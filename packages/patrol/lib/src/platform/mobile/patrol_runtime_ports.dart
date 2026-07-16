import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads Patrol HTTP ports injected by the native test runner.
///
/// On iOS/macOS, XCTest sets ports in `XCUIApplication.launchEnvironment`.
/// Flutter does not expose that to Dart [Platform.environment], so ports are
/// read from native `ProcessInfo` over a method channel.
class PatrolRuntimePorts {
  PatrolRuntimePorts._();

  static const _channel = MethodChannel('pl.leancode.patrol/main');
  static const _methodGetRuntimePorts = 'getRuntimePorts';

  static int? _testServerPort;
  static int? _appServerPort;

  /// Loads ports from the native side.
  ///
  /// Must be called after the Flutter binding is initialized so the method
  /// channel handler is registered.
  static Future<void> ensureLoaded() async {
    if (kIsWeb || !(Platform.isIOS || Platform.isMacOS)) {
      return;
    }

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        _methodGetRuntimePorts,
      );
      _testServerPort = _parsePort(result?['testServerPort']);
      _appServerPort = _parsePort(result?['appServerPort']);
    } on Object catch (error) {
      debugPrint(
        'Failed to load Patrol runtime ports from the native side: $error',
      );
    }
  }

  /// Port of the native Patrol automation server, or null if not injected.
  static int? testServerPort() => _testServerPort;

  /// Port of `PatrolAppService` inside the app under test, or null if not injected.
  static int? appServerPort() => _appServerPort;

  static int? _parsePort(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
