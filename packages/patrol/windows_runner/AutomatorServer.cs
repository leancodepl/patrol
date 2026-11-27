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

        // Reject browser Origin / non-JSON POSTs (loopback CSRF) and map
        // unhandled failures to PROTOCOL.md `{ "error": ... }` bodies.
        _app.Use(async (context, next) =>
        {
            if (HttpMethods.IsPost(context.Request.Method))
            {
                if (context.Request.Headers.ContainsKey("Origin"))
                {
                    await WriteErrorAsync(context, 400, "Browser Origin header is not allowed");
                    return;
                }

                var contentType = context.Request.ContentType;
                if (
                    contentType is null
                    || !contentType.StartsWith("application/json", StringComparison.OrdinalIgnoreCase)
                )
                {
                    await WriteErrorAsync(context, 400, "Content-Type must be application/json");
                    return;
                }
            }

            try
            {
                await next();
            }
            catch (Exception ex) when (ex is JsonException or ArgumentException)
            {
                await WriteErrorAsync(context, 400, ex is JsonException j
                    ? $"Invalid JSON: {j.Message}"
                    : ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                await WriteErrorAsync(context, 404, ex.Message);
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"AutomatorServer: unhandled error: {ex}");
                await WriteErrorAsync(context, 500, ex.Message);
            }
        });

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
                using var doc = await ReadJsonAsync(request);
                var root = doc.RootElement;
                if (
                    !root.TryGetProperty("x", out var xEl)
                    || !root.TryGetProperty("y", out var yEl)
                    || xEl.ValueKind != JsonValueKind.Number
                    || yEl.ValueKind != JsonValueKind.Number
                )
                {
                    return ErrorBadRequest("tapAt requires numeric \"x\" and \"y\"");
                }

                var tap = new TapAtRequest
                {
                    X = xEl.GetDouble(),
                    Y = yEl.GetDouble(),
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
                using var doc = await ReadJsonAsync(request);
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
        );

        _app.MapPost(
            "/findElement",
            async (HttpRequest request) =>
            {
                using var doc = await ReadJsonAsync(request);
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
        );

        _app.MapPost(
            "/enterText",
            async (HttpRequest request) =>
            {
                using var doc = await ReadJsonAsync(request);
                var root = doc.RootElement;
                if (
                    !root.TryGetProperty("text", out var textEl)
                    || textEl.ValueKind != JsonValueKind.String
                )
                {
                    return ErrorBadRequest("enterText requires \"text\"");
                }

                var selector = ParseSelector(root);
                var timeout = ParseTimeout(root);
                var text = textEl.GetString() ?? "";
                Console.WriteLine($"AutomatorServer: enterText({selector})");
                WindowsUiAutomation.EnterText(selector, text, timeout);
                return Results.Ok();
            }
        );

        _app.MapPost(
            "/pressKey",
            async (HttpRequest request) =>
            {
                using var doc = await ReadJsonAsync(request);
                var root = doc.RootElement;
                if (
                    !root.TryGetProperty("keyCode", out var keyEl)
                    || keyEl.ValueKind != JsonValueKind.Number
                )
                {
                    return ErrorBadRequest("pressKey requires \"keyCode\"");
                }

                var keyCode = keyEl.GetInt32();
                var shift = root.TryGetProperty("shift", out var s) && s.GetBoolean();
                var ctrl = root.TryGetProperty("ctrl", out var c) && c.GetBoolean();
                var alt = root.TryGetProperty("alt", out var a) && a.GetBoolean();
                Console.WriteLine($"AutomatorServer: pressKey({keyCode})");
                WindowsUiAutomation.PressKey(keyCode, shift, ctrl, alt);
                return Results.Ok();
            }
        );

        _app.MapPost(
            "/launchApp",
            async (HttpRequest request) =>
            {
                using var doc = await ReadJsonAsync(request);
                var root = doc.RootElement;
                if (
                    !root.TryGetProperty("appPath", out var pathEl)
                    || pathEl.ValueKind != JsonValueKind.String
                    || string.IsNullOrWhiteSpace(pathEl.GetString())
                )
                {
                    return ErrorBadRequest("launchApp requires \"appPath\"");
                }

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
        );

        _app.MapPost(
            "/activateApp",
            async (HttpRequest request) =>
            {
                using var doc = await ReadJsonAsync(request);
                var root = doc.RootElement;
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
        using var doc = await ReadJsonAsync(request);
        var root = doc.RootElement;
        var selector = ParseSelector(root);
        var timeout = ParseTimeout(root);
        Console.WriteLine($"AutomatorServer: {actionName}({selector})");
        action(selector, timeout);
        return Results.Ok();
    }

    private static async Task<JsonDocument> ReadJsonAsync(HttpRequest request)
    {
        return await JsonDocument.ParseAsync(
            request.Body,
            cancellationToken: request.HttpContext.RequestAborted
        );
    }

    private static async Task WriteErrorAsync(HttpContext context, int statusCode, string message)
    {
        if (context.Response.HasStarted)
        {
            throw new InvalidOperationException($"Cannot write error after response started: {message}");
        }

        context.Response.StatusCode = statusCode;
        await context.Response.WriteAsJsonAsync(new { error = message });
    }

    /// <summary>400 — invalid request. Body: <c>{ "error": "..." }</c>.</summary>
    private static IResult ErrorBadRequest(string message) =>
        Results.Json(new { error = message }, statusCode: StatusCodes.Status400BadRequest);

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

        var within = ParseScope(root);
        return UiSelector.FromRequest(name, automationId, className, index, within);
    }

    private static UiScope? ParseScope(JsonElement root)
    {
        if (
            !root.TryGetProperty("within", out var withinEl)
            || withinEl.ValueKind != JsonValueKind.Object
        )
        {
            return null;
        }

        string? processName = null;
        string? windowName = null;
        int? processId = null;

        if (
            withinEl.TryGetProperty("processName", out var pn)
            && pn.ValueKind == JsonValueKind.String
        )
        {
            processName = pn.GetString();
        }

        if (
            withinEl.TryGetProperty("windowName", out var wn)
            && wn.ValueKind == JsonValueKind.String
        )
        {
            windowName = wn.GetString();
        }

        if (
            withinEl.TryGetProperty("processId", out var pidEl)
            && pidEl.ValueKind == JsonValueKind.Number
        )
        {
            processId = pidEl.GetInt32();
        }

        var scope = UiScope.FromRequest(processId, processName, windowName);
        if (scope is null)
        {
            throw new ArgumentException(
                "\"within\" requires at least one of \"processId\", \"processName\", or \"windowName\""
            );
        }

        return scope;
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
