import 'package:flutter/painting.dart';
import 'package:patrol/src/platform/windows/windows_automator.dart'
    as windows_automator;
import 'package:patrol/src/platform/windows/windows_automator_config.dart';

/// Stub [WindowsAutomator] used when not compiling for a Windows IO target.
class WindowsAutomator implements windows_automator.WindowsAutomator {
  /// Creates a new [WindowsAutomator].
  WindowsAutomator({required WindowsAutomatorConfig config}) : _config = config;

  final WindowsAutomatorConfig _config;

  @override
  WindowsAutomatorConfig get config => _config;

  Future<T> _unsupported<T>() {
    throw UnsupportedError(
      'Windows automator is not available on this platform',
    );
  }

  @override
  Future<void> markPatrolAppServiceReady() => _unsupported();

  @override
  Future<void> tapAt(Offset point) => _unsupported();

  @override
  Future<void> tap(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) => _unsupported();

  @override
  Future<void> waitUntilVisible(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) => _unsupported();

  @override
  Future<bool> isElementVisible(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) => _unsupported();

  @override
  Future<windows_automator.WindowsUiElement?> findElement(
    windows_automator.WindowsSelector selector, {
    Duration? timeout,
  }) => _unsupported();

  @override
  Future<void> enterText(
    windows_automator.WindowsSelector selector, {
    required String text,
    Duration? timeout,
  }) => _unsupported();

  @override
  Future<void> pressKey(
    int keyCode, {
    bool shift = false,
    bool ctrl = false,
    bool alt = false,
  }) => _unsupported();

  @override
  Future<int> launchApp({
    required String appPath,
    String? arguments,
    bool activate = true,
  }) => _unsupported();

  @override
  Future<void> activateApp({
    String? processName,
    String? windowName,
    int? processId,
  }) => _unsupported();
}
