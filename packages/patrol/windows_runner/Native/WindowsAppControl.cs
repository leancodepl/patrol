using System.Diagnostics;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Definitions;
using FlaUI.Core.Tools;
using FlaUI.UIA3;

namespace Patrol.WindowsRunner.Native;

/// <summary>
/// Launch / foreground helpers for desktop apps (Explorer, fixtures, etc.).
/// </summary>
internal static class WindowsAppControl
{
    private static readonly TimeSpan DefaultActivateTimeout = TimeSpan.FromSeconds(15);

    /// <summary>
    /// Starts <paramref name="appPath"/> (EXE name or full path) with optional
    /// arguments. Returns the process id when available (Explorer may reuse a
    /// shell process, so pid can be short-lived).
    /// </summary>
    public static int LaunchApp(
        string appPath,
        string? arguments = null,
        bool activate = true,
        TimeSpan? activateTimeout = null
    )
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(appPath);

        var startInfo = new ProcessStartInfo
        {
            FileName = appPath.Trim(),
            Arguments = arguments ?? "",
            UseShellExecute = true,
        };

        Console.WriteLine(
            $"WindowsAppControl: launchApp(path=\"{startInfo.FileName}\", args=\"{startInfo.Arguments}\", activate={activate})"
        );

        var process =
            Process.Start(startInfo)
            ?? throw new InvalidOperationException($"Failed to start \"{appPath}\"");

        if (activate)
        {
            try
            {
                ActivateApp(
                    processName: SafeProcessName(process),
                    windowName: null,
                    processId: process.Id,
                    timeout: activateTimeout
                );
            }
            catch (Exception ex)
            {
                // Explorer often returns a transient helper process; still try
                // by process name / later window title from the test.
                Console.Error.WriteLine(
                    $"WindowsAppControl: launchApp activate best-effort failed: {ex.Message}"
                );
            }
        }

        return process.Id;
    }

    /// <summary>
    /// Brings a top-level window to the foreground.
    /// Provide at least one of processName, windowName, or processId.
    /// </summary>
    public static void ActivateApp(
        string? processName = null,
        string? windowName = null,
        int? processId = null,
        TimeSpan? timeout = null
    )
    {
        var hasProcess = !string.IsNullOrWhiteSpace(processName);
        var hasWindow = !string.IsNullOrWhiteSpace(windowName);
        var hasPid = processId is > 0;
        if (!hasProcess && !hasWindow && !hasPid)
        {
            throw new ArgumentException(
                "Provide at least one of \"processName\", \"windowName\", or \"processId\""
            );
        }

        var wait = timeout ?? DefaultActivateTimeout;
        Console.WriteLine(
            $"WindowsAppControl: activateApp(processName={processName}, windowName={windowName}, processId={processId})"
        );

        using var automation = new UIA3Automation();

        var window = Retry.WhileNull(
            () => TryFindWindow(automation, processName, windowName, processId),
            wait,
            interval: TimeSpan.FromMilliseconds(250),
            throwOnTimeout: false,
            ignoreException: true
        ).Result;

        if (window is null)
        {
            throw new InvalidOperationException(
                $"No window found to activate (processName={processName}, windowName={windowName}, processId={processId}) within {wait.TotalSeconds:0}s"
            );
        }

        window.Focus();
        window.SetForeground();
        Console.WriteLine($"WindowsAppControl: activated window \"{window.Name}\"");
    }

    /// <summary>
    /// Resolves a top-level window for scoping finds / activation.
    /// Scope fields are AND-ed; a given pid/processName does not fall through.
    /// </summary>
    internal static Window? TryFindWindow(
        UIA3Automation automation,
        string? processName,
        string? windowName,
        int? processId
    )
    {
        List<int> pids;
        if (processId is > 0)
        {
            try
            {
                if (Process.GetProcessById(processId.Value).HasExited)
                {
                    return null;
                }
            }
            catch (ArgumentException)
            {
                return null;
            }

            pids = [processId.Value];
        }
        else if (!string.IsNullOrWhiteSpace(processName))
        {
            pids = Process
                .GetProcessesByName(NormalizeProcessName(processName))
                .Where(p => !p.HasExited)
                .Select(p => p.Id)
                .ToList();
            if (pids.Count == 0)
            {
                return null;
            }
        }
        else if (!string.IsNullOrWhiteSpace(windowName))
        {
            return FindByTitle(automation, windowName!);
        }
        else
        {
            return null;
        }

        foreach (var pid in pids)
        {
            var window = FindForProcess(automation, pid, windowName);
            if (window is not null)
            {
                return window;
            }
        }

        return null;
    }

    private static Window? FindForProcess(
        UIA3Automation automation,
        int processId,
        string? windowName
    )
    {
        if (string.IsNullOrWhiteSpace(windowName))
        {
            try
            {
                var process = Process.GetProcessById(processId);
                if (!process.HasExited)
                {
                    var main = FlaUI.Core.Application.Attach(process)
                        .GetMainWindow(automation, TimeSpan.FromSeconds(2));
                    if (main is not null)
                    {
                        return main;
                    }
                }
            }
            catch
            {
                // Enumerate desktop windows below.
            }
        }

        Window? first = null;
        foreach (var el in automation.GetDesktop().FindAllChildren(cf =>
            cf.ByControlType(ControlType.Window)))
        {
            try
            {
                if (el.Properties.ProcessId.ValueOrDefault != processId)
                {
                    continue;
                }

                var window = el.AsWindow();
                if (!string.IsNullOrWhiteSpace(windowName))
                {
                    if (WindowNameMatches(window.Name, windowName))
                    {
                        return window;
                    }

                    continue;
                }

                first ??= window;
            }
            catch
            {
                // Skip inaccessible windows.
            }
        }

        return string.IsNullOrWhiteSpace(windowName) ? first : null;
    }

    private static Window? FindByTitle(UIA3Automation automation, string windowName)
    {
        var exact = automation.GetDesktop().FindAllChildren(cf =>
            cf.ByControlType(ControlType.Window).And(cf.ByName(windowName))
        );
        if (exact.Length > 0)
        {
            return exact[0].AsWindow();
        }

        foreach (var el in automation.GetDesktop().FindAllChildren(cf =>
            cf.ByControlType(ControlType.Window)))
        {
            if (WindowNameMatches(el.Name, windowName))
            {
                return el.AsWindow();
            }
        }

        return null;
    }

    private static bool WindowNameMatches(string? actual, string expected) =>
        !string.IsNullOrWhiteSpace(actual)
        && (actual.Equals(expected, StringComparison.OrdinalIgnoreCase)
            || actual.Contains(expected, StringComparison.OrdinalIgnoreCase));

    private static string NormalizeProcessName(string processName)
    {
        var name = processName.Trim();
        return name.EndsWith(".exe", StringComparison.OrdinalIgnoreCase)
            ? name[..^4]
            : name;
    }

    private static string? SafeProcessName(Process process)
    {
        try
        {
            return process.ProcessName;
        }
        catch
        {
            return null;
        }
    }
}
