import 'package:flutter/painting.dart';
import 'package:patrol/src/platform/windows/windows_automator_config.dart';

/// Snapshot of a desktop UI Automation element.
class WindowsUiElement {
  /// Creates a [WindowsUiElement].
  const WindowsUiElement({
    this.name,
    this.className,
    this.automationId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Creates a [WindowsUiElement] from a JSON map returned by the runner.
  factory WindowsUiElement.fromJson(Map<String, dynamic> json) {
    return WindowsUiElement(
      name: json['name'] as String?,
      className: json['className'] as String?,
      automationId: json['automationId'] as String?,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  /// UIA Name.
  final String? name;

  /// UIA ClassName.
  final String? className;

  /// UIA AutomationId.
  final String? automationId;

  /// Left edge in screen pixels.
  final double x;

  /// Top edge in screen pixels.
  final double y;

  /// Width in screen pixels.
  final double width;

  /// Height in screen pixels.
  final double height;
}

/// Windows-specific OS automation (experimental).
///
/// Coordinate taps plus UI Automation actions via FlaUI.UIA3 in the Windows
/// runner. Intended for UI outside the Flutter window; use Flutter finders for
/// widgets inside your app.
///
/// Selector fields ([name], [automationId], [className]) are AND-ed. Provide
/// at least one. Optional [index] picks among matches (0-based).
abstract interface class WindowsAutomator {
  /// Configuration used by this automator.
  WindowsAutomatorConfig get config;

  /// Tells the Windows runner that PatrolAppService is ready.
  Future<void> markPatrolAppServiceReady();

  /// Taps at normalized primary-screen coordinates in the range `[0, 1]`.
  Future<void> tapAt(Offset point);

  /// Taps a matching desktop UI element.
  Future<void> tap({
    String? name,
    String? automationId,
    String? className,
    int? index,
  });

  /// Double-taps / double-invokes a matching desktop UI element.
  Future<void> doubleTap({
    String? name,
    String? automationId,
    String? className,
    int? index,
  });

  /// Waits until a matching desktop UI element exists.
  Future<void> waitUntilVisible({
    String? name,
    String? automationId,
    String? className,
    int? index,
  });

  /// Returns whether a matching desktop UI element currently exists.
  Future<bool> isElementVisible({
    String? name,
    String? automationId,
    String? className,
    int? index,
  });

  /// Finds a matching desktop UI element, or `null` if none.
  Future<WindowsUiElement?> findElement({
    String? name,
    String? automationId,
    String? className,
    int? index,
  });

  /// Finds all matching desktop UI elements.
  Future<List<WindowsUiElement>> findElements({
    String? name,
    String? automationId,
    String? className,
  });

  /// Sets the text of a matching desktop edit control.
  Future<void> enterText(
    String text, {
    String? name,
    String? automationId,
    String? className,
    int? index,
  });

  /// Presses a virtual-key code, optionally with modifiers.
  ///
  /// [keyCode] is a Win32 virtual-key code (e.g. `0x41` for A, `0x0D` for Enter).
  Future<void> pressKey(
    int keyCode, {
    bool shift = false,
    bool ctrl = false,
    bool alt = false,
  });

  /// Launches a desktop app by executable path or name (e.g. `explorer.exe`).
  ///
  /// Returns the OS process id when available. Some apps (notably Explorer)
  /// may reuse an existing shell process.
  Future<int> launchApp({
    required String appPath,
    String? arguments,
    bool activate = true,
  });

  /// Brings an already-running app window to the foreground.
  ///
  /// Provide at least one of [processName], [windowName], or [processId].
  Future<void> activateApp({
    String? processName,
    String? windowName,
    int? processId,
  });
}
