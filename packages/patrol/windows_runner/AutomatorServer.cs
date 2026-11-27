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
                (selector, timeout) => WindowsUiAutomation.Tap(selector, timeout)
            ));

        _app.MapPost("/doubleTap", async (HttpRequest request) =>
            await RunSelectorActionAsync(
                request,
                "doubleTap",
                (selector, timeout) =>
                    WindowsUiAutomation.DoubleTap(selector, timeout)
            ));

        _app.MapPost("/waitUntilVisible", async (HttpRequest request) =>
            await RunSelectorActionAsync(
                request,
                "waitUntilVisible",
                (selector, timeout) =>
                    WindowsUiAutomation.WaitUntilVisible(selector, timeout)
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
                    var root = doc.RootElement;
                    var selector = ParseSelector(root);
                    var timeout = ParseTimeout(root);
                    Console.WriteLine($"AutomatorServer: isElementVisible({selector})");
                    var visible = WindowsUiAutomation.IsElementVisible(
                        selector,
                        timeout
                    );
                    return Results.Json(new { visible });
                }
                catch (ArgumentException ex)
                {
                    return ErrorBadRequest(ex.Message);
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
                    var root = doc.RootElement;
                    var selector = ParseSelector(root);
                    var timeout = ParseTimeout(root);
                    Console.WriteLine($"AutomatorServer: findElement({selector})");
                    var info = WindowsUiAutomation.FindElementInfo(
                        selector,
                        timeout
                    );
                    return info is null
                        ? Results.Json(new { element = (object?)null })
                        : Results.Json(new { element = ToJson(info) });
                }
                catch (ArgumentException ex)
                {
                    return ErrorBadRequest(ex.Message);
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
                    var root = doc.RootElement;
                    var selector = ParseSelector(root);
                    var timeout = ParseTimeout(root);
                    Console.WriteLine($"AutomatorServer: findElements({selector})");
                    var elements = WindowsUiAutomation.FindElements(
                        selector,
                        timeout
                    );
                    return Results.Json(new { elements = elements.Select(ToJson) });
                }
                catch (ArgumentException ex)
                {
                    return ErrorBadRequest(ex.Message);
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
                    return ErrorBadRequest("enterText requires \"text\"");
                }

                try
                {
                    var selector = ParseSelector(root);
                    var timeout = ParseTimeout(root);
                    var text = textEl.GetString() ?? "";
                    Console.WriteLine($"AutomatorServer: enterText({selector})");
                    WindowsUiAutomation.EnterText(selector, text, timeout);
                    return Results.Ok();
                }
                catch (ArgumentException ex)
                {
                    return ErrorBadRequest(ex.Message);
                }
                catch (InvalidOperationException ex)
                {
                    Console.Error.WriteLine($"AutomatorServer: enterText failed: {ex.Message}");
                    return ErrorNotFound(ex.Message);
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
                    return ErrorBadRequest("pressKey requires \"keyCode\"");
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
                    return ErrorBadRequest(ex.Message);
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine($"AutomatorServer: pressKey failed: {ex.Message}");
                    return ErrorInternal(ex.Message);
                }
            }
        );

        _app.MapPost(
            "/launchApp",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                var root = doc.RootElement;
                if (
                    !root.TryGetProperty("appPath", out var pathEl)
                    || pathEl.ValueKind != JsonValueKind.String
                    || string.IsNullOrWhiteSpace(pathEl.GetString())
                )
                {
                    return ErrorBadRequest("launchApp requires \"appPath\"");
                }

                try
                {
                    var appPath = pathEl.GetString()!;
                    string? arguments = null;
                    if (
                        root.TryGetProperty("arguments", out var argsEl)
                        && argsEl.ValueKind == JsonValueKind.String
                    )
                    {
                        arguments = argsEl.GetString();
                    }

                    var activate = true;
                    if (root.TryGetProperty("activate", out var actEl)
                        && (actEl.ValueKind == JsonValueKind.True
                            || actEl.ValueKind == JsonValueKind.False))
                    {
                        activate = actEl.GetBoolean();
                    }

                    Console.WriteLine($"AutomatorServer: launchApp(\"{appPath}\")");
                    var pid = WindowsAppControl.LaunchApp(appPath, arguments, activate);
                    return Results.Json(new { processId = pid });
                }
                catch (Exception ex)
                {
                    Console.Error.WriteLine($"AutomatorServer: launchApp failed: {ex.Message}");
                    return ErrorInternal(ex.Message);
                }
            }
        );

        _app.MapPost(
            "/activateApp",
            async (HttpRequest request) =>
            {
                using var doc = await JsonDocument.ParseAsync(
                    request.Body,
                    cancellationToken: request.HttpContext.RequestAborted
                );
                var root = doc.RootElement;
                try
                {
                    string? processName = null;
                    string? windowName = null;
                    int? processId = null;

                    if (
                        root.TryGetProperty("processName", out var pn)
                        && pn.ValueKind == JsonValueKind.String
                    )
                    {
                        processName = pn.GetString();
                    }

                    if (
                        root.TryGetProperty("windowName", out var wn)
                        && wn.ValueKind == JsonValueKind.String
                    )
                    {
                        windowName = wn.GetString();
                    }

                    if (
                        root.TryGetProperty("processId", out var pidEl)
                        && pidEl.ValueKind == JsonValueKind.Number
                    )
                    {
                        processId = pidEl.GetInt32();
                    }

                    Console.WriteLine("AutomatorServer: activateApp");
                    WindowsAppControl.ActivateApp(processName, windowName, processId);
                    return Results.Ok();
                }
                catch (ArgumentException ex)
                {
                    return ErrorBadRequest(ex.Message);
                }
                catch (InvalidOperationException ex)
                {
                    Console.Error.WriteLine($"AutomatorServer: activateApp failed: {ex.Message}");
                    return ErrorNotFound(ex.Message);
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
        Action<UiSelector, TimeSpan?> action
    )
    {
        using var doc = await JsonDocument.ParseAsync(
            request.Body,
            cancellationToken: request.HttpContext.RequestAborted
        );
        try
        {
            var root = doc.RootElement;
            var selector = ParseSelector(root);
            var timeout = ParseTimeout(root);
            Console.WriteLine($"AutomatorServer: {actionName}({selector})");
            action(selector, timeout);
            return Results.Ok();
        }
        catch (ArgumentException ex)
        {
            return ErrorBadRequest(ex.Message);
        }
        catch (InvalidOperationException ex)
        {
            Console.Error.WriteLine($"AutomatorServer: {actionName} failed: {ex.Message}");
            return ErrorNotFound(ex.Message);
        }
    }

    /// <summary>400 — invalid request. Body: <c>{ "error": "..." }</c>.</summary>
    private static IResult ErrorBadRequest(string message) =>
        Results.Json(new { error = message }, statusCode: StatusCodes.Status400BadRequest);

    /// <summary>404 — target not found. Body: <c>{ "error": "..." }</c>.</summary>
    private static IResult ErrorNotFound(string message) =>
        Results.Json(new { error = message }, statusCode: StatusCodes.Status404NotFound);

    /// <summary>500 — unexpected failure. Body: <c>{ "error": "..." }</c>.</summary>
    private static IResult ErrorInternal(string message) =>
        Results.Json(
            new { error = message },
            statusCode: StatusCodes.Status500InternalServerError
        );

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

    private static TimeSpan? ParseTimeout(JsonElement root)
    {
        if (
            !root.TryGetProperty("timeoutMillis", out var timeoutEl)
            || timeoutEl.ValueKind != JsonValueKind.Number
        )
        {
            return null;
        }

        var millis = timeoutEl.GetInt32();
        if (millis <= 0)
        {
            throw new ArgumentException("\"timeoutMillis\" must be > 0");
        }

        return TimeSpan.FromMilliseconds(millis);
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
