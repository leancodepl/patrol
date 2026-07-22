using System.Globalization;
using System.Text.Json;
using Patrol.WindowsRunner.Native;
using Patrol.WindowsRunner.Protocol;

namespace Patrol.WindowsRunner;

internal sealed class AutomatorServer
{
    private readonly int _port;
    private readonly object _readyLock = new();
    private TaskCompletionSource _ready = NewReadySource();
    private WebApplication? _app;

    public AutomatorServer(int port)
    {
        _port = port;
    }

    public void ResetReadyGate()
    {
        lock (_readyLock)
        {
            _ready = NewReadySource();
        }
    }

    public Task WaitUntilReadyAsync(CancellationToken ct)
    {
        TaskCompletionSource ready;
        lock (_readyLock)
        {
            ready = _ready;
        }

        return ready.Task.WaitAsync(ct);
    }

    public async Task StartAsync(CancellationToken ct)
    {
        var builder = WebApplication.CreateSlimBuilder();
        builder.WebHost.UseUrls($"http://127.0.0.1:{_port}");
        builder.Logging.ClearProviders();
        builder.Logging.AddConsole();

        _app = builder.Build();

        _app.MapPost(
            "/markPatrolAppServiceReady",
            () =>
            {
                Console.WriteLine("AutomatorServer: markPatrolAppServiceReady");
                lock (_readyLock)
                {
                    _ready.TrySetResult();
                }

                return Results.Ok();
            }
        );

        _app.MapPost(
            "/tapAt",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                var root = doc.RootElement;
                var tap = new TapAtRequest
                {
                    X = root.GetProperty("x").GetDouble(),
                    Y = root.GetProperty("y").GetDouble(),
                };

                Console.WriteLine(
                    string.Create(
                        CultureInfo.InvariantCulture,
                        $"AutomatorServer: tapAt({tap.X}, {tap.Y})"
                    )
                );
                WindowsInput.TapAtNormalized(tap.X, tap.Y);
                return Results.Ok();
            }
        );

        await _app.StartAsync(ct);
        Console.WriteLine($"AutomatorServer listening on http://127.0.0.1:{_port}");
    }

    public async Task StopAsync()
    {
        if (_app is null)
        {
            return;
        }

        await _app.StopAsync();
        await _app.DisposeAsync();
    }

    private static TaskCompletionSource NewReadySource() =>
        new(TaskCreationOptions.RunContinuationsAsynchronously);
}
