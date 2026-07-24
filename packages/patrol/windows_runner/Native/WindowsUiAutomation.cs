using FlaUI.Core;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Conditions;
using FlaUI.Core.Tools;
using FlaUI.UIA3;

namespace Patrol.WindowsRunner.Native;

/// <summary>
/// Selector for desktop UI Automation lookups.
/// At least one of <see cref="Name"/>, <see cref="AutomationId"/>, or
/// <see cref="ClassName"/> must be set; provided fields are AND-ed.
/// </summary>
internal readonly record struct UiSelector(
    string? Name,
    string? AutomationId,
    string? ClassName,
    int Index
)
{
    public static UiSelector FromRequest(
        string? name,
        string? automationId,
        string? className,
        int? index
    )
    {
        var hasName = !string.IsNullOrWhiteSpace(name);
        var hasId = !string.IsNullOrWhiteSpace(automationId);
        var hasClass = !string.IsNullOrWhiteSpace(className);
        if (!hasName && !hasId && !hasClass)
        {
            throw new ArgumentException(
                "Provide at least one of \"name\", \"automationId\", or \"className\""
            );
        }

        if (index is < 0)
        {
            throw new ArgumentException("\"index\" must be >= 0");
        }

        return new UiSelector(
            hasName ? name!.Trim() : null,
            hasId ? automationId!.Trim() : null,
            hasClass ? className!.Trim() : null,
            index ?? 0
        );
    }

    public override string ToString()
    {
        var parts = new List<string>();
        if (Name is not null)
        {
            parts.Add($"name=\"{Name}\"");
        }

        if (AutomationId is not null)
        {
            parts.Add($"automationId=\"{AutomationId}\"");
        }

        if (ClassName is not null)
        {
            parts.Add($"className=\"{ClassName}\"");
        }

        if (Index != 0)
        {
            parts.Add($"index={Index}");
        }

        return string.Join(", ", parts);
    }
}

internal sealed class UiElementInfo
{
    public string? Name { get; init; }
    public string? ClassName { get; init; }
    public string? AutomationId { get; init; }
    public double X { get; init; }
    public double Y { get; init; }
    public double Width { get; init; }
    public double Height { get; init; }
}

/// <summary>
/// FlaUI.UIA3 helpers for selector-based Windows actions.
/// </summary>
internal static class WindowsUiAutomation
{
    private static readonly TimeSpan DefaultFindTimeout = TimeSpan.FromSeconds(10);

    public static void WaitUntilVisible(UiSelector selector, TimeSpan? findTimeout = null)
    {
        using var automation = new UIA3Automation();
        _ = FindElement(automation, selector, findTimeout);
    }

    public static bool IsElementVisible(UiSelector selector, TimeSpan? findTimeout = null)
    {
        using var automation = new UIA3Automation();
        try
        {
            _ = FindElement(
                automation,
                selector,
                findTimeout ?? TimeSpan.FromMilliseconds(500)
            );
            return true;
        }
        catch (InvalidOperationException)
        {
            return false;
        }
    }

    public static void Tap(UiSelector selector, TimeSpan? findTimeout = null)
    {
        using var automation = new UIA3Automation();
        ClickElement(FindElement(automation, selector, findTimeout), selector, twice: false);
    }

    public static void DoubleTap(UiSelector selector, TimeSpan? findTimeout = null)
    {
        using var automation = new UIA3Automation();
        ClickElement(FindElement(automation, selector, findTimeout), selector, twice: true);
    }

    public static void EnterText(
        UiSelector selector,
        string text,
        TimeSpan? findTimeout = null
    )
    {
        ArgumentNullException.ThrowIfNull(text);

        using var automation = new UIA3Automation();
        var element = FindElement(automation, selector, findTimeout);
        element.Focus();

        if (element.Patterns.Value.IsSupported)
        {
            element.Patterns.Value.Pattern.SetValue(text);
        }
        else
        {
            element.AsTextBox().Text = text;
        }

        Console.WriteLine(
            $"WindowsUiAutomation: enterText({selector}, length={text.Length})"
        );
    }

    public static UiElementInfo? FindElementInfo(
        UiSelector selector,
        TimeSpan? findTimeout = null
    )
    {
        using var automation = new UIA3Automation();
        try
        {
            return ToInfo(FindElement(automation, selector, findTimeout));
        }
        catch (InvalidOperationException)
        {
            return null;
        }
    }

    public static IReadOnlyList<UiElementInfo> FindElements(
        UiSelector selector,
        TimeSpan? findTimeout = null
    )
    {
        using var automation = new UIA3Automation();
        var timeout = findTimeout ?? DefaultFindTimeout;
        var desktop = automation.GetDesktop();

        AutomationElement[] matches = [];
        var found = Retry.WhileFalse(
            () =>
            {
                matches = desktop.FindAllDescendants(cf => BuildCondition(cf, selector));
                return matches.Length > 0;
            },
            timeout,
            interval: TimeSpan.FromMilliseconds(200),
            throwOnTimeout: false,
            ignoreException: true
        ).Result;

        if (!found || matches.Length == 0)
        {
            return [];
        }

        return matches.Select(ToInfo).ToList();
    }

    public static void PressKey(
        int keyCode,
        bool shift = false,
        bool ctrl = false,
        bool alt = false
    )
    {
        WindowsInput.PressKey(keyCode, shift, ctrl, alt);
        Console.WriteLine(
            $"WindowsUiAutomation: pressKey(keyCode={keyCode}, shift={shift}, ctrl={ctrl}, alt={alt})"
        );
    }

    private static void ClickElement(
        AutomationElement element,
        UiSelector selector,
        bool twice
    )
    {
        var rect = element.BoundingRectangle;
        if (rect.IsEmpty || rect.Width <= 0 || rect.Height <= 0)
        {
            throw new InvalidOperationException(
                $"UI element ({selector}) has an empty bounding rectangle"
            );
        }

        void Once()
        {
            if (element.Patterns.Invoke.IsSupported)
            {
                element.Patterns.Invoke.Pattern.Invoke();
                return;
            }

            if (element.Patterns.Toggle.IsSupported)
            {
                element.Patterns.Toggle.Pattern.Toggle();
                return;
            }

            element.Focus();
            var pixelX = (int)Math.Round(rect.Left + rect.Width / 2.0);
            var pixelY = (int)Math.Round(rect.Top + rect.Height / 2.0);
            WindowsInput.TapAtPixels(pixelX, pixelY);
        }

        Console.WriteLine(
            twice
                ? $"WindowsUiAutomation: doubleTap({selector})"
                : $"WindowsUiAutomation: tap({selector})"
        );
        Once();
        if (twice)
        {
            Thread.Sleep(100);
            Once();
        }
    }

    private static AutomationElement FindElement(
        UIA3Automation automation,
        UiSelector selector,
        TimeSpan? findTimeout
    )
    {
        var desktop = automation.GetDesktop();
        var timeout = findTimeout ?? DefaultFindTimeout;

        AutomationElement[] matches = [];
        var found = Retry.WhileFalse(
            () =>
            {
                matches = desktop.FindAllDescendants(cf => BuildCondition(cf, selector));
                return matches.Length > selector.Index;
            },
            timeout,
            interval: TimeSpan.FromMilliseconds(200),
            throwOnTimeout: false,
            ignoreException: true
        ).Result;

        if (!found || matches.Length <= selector.Index)
        {
            throw new InvalidOperationException(
                $"No UI element found ({selector}) within {timeout.TotalSeconds:0}s"
            );
        }

        return matches[selector.Index];
    }

    private static ConditionBase BuildCondition(ConditionFactory cf, UiSelector selector)
    {
        ConditionBase? condition = null;

        void And(ConditionBase next)
        {
            condition = condition is null ? next : condition.And(next);
        }

        if (selector.Name is not null)
        {
            And(cf.ByName(selector.Name));
        }

        if (selector.AutomationId is not null)
        {
            And(cf.ByAutomationId(selector.AutomationId));
        }

        if (selector.ClassName is not null)
        {
            And(cf.ByClassName(selector.ClassName));
        }

        return condition
            ?? throw new InvalidOperationException("Selector produced no condition");
    }

    private static UiElementInfo ToInfo(AutomationElement element)
    {
        var rect = element.BoundingRectangle;
        string? automationId = null;
        try
        {
            automationId = element.Properties.AutomationId.ValueOrDefault;
        }
        catch
        {
            // Some hosts throw for unsupported properties.
        }

        return new UiElementInfo
        {
            Name = element.Name,
            ClassName = element.ClassName,
            AutomationId = string.IsNullOrEmpty(automationId) ? null : automationId,
            X = rect.Left,
            Y = rect.Top,
            Width = rect.Width,
            Height = rect.Height,
        };
    }
}
