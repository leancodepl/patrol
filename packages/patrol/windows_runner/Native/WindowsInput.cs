using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Patrol.WindowsRunner.Native;

internal static class WindowsInput
{
    private const uint MouseEventfLeftDown = 0x0002;
    private const uint MouseEventfLeftUp = 0x0004;

    public static void EnsureDpiAware()
    {
        // Best-effort; ignore failures on older hosts.
        SetProcessDpiAwarenessContext(DpiAwarenessContext.PerMonitorAwareV2);
    }

    public static void TapAtNormalized(double x, double y)
    {
        if (x is < 0 or > 1 || y is < 0 or > 1)
        {
            throw new ArgumentOutOfRangeException(
                paramName: null,
                message: string.Create(
                    System.Globalization.CultureInfo.InvariantCulture,
                    $"Normalized coordinates must be in [0,1], got ({x}, {y})"
                )
            );
        }

        var screen = Screen.PrimaryScreen
            ?? throw new InvalidOperationException("No primary screen available");

        var pixelX = screen.Bounds.Left + (int)Math.Round(x * (screen.Bounds.Width - 1));
        var pixelY = screen.Bounds.Top + (int)Math.Round(y * (screen.Bounds.Height - 1));

        if (!SetCursorPos(pixelX, pixelY))
        {
            throw new Win32Exception(Marshal.GetLastWin32Error(), $"SetCursorPos({pixelX}, {pixelY}) failed");
        }

        mouse_event(MouseEventfLeftDown, 0, 0, 0, UIntPtr.Zero);
        mouse_event(MouseEventfLeftUp, 0, 0, 0, UIntPtr.Zero);
    }

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool SetCursorPos(int x, int y);

    [DllImport("user32.dll")]
    private static extern void mouse_event(
        uint dwFlags,
        uint dx,
        uint dy,
        uint dwData,
        UIntPtr dwExtraInfo
    );

    [DllImport("user32.dll")]
    private static extern bool SetProcessDpiAwarenessContext(IntPtr value);

    private static class DpiAwarenessContext
    {
        public static readonly IntPtr PerMonitorAwareV2 = (IntPtr)(-4);
    }
}
