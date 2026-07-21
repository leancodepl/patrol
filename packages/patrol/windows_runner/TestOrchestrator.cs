using System.Diagnostics;
using Patrol.WindowsRunner.Native;

namespace Patrol.WindowsRunner;

internal sealed class TestOrchestrator
{
    private readonly string _appPath;
    private readonly int _testPort;
    private readonly int _appPort;
    private readonly TimeSpan _readyTimeout;

    public TestOrchestrator(
        string appPath,
        int testPort,
        int appPort,
        TimeSpan? readyTimeout = null
    )
    {
        _appPath = appPath;
        _testPort = testPort;
        _appPort = appPort;
        _readyTimeout = readyTimeout ?? TimeSpan.FromMinutes(2);
    }

    public async Task<int> RunAsync(CancellationToken ct)
    {
        WindowsInput.EnsureDpiAware();

        var server = new AutomatorServer(_testPort);
        Process? app = null;

        try
        {
            await server.StartAsync(ct);

            Console.WriteLine($"TestOrchestrator: launching {_appPath}");
            var appDir = Path.GetDirectoryName(_appPath) ?? Environment.CurrentDirectory;
            var startInfo = new ProcessStartInfo
            {
                FileName = _appPath,
                UseShellExecute = false,
                WorkingDirectory = appDir,
            };

            // Best-effort: help the Dart test find the outside-app fixture.
            var fixture = FindFixtureExe();
            if (fixture is not null)
            {
                startInfo.Environment["PATROL_WINDOWS_FIXTURE_EXE"] = fixture;
                Console.WriteLine($"TestOrchestrator: fixture={fixture}");
            }

            app = Process.Start(startInfo);

            if (app is null)
            {
                Console.Error.WriteLine("TestOrchestrator: failed to start app process");
                return 2;
            }

            using var readyCts = CancellationTokenSource.CreateLinkedTokenSource(ct);
            readyCts.CancelAfter(_readyTimeout);

            try
            {
                await server.WaitUntilReadyAsync(readyCts.Token);
            }
            catch (OperationCanceledException) when (!ct.IsCancellationRequested)
            {
                Console.Error.WriteLine(
                    "TestOrchestrator: timed out waiting for markPatrolAppServiceReady"
                );
                return 3;
            }

            Console.WriteLine("TestOrchestrator: app service ready");
            var client = new PatrolAppServiceClient(_appPort);
            var listed = await client.ListDartTestsAsync(ct);
            var tests = DartTestTree
                .Flatten(listed.Group)
                .Where(t => !t.Skip)
                .ToList();

            if (tests.Count == 0)
            {
                Console.Error.WriteLine("TestOrchestrator: no runnable Dart tests found");
                return 4;
            }

            // POC: one app process can complete one runDartTest (single completers).
            var (name, _) = tests[0];
            if (tests.Count > 1)
            {
                Console.WriteLine(
                    $"TestOrchestrator: POC runs first test only ({tests.Count} found): {name}"
                );
            }
            else
            {
                Console.WriteLine($"TestOrchestrator: running {name}");
            }

            var result = await client.RunDartTestAsync(name, ct);
            if (!result.Passed)
            {
                Console.Error.WriteLine(
                    $"TestOrchestrator: test failed: {name}\n{result.Details}"
                );
                return 1;
            }

            Console.WriteLine($"TestOrchestrator: test passed: {name}");
            return 0;
        }
        finally
        {
            try
            {
                if (app is { HasExited: false })
                {
                    app.Kill(entireProcessTree: true);
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"TestOrchestrator: failed to kill app: {ex.Message}");
            }

            await server.StopAsync();
        }
    }

    private static string? FindFixtureExe()
    {
        var fromEnv = Environment.GetEnvironmentVariable("PATROL_WINDOWS_FIXTURE_EXE");
        if (!string.IsNullOrWhiteSpace(fromEnv) && File.Exists(fromEnv))
        {
            return Path.GetFullPath(fromEnv);
        }

        var dir = new DirectoryInfo(Directory.GetCurrentDirectory());
        for (var i = 0; i < 12 && dir is not null; i++)
        {
            var candidates = new[]
            {
                Path.Combine(
                    dir.FullName,
                    "dev",
                    "windows_poc",
                    "fixture",
                    "bin",
                    "Release",
                    "net8.0-windows",
                    "patrol_windows_fixture.exe"
                ),
                Path.Combine(
                    dir.FullName,
                    "fixture",
                    "bin",
                    "Release",
                    "net8.0-windows",
                    "patrol_windows_fixture.exe"
                ),
            };

            foreach (var candidate in candidates)
            {
                if (File.Exists(candidate))
                {
                    return Path.GetFullPath(candidate);
                }
            }

            dir = dir.Parent;
        }

        return null;
    }
}
