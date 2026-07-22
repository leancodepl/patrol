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
        TapAtPixels(pixelX, pixelY);
    }

    public static void TapAtPixels(int pixelX, int pixelY)
    {
        if (!SetCursorPos(pixelX, pixelY))
        {
            throw new Win32Exception(
                Marshal.GetLastWin32Error(),
                $"SetCursorPos({pixelX}, {pixelY}) failed"
            );
        }

        mouse_event(MouseEventfLeftDown, 0, 0, 0, UIntPtr.Zero);
        mouse_event(MouseEventfLeftUp, 0, 0, 0, UIntPtr.Zero);
    }

    public static void PressKey(
        int keyCode,
        bool shift = false,
        bool ctrl = false,
        bool alt = false
    )
    {
        if (keyCode is < 1 or > 254)
        {
            throw new ArgumentOutOfRangeException(
                nameof(keyCode),
                keyCode,
                "Virtual-key code must be in 1..254"
            );
        }

        var inputs = new List<INPUT>(8);
        void Down(ushort vk) =>
            inputs.Add(
                new INPUT
                {
                    type = InputKeyboard,
                    U = new InputUnion
                    {
                        ki = new KEYBDINPUT { wVk = vk, dwFlags = 0 },
                    },
                }
            );
        void Up(ushort vk) =>
            inputs.Add(
                new INPUT
                {
                    type = InputKeyboard,
                    U = new InputUnion
                    {
                        ki = new KEYBDINPUT { wVk = vk, dwFlags = KeyeventfKeyup },
                    },
                }
            );

        if (ctrl)
        {
            Down(VkControl);
        }

        if (shift)
        {
            Down(VkShift);
        }

        if (alt)
        {
            Down(VkMenu);
        }

        Down((ushort)keyCode);
        Up((ushort)keyCode);

        if (alt)
        {
            Up(VkMenu);
        }

        if (shift)
        {
            Up(VkShift);
        }

        if (ctrl)
        {
            Up(VkControl);
        }

        var arr = inputs.ToArray();
        var sent = SendInput((uint)arr.Length, arr, INPUT.Size);
        if (sent != arr.Length)
        {
            throw new Win32Exception(Marshal.GetLastWin32Error(), "SendInput(pressKey) failed");
        }
    }

    private const uint InputKeyboard = 1;
    private const uint KeyeventfKeyup = 0x0002;
    private const ushort VkShift = 0x10;
    private const ushort VkControl = 0x11;
    private const ushort VkMenu = 0x12;

    [StructLayout(LayoutKind.Sequential)]
    private struct INPUT
    {
        public uint type;
        public InputUnion U;
        public static int Size => Marshal.SizeOf<INPUT>();
    }

    // Union must be sized like MOUSEINPUT on x64 or SendInput returns ERROR_INVALID_PARAMETER.
    [StructLayout(LayoutKind.Explicit)]
    private struct InputUnion
    {
        [FieldOffset(0)]
        public MOUSEINPUT mi;

        [FieldOffset(0)]
        public KEYBDINPUT ki;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MOUSEINPUT
    {
        public int dx;
        public int dy;
        public uint mouseData;
        public uint dwFlags;
        public uint time;
        public UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct KEYBDINPUT
    {
        public ushort wVk;
        public ushort wScan;
        public uint dwFlags;
        public uint time;
        public UIntPtr dwExtraInfo;
    }

    [DllImport("user32.dll", SetLastError = true)]
    private static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

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
