using System.Drawing;
using System.Globalization;
using System.Windows.Forms;

namespace Patrol.WindowsFixture;

/// <summary>
/// Demo "native desktop dialog" — a second process outside Flutter
/// that Patrol drives via UI Automation (Name / AutomationId).
/// </summary>
internal static class Program
{
    public const int WindowLeft = 520;
    public const int WindowTop = 120;
    public const int WindowWidth = 420;
    public const int WindowHeight = 280;

    public const string DialogTitle = "Windows Security Prompt";
    public const string ApproveButtonName = "Allow access";
    public const string ApproveButtonAutomationId = "poc_allow_button";
    public const string NameFieldAutomationId = "poc_identity_field";

    public static string MarkerPath =>
        Path.Combine(Path.GetTempPath(), "patrol_windows_poc_clicked.txt");

    public static string TextMarkerPath =>
        Path.Combine(Path.GetTempPath(), "patrol_windows_poc_text.txt");

    public static string TargetPath =>
        Path.Combine(Path.GetTempPath(), "patrol_windows_poc_target.txt");

    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);

        foreach (var path in new[] { MarkerPath, TextMarkerPath, TargetPath })
        {
            if (File.Exists(path))
            {
                File.Delete(path);
            }
        }

        var form = new Form
        {
            Text = DialogTitle,
            StartPosition = FormStartPosition.Manual,
            Location = new Point(WindowLeft, WindowTop),
            ClientSize = new Size(WindowWidth, WindowHeight),
            FormBorderStyle = FormBorderStyle.FixedDialog,
            MaximizeBox = false,
            MinimizeBox = false,
            TopMost = true,
            BackColor = Color.FromArgb(250, 250, 252),
        };

        var header = new Label
        {
            Text = "Flutter app is requesting access",
            AutoSize = false,
            Dock = DockStyle.Top,
            Height = 48,
            Padding = new Padding(16, 14, 16, 8),
            Font = new Font("Segoe UI", 12, FontStyle.Bold),
        };

        var body = new Label
        {
            Text =
                "This window is a separate Win32 process — not Flutter.\n"
                + "Patrol will find it with UI Automation, type an identity,\n"
                + "then click Allow access.",
            AutoSize = false,
            Dock = DockStyle.Top,
            Height = 72,
            Padding = new Padding(16, 0, 16, 8),
            Font = new Font("Segoe UI", 9),
        };

        var nameLabel = new Label
        {
            Text = "Identity",
            Dock = DockStyle.Top,
            Height = 22,
            Padding = new Padding(16, 4, 16, 0),
            Font = new Font("Segoe UI", 9, FontStyle.Bold),
        };

        var textBox = new TextBox
        {
            Name = NameFieldAutomationId,
            Dock = DockStyle.Top,
            Height = 32,
            Margin = new Padding(16),
            Font = new Font("Segoe UI", 11),
        };
        // Padding via a host panel looks better
        var textHost = new Panel
        {
            Dock = DockStyle.Top,
            Height = 44,
            Padding = new Padding(16, 4, 16, 8),
        };
        textBox.Dock = DockStyle.Fill;
        textHost.Controls.Add(textBox);
        textBox.TextChanged += (_, _) =>
            File.WriteAllText(TextMarkerPath, textBox.Text);

        var button = new Button
        {
            Name = ApproveButtonAutomationId,
            Text = ApproveButtonName,
            Dock = DockStyle.Bottom,
            Height = 52,
            Font = new Font("Segoe UI", 12, FontStyle.Bold),
            BackColor = Color.FromArgb(0, 99, 177),
            ForeColor = Color.White,
            FlatStyle = FlatStyle.Flat,
        };
        button.FlatAppearance.BorderSize = 0;
        button.Click += (_, _) =>
        {
            File.WriteAllText(
                MarkerPath,
                string.Create(
                    CultureInfo.InvariantCulture,
                    $"allowed:{textBox.Text}:{DateTime.UtcNow:O}"
                )
            );
            button.Text = "Access granted";
            button.BackColor = Color.FromArgb(16, 124, 16);
            header.Text = "Access allowed — native step complete";
        };

        form.Controls.Add(button);
        form.Controls.Add(textHost);
        form.Controls.Add(nameLabel);
        form.Controls.Add(body);
        form.Controls.Add(header);

        form.Shown += (_, _) => WriteNormalizedButtonCenter(button);

        Application.Run(form);
    }

    private static void WriteNormalizedButtonCenter(Button button)
    {
        var screen =
            Screen.PrimaryScreen
            ?? throw new InvalidOperationException("No primary screen");
        var center = button.PointToScreen(
            new Point(button.ClientSize.Width / 2, button.ClientSize.Height / 2)
        );
        var normalizedX =
            (center.X - screen.Bounds.Left) / (double)Math.Max(1, screen.Bounds.Width - 1);
        var normalizedY =
            (center.Y - screen.Bounds.Top) / (double)Math.Max(1, screen.Bounds.Height - 1);
        File.WriteAllText(
            TargetPath,
            string.Create(
                CultureInfo.InvariantCulture,
                $"{normalizedX:R},{normalizedY:R}"
            )
        );
    }
}
