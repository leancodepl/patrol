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

  @override
  Future<void> markPatrolAppServiceReady() {
    throw UnsupportedError('Windows automator is not available on this platform');
  }

  @override
  Future<void> tapAt(Offset point) {
    throw UnsupportedError('Windows automator is not available on this platform');
  }

  @override
  Future<void> tap({String? name, String? automationId}) {
    throw UnsupportedError('Windows automator is not available on this platform');
  }

  @override
  Future<void> waitUntilVisible({String? name, String? automationId}) {
    throw UnsupportedError('Windows automator is not available on this platform');
  }

  @override
  Future<void> enterText(
    String text, {
    String? name,
    String? automationId,
  }) {
    throw UnsupportedError('Windows automator is not available on this platform');
  }
}
