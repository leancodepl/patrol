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

        _app.MapPost("/doubleTap", async (HttpRequest request) =>
            await RunSelectorActionAsync(
                request,
                "doubleTap",
                selector => WindowsUiAutomation.DoubleTap(selector)
            ));

        _app.MapPost("/waitUntilVisible", async (HttpRequest request) =>
            await RunSelectorActionAsync(
                request,
                "waitUntilVisible",
                selector => WindowsUiAutomation.WaitUntilVisible(selector)
            ));

        _app.MapPost(
            "/isElementVisible",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                try
                {
                    var selector = ParseSelector(doc.RootElement);
                    Console.WriteLine($"AutomatorServer: isElementVisible({selector})");
                    var visible = WindowsUiAutomation.IsElementVisible(selector);
                    return Results.Json(new { visible });
                }
                catch (ArgumentException ex)
                {
                    return Results.BadRequest(new { error = ex.Message });
                }
            }
        );

        _app.MapPost(
            "/findElement",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                try
                {
                    var selector = ParseSelector(doc.RootElement);
                    Console.WriteLine($"AutomatorServer: findElement({selector})");
                    var info = WindowsUiAutomation.FindElementInfo(selector);
                    return info is null
                        ? Results.Json(new { element = (object?)null })
                        : Results.Json(new { element = ToJson(info) });
                }
                catch (ArgumentException ex)
                {
                    return Results.BadRequest(new { error = ex.Message });
                }
            }
        );

        _app.MapPost(
            "/findElements",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                try
                {
                    var selector = ParseSelector(doc.RootElement);
                    Console.WriteLine($"AutomatorServer: findElements({selector})");
                    var elements = WindowsUiAutomation.FindElements(selector);
                    return Results.Json(new { elements = elements.Select(ToJson) });
                }
                catch (ArgumentException ex)
                {
                    return Results.BadRequest(new { error = ex.Message });
                }
            }
        );

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

        _app.MapPost(
            "/pressKey",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                var root = doc.RootElement;
                if (
                    !root.TryGetProperty("keyCode", out var keyEl)
                    || keyEl.ValueKind != JsonValueKind.Number
                )
                {
                    return Results.BadRequest(new { error = "pressKey requires \"keyCode\"" });
                }

                try
                {
                    var keyCode = keyEl.GetInt32();
                    var shift = root.TryGetProperty("shift", out var s) && s.GetBoolean();
                    var ctrl = root.TryGetProperty("ctrl", out var c) && c.GetBoolean();
                    var alt = root.TryGetProperty("alt", out var a) && a.GetBoolean();
                    Console.WriteLine($"AutomatorServer: pressKey({keyCode})");
                    WindowsUiAutomation.PressKey(keyCode, shift, ctrl, alt);
                    return Results.Ok();
                }
                catch (ArgumentOutOfRangeException ex)
                {
                    return Results.BadRequest(new { error = ex.Message });
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine($"AutomatorServer: pressKey failed: {ex.Message}");
                    return Results.Json(
                        new { error = ex.Message },
                        statusCode: StatusCodes.Status500InternalServerError
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
        string? className = null;
        int? index = null;

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

        if (
            root.TryGetProperty("className", out var classEl)
            && classEl.ValueKind == JsonValueKind.String
        )
        {
            className = classEl.GetString();
        }

        if (
            root.TryGetProperty("index", out var indexEl)
            && indexEl.ValueKind == JsonValueKind.Number
        )
        {
            index = indexEl.GetInt32();
        }

        return UiSelector.FromRequest(name, automationId, className, index);
    }

    private static object ToJson(UiElementInfo info) =>
        new
        {
            name = info.Name,
            className = info.ClassName,
            automationId = info.AutomationId,
            x = info.X,
            y = info.Y,
            width = info.Width,
            height = info.Height,
        };

    private static TaskCompletionSource NewReadySource() =>
        new(TaskCreationOptions.RunContinuationsAsynchronously);
}
