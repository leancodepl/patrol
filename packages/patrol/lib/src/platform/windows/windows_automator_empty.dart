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
  Future<void> tap({
    String? name,
    String? automationId,
    String? className,
    int? index,
  }) =>
      _unsupported();

  @override
  Future<void> doubleTap({
    String? name,
    String? automationId,
    String? className,
    int? index,
  }) =>
      _unsupported();

  @override
  Future<void> waitUntilVisible({
    String? name,
    String? automationId,
    String? className,
    int? index,
  }) =>
      _unsupported();

  @override
  Future<bool> isElementVisible({
    String? name,
    String? automationId,
    String? className,
    int? index,
  }) =>
      _unsupported();

  @override
  Future<windows_automator.WindowsUiElement?> findElement({
    String? name,
    String? automationId,
    String? className,
    int? index,
  }) =>
      _unsupported();

  @override
  Future<List<windows_automator.WindowsUiElement>> findElements({
    String? name,
    String? automationId,
    String? className,
  }) =>
      _unsupported();

  @override
  Future<void> enterText(
    String text, {
    String? name,
    String? automationId,
    String? className,
    int? index,
  }) =>
      _unsupported();

  @override
  Future<void> pressKey(
    int keyCode, {
    bool shift = false,
    bool ctrl = false,
    bool alt = false,
  }) =>
      _unsupported();
}
