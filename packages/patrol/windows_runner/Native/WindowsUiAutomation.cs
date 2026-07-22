using System.Drawing;
using FlaUI.Core;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Conditions;
using FlaUI.Core.Tools;
using FlaUI.UIA3;

namespace Patrol.WindowsRunner.Native;

/// <summary>
/// Selector for desktop UI Automation lookups (exactly one of Name / AutomationId).
/// </summary>
internal readonly record struct UiSelector(string? Name, string? AutomationId)
{
    public static UiSelector FromRequest(string? name, string? automationId)
    {
        var hasName = !string.IsNullOrWhiteSpace(name);
        var hasId = !string.IsNullOrWhiteSpace(automationId);
        if (hasName == hasId)
        {
            throw new ArgumentException(
                "Provide exactly one of \"name\" or \"automationId\""
            );
        }

        return new UiSelector(
            hasName ? name!.Trim() : null,
            hasId ? automationId!.Trim() : null
        );
    }

    public override string ToString() =>
        Name is not null ? $"name=\"{Name}\"" : $"automationId=\"{AutomationId}\"";
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

    public static void Tap(UiSelector selector, TimeSpan? findTimeout = null)
    {
        using var automation = new UIA3Automation();
        var element = FindElement(automation, selector, findTimeout);
        var rect = element.BoundingRectangle;
        if (rect.IsEmpty || rect.Width <= 0 || rect.Height <= 0)
        {
            throw new InvalidOperationException(
                $"UI element ({selector}) has an empty bounding rectangle"
            );
        }

        // Prefer Invoke (works even when another window is focused). Fall back to
        // focusing + clicking the center — needed for controls without Invoke.
        if (element.Patterns.Invoke.IsSupported)
        {
            Console.WriteLine($"WindowsUiAutomation: tap({selector}) via Invoke");
            element.Patterns.Invoke.Pattern.Invoke();
            return;
        }

        element.Focus();
        var pixelX = (int)Math.Round(rect.Left + rect.Width / 2.0);
        var pixelY = (int)Math.Round(rect.Top + rect.Height / 2.0);

        Console.WriteLine(
            string.Create(
                System.Globalization.CultureInfo.InvariantCulture,
                $"WindowsUiAutomation: tap({selector}) -> ({pixelX}, {pixelY}) bounds={FormatRect(rect)}"
            )
        );

        WindowsInput.TapAtPixels(pixelX, pixelY);
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

    private static AutomationElement FindElement(
        UIA3Automation automation,
        UiSelector selector,
        TimeSpan? findTimeout
    )
    {
        var desktop = automation.GetDesktop();
        var timeout = findTimeout ?? DefaultFindTimeout;
        ConditionBase Condition(ConditionFactory cf) =>
            selector.Name is not null
                ? cf.ByName(selector.Name)
                : cf.ByAutomationId(selector.AutomationId!);

        var element = Retry.WhileNull(
            () => desktop.FindFirstDescendant(Condition),
            timeout,
            interval: TimeSpan.FromMilliseconds(200),
            throwOnTimeout: false,
            ignoreException: true
        ).Result;

        if (element is null)
        {
            throw new InvalidOperationException(
                $"No UI element found ({selector}) within {timeout.TotalSeconds:0}s"
            );
        }

        return element;
    }

    private static string FormatRect(Rectangle rect) =>
        string.Create(
            System.Globalization.CultureInfo.InvariantCulture,
            $"[{rect.Left},{rect.Top} {rect.Width}x{rect.Height}]"
        );
}
