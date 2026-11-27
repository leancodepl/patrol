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

enum _WindowsScopeKind { targeted, appUnderTest, desktop }

/// Root for desktop UI Automation finds.
///
/// Find-based actions default to [WindowsScope.appUnderTest] (the Flutter
/// process running the test). Override with a targeted scope for another
/// window/process, or with [WindowsScope.desktop] for a full-desktop search.
class WindowsScope {
  /// Creates a scope for a specific process and/or window title.
  ///
  /// Provide at least one of [processId], [processName], or [windowName].
  const WindowsScope({this.processId, this.processName, this.windowName})
    : _kind = _WindowsScopeKind.targeted;

  const WindowsScope._appUnderTest()
    : processId = null,
      processName = null,
      windowName = null,
      _kind = _WindowsScopeKind.appUnderTest;

  const WindowsScope._desktop()
    : processId = null,
      processName = null,
      windowName = null,
      _kind = _WindowsScopeKind.desktop;

  /// Scope finds to the Flutter app under test (this process).
  ///
  /// This is the default when [WindowsSelector.within] is omitted.
  static const appUnderTest = WindowsScope._appUnderTest();

  /// Search the entire desktop (no process/window root).
  ///
  /// Use for rare cases where the default app scope is too narrow and you
  /// do not have a better [processId] / [windowName] yet.
  static const desktop = WindowsScope._desktop();

  final _WindowsScopeKind _kind;

  /// OS process id of the target app.
  final int? processId;

  /// Process name (with or without `.exe`), e.g. `notepad` or `explorer`.
  final String? processName;

  /// Top-level window title (exact or substring, case-insensitive).
  final String? windowName;

  /// Whether this scope means the Flutter app under test.
  bool get isAppUnderTest => _kind == _WindowsScopeKind.appUnderTest;

  /// Whether this scope means an unscoped desktop search.
  bool get isDesktop => _kind == _WindowsScopeKind.desktop;

  /// Ensures a targeted scope has at least one identifying field.
  void validate() {
    if (_kind != _WindowsScopeKind.targeted) {
      return;
    }
    final hasPid = processId != null && processId! > 0;
    final hasProcess = processName != null && processName!.isNotEmpty;
    final hasWindow = windowName != null && windowName!.isNotEmpty;
    if (!hasPid && !hasProcess && !hasWindow) {
      throw ArgumentError(
        'Provide at least one of processId, processName, or windowName',
      );
    }
  }

  /// JSON `within` object for a targeted scope.
  ///
  /// Not used for [appUnderTest] / [desktop] — the native client resolves
  /// those when building the request.
  Map<String, dynamic> toJson() {
    validate();
    if (_kind != _WindowsScopeKind.targeted) {
      throw StateError(
        'Only targeted WindowsScope values can be serialized directly',
      );
    }
    return <String, dynamic>{
      if (processId != null && processId! > 0) 'processId': processId,
      if (processName != null && processName!.isNotEmpty)
        'processName': processName,
      if (windowName != null && windowName!.isNotEmpty)
        'windowName': windowName,
    };
  }

  @override
  String toString() {
    return switch (_kind) {
      _WindowsScopeKind.appUnderTest => 'WindowsScope.appUnderTest',
      _WindowsScopeKind.desktop => 'WindowsScope.desktop',
      _WindowsScopeKind.targeted => () {
        final parts = <String>[
          if (processId != null && processId! > 0) 'processId: $processId',
          if (processName != null && processName!.isNotEmpty)
            'processName: $processName',
          if (windowName != null && windowName!.isNotEmpty)
            'windowName: $windowName',
        ];
        return 'WindowsScope(${parts.join(', ')})';
      }(),
    };
  }
}

/// Finder for desktop UI Automation elements on Windows.
///
/// Selector fields are AND-ed. Provide at least one of [name], [automationId],
/// or [className]. Optional [index] picks among matches (0-based).
///
/// When [within] is omitted, finds default to [WindowsScope.appUnderTest].
/// Pass [WindowsScope.desktop] or a targeted [WindowsScope] to override.
class WindowsSelector {
  /// Creates a [WindowsSelector].
  const WindowsSelector({
    this.name,
    this.automationId,
    this.className,
    this.index,
    this.within,
  });

  /// UIA Name.
  final String? name;

  /// UIA AutomationId.
  final String? automationId;

  /// UIA ClassName.
  final String? className;

  /// 0-based index among matches.
  final int? index;

  /// Search root. Defaults to [WindowsScope.appUnderTest] when omitted.
  final WindowsScope? within;

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
    within?.validate();
  }

  /// JSON body fields for the element identity (no resolved scope).
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
      'within: ${within ?? WindowsScope.appUnderTest}',
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

  /// Waits until a matching desktop UI element exists.
  ///
  /// Defaults to [WindowsAutomatorConfig.findTimeout] when [timeout] is omit-
  /// ted. [WindowsAutomatorConfig.connectionTimeout] must be longer than the
  /// effective find timeout.
  Future<void> waitUntilVisible(WindowsSelector selector, {Duration? timeout});

  /// Returns whether a matching desktop UI element currently exists.
  ///
  /// When [timeout] is omitted the sidecar uses a short poll (~500 ms). Pass
  /// an explicit [timeout] to wait longer for the element to appear.
  Future<bool> isElementVisible(WindowsSelector selector, {Duration? timeout});

  /// Finds a matching desktop UI element, or `null` if none within [timeout].
  Future<WindowsUiElement?> findElement(
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
