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
            () => FindWindow(automation, processName, windowName, processId),
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

    private static Window? FindWindow(
        UIA3Automation automation,
        string? processName,
        string? windowName,
        int? processId
    )
    {
        if (processId is > 0)
        {
            try
            {
                var process = Process.GetProcessById(processId.Value);
                if (!process.HasExited)
                {
                    var app = FlaUI.Core.Application.Attach(process);
                    var main = app.GetMainWindow(automation, TimeSpan.FromSeconds(2));
                    if (main is not null)
                    {
                        return main;
                    }
                }
            }
            catch
            {
                // Process may have exited (common with explorer.exe launcher).
            }
        }

        if (!string.IsNullOrWhiteSpace(processName))
        {
            var name = NormalizeProcessName(processName);
            foreach (var process in Process.GetProcessesByName(name))
            {
                try
                {
                    if (process.HasExited || process.MainWindowHandle == IntPtr.Zero)
                    {
                        continue;
                    }

                    var app = FlaUI.Core.Application.Attach(process);
                    var main = app.GetMainWindow(automation, TimeSpan.FromSeconds(1));
                    if (main is not null)
                    {
                        if (
                            string.IsNullOrWhiteSpace(windowName)
                            || WindowNameMatches(main.Name, windowName)
                        )
                        {
                            return main;
                        }
                    }
                }
                catch
                {
                    // Try next process.
                }
            }
        }

        if (!string.IsNullOrWhiteSpace(windowName))
        {
            var desktop = automation.GetDesktop();
            var matches = desktop.FindAllChildren(cf =>
                cf.ByControlType(ControlType.Window).And(cf.ByName(windowName!))
            );
            if (matches.Length > 0)
            {
                return matches[0].AsWindow();
            }

            // Partial title match (Explorer often uses folder name as title).
            matches = desktop.FindAllChildren(cf => cf.ByControlType(ControlType.Window));
            foreach (var el in matches)
            {
                if (WindowNameMatches(el.Name, windowName))
                {
                    return el.AsWindow();
                }
            }
        }

        return null;
    }

    private static bool WindowNameMatches(string? actual, string expected)
    {
        if (string.IsNullOrWhiteSpace(actual))
        {
            return false;
        }

        return actual.Equals(expected, StringComparison.OrdinalIgnoreCase)
            || actual.Contains(expected, StringComparison.OrdinalIgnoreCase);
    }

    private static string NormalizeProcessName(string processName)
    {
        var name = processName.Trim();
        if (name.EndsWith(".exe", StringComparison.OrdinalIgnoreCase))
        {
            name = name[..^4];
        }

        return name;
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
