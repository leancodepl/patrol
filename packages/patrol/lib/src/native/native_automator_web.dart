import 'package:flutter_test/flutter_test.dart';
// Web stub does not use patrol_log to minimize surface area.

/// Web stub: mirrors the public API used by Patrol without native features.
class NativeAutomatorConfig {
  const NativeAutomatorConfig({
    this.host = 'localhost',
    this.port = '8081',
    this.packageName = '',
    this.iosInstalledApps = '',
    this.bundleId = '',
    this.androidAppName = '',
    this.iosAppName = '',
    this.connectionTimeout = const Duration(seconds: 60),
    this.findTimeout = const Duration(seconds: 10),
    this.keyboardBehavior = KeyboardBehavior.showAndDismiss,
    this.logger = _defaultPrintLogger,
  });

  final String iosInstalledApps;
  final String host;
  final String port;
  final Duration connectionTimeout;
  final Duration findTimeout;
  final KeyboardBehavior keyboardBehavior;
  final String packageName;
  final String bundleId;
  final String androidAppName;
  final String iosAppName;
  final void Function(String) logger;

  NativeAutomatorConfig copyWith({
    String? host,
    String? port,
    String? packageName,
    String? bundleId,
    String? androidAppName,
    String? iosAppName,
    Duration? connectionTimeout,
    Duration? findTimeout,
    KeyboardBehavior? keyboardBehavior,
    void Function(String)? logger,
  }) {
    return NativeAutomatorConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      packageName: packageName ?? this.packageName,
      bundleId: bundleId ?? this.bundleId,
      androidAppName: androidAppName ?? this.androidAppName,
      iosAppName: iosAppName ?? this.iosAppName,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      findTimeout: findTimeout ?? this.findTimeout,
      keyboardBehavior: keyboardBehavior ?? this.keyboardBehavior,
      logger: logger ?? this.logger,
    );
  }
}

enum KeyboardBehavior { showAndDismiss, alternative }

void _defaultPrintLogger(String message) {
  // ignore: avoid_print
  print('Patrol (native web stub): $message');
}

/// Web stub for NativeAutomator – all methods are no-ops.
class NativeAutomator {
  NativeAutomator({required NativeAutomatorConfig config}) : _config = config;

  final NativeAutomatorConfig _config;

  Future<void> initialize() async {}
  Future<void> configure() async {}
  Future<void> markPatrolAppServiceReady() async {}

  Future<void> pressHome() async {}
  Future<void> pressBack() async {}
  Future<void> pressRecentApps() async {}
  Future<void> pressDoubleRecentApps() async {}

  Future<void> openNotifications() async {}
  Future<void> closeNotifications() async {}
  Future<void> openQuickSettings() async {}
  Future<void> openUrl(String url) async {}

  Future<void> tapAt(Offset location, {String? appId}) async {}
  Future<void> swipe({
    required Offset from,
    required Offset to,
    int steps = 12,
    String? appId,
    bool enablePatrolLog = true,
  }) async {}
  Future<void> swipeBack({double dy = 0.5, String? appId}) async {}
  Future<void> pullToRefresh({
    Offset from = const Offset(0.5, 0.5),
    Offset to = const Offset(0.5, 0.9),
    int steps = 50,
  }) async {}
}
