import 'package:flutter/painting.dart';
import 'package:patrol/src/platform/windows/windows_automator_config.dart';

/// Windows-specific OS automation (experimental).
///
/// Coordinate taps plus Name / AutomationId actions via UI Automation
/// (FlaUI.UIA3 in the Windows runner). Intended for UI outside the Flutter
/// window; use Flutter finders for widgets inside your app.
abstract interface class WindowsAutomator {
  /// Configuration used by this automator.
  WindowsAutomatorConfig get config;

  /// Tells the Windows runner that PatrolAppService is ready.
  Future<void> markPatrolAppServiceReady();

  /// Taps at normalized primary-screen coordinates in the range `[0, 1]`.
  ///
  /// `(0, 0)` is the top-left of the primary display; `(1, 1)` is the
  /// bottom-right.
  Future<void> tapAt(Offset point);

  /// Taps the first matching desktop UI element.
  ///
  /// Provide exactly one of [name] (UIA Name) or [automationId].
  Future<void> tap({String? name, String? automationId});

  /// Waits until a matching desktop UI element exists.
  ///
  /// Provide exactly one of [name] or [automationId].
  Future<void> waitUntilVisible({String? name, String? automationId});

  /// Sets the text of a matching desktop edit control.
  ///
  /// Provide exactly one of [name] or [automationId].
  Future<void> enterText(
    String text, {
    String? name,
    String? automationId,
  });
}
