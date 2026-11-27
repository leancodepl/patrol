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

/// Finder for desktop UI Automation elements on Windows.
///
/// Selector fields are AND-ed. Provide at least one of [name], [automationId],
/// or [className]. Optional [index] picks among matches (0-based).
class WindowsSelector {
  /// Creates a [WindowsSelector].
  const WindowsSelector({
    this.name,
    this.automationId,
    this.className,
    this.index,
  });

  /// UIA Name.
  final String? name;

  /// UIA AutomationId.
  final String? automationId;

  /// UIA ClassName.
  final String? className;

  /// 0-based index among matches.
  final int? index;

  /// Ensures at least one identifying field is set and [index] is valid.
  void validate() {
    final hasName = name != null && name!.isNotEmpty;
    final hasId = automationId != null && automationId!.isNotEmpty;
    final hasClass = className != null && className!.isNotEmpty;
    if (!hasName && !hasId && !hasClass) {
      throw ArgumentError(
        'Provide at least one of name, automationId, or className',
      );
    }
    if (index != null && index! < 0) {
      throw ArgumentError.value(index, 'index', 'must be >= 0');
    }
  }

  /// JSON body fields understood by the Windows automator sidecar.
  Map<String, dynamic> toJson() {
    validate();
    return <String, dynamic>{
      if (name != null && name!.isNotEmpty) 'name': name,
      if (automationId != null && automationId!.isNotEmpty)
        'automationId': automationId,
      if (className != null && className!.isNotEmpty) 'className': className,
      if (index != null) 'index': index,
    };
  }

  @override
  String toString() {
    final parts = <String>[
      if (name != null && name!.isNotEmpty) 'name: $name',
      if (automationId != null && automationId!.isNotEmpty)
        'automationId: $automationId',
      if (className != null && className!.isNotEmpty) 'className: $className',
      if (index != null) 'index: $index',
    ];
    return 'WindowsSelector(${parts.join(', ')})';
  }
}

/// Windows-specific OS automation (experimental).
///
/// Drives desktop UI outside the Flutter window through an out-of-process
/// Windows automator sidecar over HTTP/JSON (UI Automation). Use Flutter
/// finders for widgets inside your app.
///
/// See `packages/patrol/windows_runner/PROTOCOL.md` for the wire contract.
abstract interface class WindowsAutomator {
  /// Configuration used by this automator.
  WindowsAutomatorConfig get config;

  /// Tells the Windows runner that PatrolAppService is ready.
  Future<void> markPatrolAppServiceReady();

  /// Taps at normalized primary-screen coordinates in the range `[0, 1]`.
  Future<void> tapAt(Offset point);

  /// Taps a matching desktop UI element.
  ///
  /// Defaults to [WindowsAutomatorConfig.findTimeout] when [timeout] is omit-
  /// ted.
  Future<void> tap(WindowsSelector selector, {Duration? timeout});

  /// Double-taps / double-invokes a matching desktop UI element.
  Future<void> doubleTap(WindowsSelector selector, {Duration? timeout});

  /// Waits until a matching desktop UI element exists.
  ///
  /// Defaults to [WindowsAutomatorConfig.findTimeout] when [timeout] is omit-
  /// ted. [WindowsAutomatorConfig.connectionTimeout] must be longer than the
  /// effective find timeout.
  Future<void> waitUntilVisible(
    WindowsSelector selector, {
    Duration? timeout,
  });

  /// Returns whether a matching desktop UI element currently exists.
  ///
  /// When [timeout] is omitted the sidecar uses a short poll (~500 ms). Pass
  /// an explicit [timeout] to wait longer for the element to appear.
  Future<bool> isElementVisible(
    WindowsSelector selector, {
    Duration? timeout,
  });

  /// Finds a matching desktop UI element, or `null` if none within [timeout].
  Future<WindowsUiElement?> findElement(
    WindowsSelector selector, {
    Duration? timeout,
  });

  /// Finds all matching desktop UI elements (waits up to [timeout] for any).
  Future<List<WindowsUiElement>> findElements(
    WindowsSelector selector, {
    Duration? timeout,
  });

  /// Sets the text of a matching desktop edit control.
  Future<void> enterText(
    WindowsSelector selector, {
    required String text,
    Duration? timeout,
  });

  /// Presses a virtual-key code, optionally with modifiers.
  ///
  /// Prefer `WindowsKey` constants instead of raw hex, e.g.
  /// `pressKey(WindowsKey.enter)` or `pressKey(WindowsKey.h, shift: true)`.
  ///
  /// [keyCode] is a Win32 virtual-key code.
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
