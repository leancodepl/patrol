using System.Diagnostics;
using Patrol.WindowsRunner.Native;

namespace Patrol.WindowsRunner;

internal sealed class TestOrchestrator
{
    private readonly string _appPath;
    private readonly int _testPort;
    private readonly int _appPort;
    private readonly TimeSpan _readyTimeout;
    private readonly TimeSpan _appExitTimeout;

    public TestOrchestrator(
        string appPath,
        int testPort,
        int appPort,
        TimeSpan? readyTimeout = null,
        TimeSpan? appExitTimeout = null
    )
    {
        _appPath = appPath;
        _testPort = testPort;
        _appPort = appPort;
        _readyTimeout = readyTimeout ?? TimeSpan.FromMinutes(2);
        _appExitTimeout = appExitTimeout ?? TimeSpan.FromSeconds(15);
    }

    public async Task<int> RunAsync(CancellationToken ct)
    {
        WindowsInput.EnsureDpiAware();

        var server = new AutomatorServer(_testPort);

        try
        {
            await server.StartAsync(ct);

            // First launch discovers the suite and runs the first test. Later
            // tests each get a fresh app process because PatrolAppService
            // completers are one-shot per launch (same constraint as Android ATO).
            IReadOnlyList<string> tests;
            var failed = 0;

            await using (var firstApp = await LaunchAppAsync(server, ct))
            {
                var client = new PatrolAppServiceClient(_appPort);
                tests = DartTestTree
                    .Flatten((await client.ListDartTestsAsync(ct)).Group)
                    .Where(t => !t.Skip)
                    .Select(t => t.Name)
                    .ToList();

                if (tests.Count == 0)
                {
                    Console.Error.WriteLine("TestOrchestrator: no runnable Dart tests found");
                    return 4;
                }

                Console.WriteLine($"TestOrchestrator: discovered {tests.Count} test(s)");
                failed += await RunOneAsync(client, tests[0], ct);
                await StopAppAsync(firstApp);
            }

            for (var i = 1; i < tests.Count; i++)
            {
                ct.ThrowIfCancellationRequested();
                await using var app = await LaunchAppAsync(server, ct);
                var client = new PatrolAppServiceClient(_appPort);
                failed += await RunOneAsync(client, tests[i], ct);
                await StopAppAsync(app);
            }

            if (failed > 0)
            {
                Console.Error.WriteLine(
                    $"TestOrchestrator: {failed}/{tests.Count} test(s) failed"
                );
                return 1;
            }

            Console.WriteLine($"TestOrchestrator: all {tests.Count} test(s) passed");
            return 0;
        }
        finally
        {
            await server.StopAsync();
        }
    }

    private static async Task<int> RunOneAsync(
        PatrolAppServiceClient client,
        string name,
        CancellationToken ct
    )
    {
        Console.WriteLine($"TestOrchestrator: running {name}");
        var result = await client.RunDartTestAsync(name, ct);
        if (result.Passed)
        {
            Console.WriteLine($"TestOrchestrator: passed {name}");
            return 0;
        }

        Console.Error.WriteLine($"TestOrchestrator: failed {name}\n{result.Details}");
        return 1;
    }

    private async Task<TrackedProcess> LaunchAppAsync(
        AutomatorServer server,
        CancellationToken ct
    )
    {
        server.ResetReadyGate();

        Console.WriteLine($"TestOrchestrator: launching {_appPath}");
        var appDir = Path.GetDirectoryName(_appPath) ?? Environment.CurrentDirectory;
        var startInfo = new ProcessStartInfo
        {
            FileName = _appPath,
            UseShellExecute = false,
            WorkingDirectory = appDir,
        };

        // Optional helper for outside-app fixtures (dev/E2E only).
        var fixture = Environment.GetEnvironmentVariable("PATROL_WINDOWS_FIXTURE_EXE");
        if (!string.IsNullOrWhiteSpace(fixture) && File.Exists(fixture))
        {
            startInfo.Environment["PATROL_WINDOWS_FIXTURE_EXE"] = Path.GetFullPath(fixture);
        }

        var process =
            Process.Start(startInfo)
            ?? throw new InvalidOperationException("Failed to start app process");

        using var readyCts = CancellationTokenSource.CreateLinkedTokenSource(ct);
        readyCts.CancelAfter(_readyTimeout);

        try
        {
            await server.WaitUntilReadyAsync(readyCts.Token);
        }
        catch (OperationCanceledException) when (!ct.IsCancellationRequested)
        {
            await StopAppAsync(new TrackedProcess(process));
            throw new TimeoutException(
                "Timed out waiting for markPatrolAppServiceReady"
            );
        }

        Console.WriteLine("TestOrchestrator: app service ready");
        return new TrackedProcess(process);
    }

    private async Task StopAppAsync(TrackedProcess app)
    {
        var process = app.Process;
        if (process.HasExited)
        {
            return;
        }

        try
        {
            // Prefer a graceful exit so Flutter can dispose bindings cleanly.
            process.CloseMainWindow();
            if (await WaitForExitAsync(process, _appExitTimeout))
            {
                return;
            }
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine(
                $"TestOrchestrator: graceful stop failed: {ex.Message}"
            );
        }

        try
        {
            if (!process.HasExited)
            {
                process.Kill(entireProcessTree: true);
                await WaitForExitAsync(process, TimeSpan.FromSeconds(5));
            }
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"TestOrchestrator: failed to kill app: {ex.Message}");
        }
    }

    private static async Task<bool> WaitForExitAsync(Process process, TimeSpan timeout)
    {
        using var cts = new CancellationTokenSource(timeout);
        try
        {
            await process.WaitForExitAsync(cts.Token);
            return true;
        }
        catch (OperationCanceledException)
        {
            return process.HasExited;
        }
    }

    private sealed class TrackedProcess(Process process) : IAsyncDisposable
    {
        public Process Process { get; } = process;

        public async ValueTask DisposeAsync()
        {
            try
            {
                if (!Process.HasExited)
                {
                    Process.Kill(entireProcessTree: true);
                    await Process.WaitForExitAsync();
                }
            }
            catch
            {
                // Best-effort cleanup for unexpected failures mid-launch.
            }
            finally
            {
                Process.Dispose();
            }
        }
    }
}
