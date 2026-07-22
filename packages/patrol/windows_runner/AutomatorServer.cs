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

        _app.MapPost("/tap", async (HttpRequest request) =>
            await RunSelectorActionAsync(
                request,
                "tap",
                selector => WindowsUiAutomation.Tap(selector)
            ));

        _app.MapPost("/waitUntilVisible", async (HttpRequest request) =>
            await RunSelectorActionAsync(
                request,
                "waitUntilVisible",
                selector => WindowsUiAutomation.WaitUntilVisible(selector)
            ));

        _app.MapPost(
            "/enterText",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                var root = doc.RootElement;
                if (
                    !root.TryGetProperty("text", out var textEl)
                    || textEl.ValueKind != JsonValueKind.String
                )
                {
                    return Results.BadRequest(new { error = "enterText requires \"text\"" });
                }

                try
                {
                    var selector = ParseSelector(root);
                    var text = textEl.GetString() ?? "";
                    Console.WriteLine($"AutomatorServer: enterText({selector})");
                    WindowsUiAutomation.EnterText(selector, text);
                    return Results.Ok();
                }
                catch (ArgumentException ex)
                {
                    return Results.BadRequest(new { error = ex.Message });
                }
                catch (InvalidOperationException ex)
                {
                    Console.Error.WriteLine($"AutomatorServer: enterText failed: {ex.Message}");
                    return Results.Json(
                        new { error = ex.Message },
                        statusCode: StatusCodes.Status404NotFound
                    );
                }
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

    private static async Task<IResult> RunSelectorActionAsync(
        HttpRequest request,
        string actionName,
        Action<UiSelector> action
    )
    {
        using var doc = await JsonDocument.ParseAsync(
            request.Body,
            cancellationToken: request.HttpContext.RequestAborted
        );
        try
        {
            var selector = ParseSelector(doc.RootElement);
            Console.WriteLine($"AutomatorServer: {actionName}({selector})");
            action(selector);
            return Results.Ok();
        }
        catch (ArgumentException ex)
        {
            return Results.BadRequest(new { error = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            Console.Error.WriteLine($"AutomatorServer: {actionName} failed: {ex.Message}");
            return Results.Json(
                new { error = ex.Message },
                statusCode: StatusCodes.Status404NotFound
            );
        }
    }

    private static UiSelector ParseSelector(JsonElement root)
    {
        string? name = null;
        string? automationId = null;
        if (
            root.TryGetProperty("name", out var nameEl)
            && nameEl.ValueKind == JsonValueKind.String
        )
        {
            name = nameEl.GetString();
        }

        if (
            root.TryGetProperty("automationId", out var idEl)
            && idEl.ValueKind == JsonValueKind.String
        )
        {
            automationId = idEl.GetString();
        }

        return UiSelector.FromRequest(name, automationId);
    }

    private static TaskCompletionSource NewReadySource() =>
        new(TaskCreationOptions.RunContinuationsAsynchronously);
}
