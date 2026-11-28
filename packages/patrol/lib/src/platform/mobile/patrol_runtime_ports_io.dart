import 'dart:io' show InternetAddress, InternetAddressType, Platform;

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
  static int? _hostServerPort;
  static String? _nativeServerHost;

  static const _configuredNativeServerHost = String.fromEnvironment(
    'PATROL_HOST',
    defaultValue: 'localhost',
  );

  /// Resolves the Android native-server host without touching a method channel.
  ///
  /// Safe to call before the Flutter binding is initialized. Call it before
  /// the Live Patrol binding is installed so `main()` does not `await` after
  /// the binding and before `test()` / `group()` declarations (that ordering
  /// lets the test framework start with an empty suite).
  static Future<void> resolveNativeServerHost() async {
    if (!Platform.isAndroid ||
        _configuredNativeServerHost != 'localhost' ||
        _nativeServerHost != null) {
      return;
    }

    try {
      final addresses = await InternetAddress.lookup(
        _configuredNativeServerHost,
        type: InternetAddressType.IPv4,
      );
      if (addresses.isNotEmpty) {
        _nativeServerHost = addresses.first.address;
      }
    } on Object catch (error) {
      debugPrint('Failed to resolve Patrol native server host: $error');
    }
  }

  /// Loads ports from the native side.
  ///
  /// Must be called after the Flutter binding is initialized so the method
  /// channel handler is registered.
  ///
  /// This goes through the native `PatrolPlugin` method channel, which ships
  /// with `patrol` as a `dev_dependency`. On iOS/macOS that plugin is still
  /// registered in release builds only because Flutter temporarily includes
  /// Darwin `dev_dependencies` in all modes (flutter/flutter#171015,
  /// flutter/flutter#164133). If Flutter later switches to inclusionary
  /// registration and omits the plugin from release, [MissingPluginException]
  /// would land here. If that happens we fall back to default 8081/8082 ports,
  /// which still works for Patrol testing on a single device.
  ///
  /// Also runs [resolveNativeServerHost] so callers that only call this method
  /// still get the Android host cache.
  static Future<void> ensureLoaded() async {
    await resolveNativeServerHost();

    if (!(Platform.isIOS || Platform.isMacOS)) {
      return;
    }

    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        _methodGetRuntimePorts,
      );
      _testServerPort = _parsePort(result?['testServerPort']);
      _appServerPort = _parsePort(result?['appServerPort']);
      _hostServerPort = _parsePort(result?['hostServerPort']);
    } on Object catch (error) {
      debugPrint(
        'Failed to load Patrol runtime ports from the native side: $error',
      );
    }
  }

  /// The port `PatrolAppService` listens on in this Flutter engine, or null if
  /// it has not started yet.
  static int? boundAppServerPort;

  /// Port of the native Patrol automation server, or null if not injected.
  static int? testServerPort() => _testServerPort;

  /// Port of `PatrolAppService` inside the app under test, or null if not injected.
  static int? appServerPort() => _appServerPort;

  /// Port of the `patrol_cli` host server on iOS simulators, or null if not injected.
  static int? hostServerPort() => _hostServerPort;

  /// Address of the native automation server.
  ///
  /// On Android, `localhost` is resolved while the app is foregrounded and the
  /// numeric address is cached. This avoids a DNS lookup after another app has
  /// backgrounded the app under test, while preserving device-farm-specific
  /// localhost resolution.
  static String nativeServerHost() =>
      _nativeServerHost ?? _configuredNativeServerHost;

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
