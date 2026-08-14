import 'package:meta/meta.dart';
import 'package:patrol/src/platform/macos/macos_automator_config.dart';
import 'package:patrol/src/platform/selector.dart' show IOSSelector;

/// Provides functionality to interact with native macOS UI that Flutter cannot
/// see (alerts, menu bar, system dialogs, and other AppKit / system views).
///
/// Communicates over HTTP with the native automation server running in the
/// macOS UI test process.
abstract interface class MacOSAutomator {
  /// Returns the bundle identifier of the app under test.
  String get resolvedAppId;

  /// Configures the native automator.
  ///
  /// Must be called before using any native features.
  Future<void> configure();

  /// Tells the native runner that PatrolAppService is ready to answer requests
  /// about the structure of Dart tests.
  @internal
  Future<void> markPatrolAppServiceReady();

  /// Taps on the native view specified by [selector].
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [MacOSAutomatorConfig.findTimeout] duration from the configuration.
  /// If the native view is not found, an exception is thrown.
  Future<void> tap(IOSSelector selector, {String? appId, Duration? timeout});

  /// Waits until the native view specified by [selector] becomes visible.
  ///
  /// It waits for the view to become visible for [timeout] duration. If
  /// [timeout] is not specified, it utilizes the
  /// [MacOSAutomatorConfig.findTimeout].
  Future<void> waitUntilVisible(
    IOSSelector selector, {
    String? appId,
    Duration? timeout,
  });

  /// Returns whether a native alert, dialog, or sheet is visible.
  Future<bool> isAlertVisible({Duration? timeout});

  /// Taps a button on the currently visible native alert / dialog / sheet.
  ///
  /// [label] is the button title, e.g. `OK` or `Cancel`.
  Future<void> tapAlertButton(
    String label, {
    String? appId,
    Duration? timeout,
  });
}
