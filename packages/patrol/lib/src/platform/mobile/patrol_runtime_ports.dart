import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Reads Patrol HTTP ports injected by the native test runner via
/// [XCUIApplication.launchArguments].
class PatrolRuntimePorts {
  PatrolRuntimePorts._();

  static const _testServerPortKey = 'PATROL_TEST_SERVER_PORT';
  static const _appServerPortKey = 'PATROL_APP_SERVER_PORT';

  /// Port of the native Patrol automation server, or null if not injected.
  static int? testServerPort() => _readLaunchArgInt(_testServerPortKey);

  /// Port of [PatrolAppService] inside the app under test, or null if not injected.
  static int? appServerPort() => _readLaunchArgInt(_appServerPortKey);

  static int? _readLaunchArgInt(String key) {
    if (kIsWeb || !(Platform.isIOS || Platform.isMacOS)) {
      return null;
    }

    final prefix = '--$key=';
    for (final arg in Platform.executableArguments) {
      if (arg.startsWith(prefix)) {
        return int.tryParse(arg.substring(prefix.length));
      }
    }
    return null;
  }
}
