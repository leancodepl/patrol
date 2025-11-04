import 'package:patrol/src/platform/android/android_automator.dart';
import 'package:patrol/src/platform/android/contracts/contracts.dart';

void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}

/// Configuration for [AndroidAutomator].
class AndroidAutomatorConfig {
  /// Creates a new [AndroidAutomatorConfig].
  const AndroidAutomatorConfig({
    this.host = const String.fromEnvironment(
      'PATROL_HOST',
      defaultValue: 'localhost',
    ),
    this.port = const String.fromEnvironment(
      'PATROL_TEST_SERVER_PORT',
      defaultValue: '8081',
    ),
    this.packageName = const String.fromEnvironment('PATROL_APP_PACKAGE_NAME'),
    this.appName = const String.fromEnvironment('PATROL_ANDROID_APP_NAME'),
    this.connectionTimeout = const Duration(seconds: 60),
    this.findTimeout = const Duration(seconds: 10),
    this.keyboardBehavior = KeyboardBehavior.showAndDismiss,
    this.logger = _defaultPrintLogger,
  });

  /// Host on which Patrol server instrumentation is running.
  final String host;

  /// Port on [host] on which Patrol server instrumentation is running.
  final String port;

  /// Time after which the connection with the native automator will fail.
  ///
  /// It must be longer than [findTimeout].
  final Duration connectionTimeout;

  /// Time to wait for native views to appear.
  final Duration findTimeout;

  /// How the keyboard should behave when entering text.
  ///
  /// See [KeyboardBehavior] to learn more.
  final KeyboardBehavior keyboardBehavior;

  /// Package name of the application under test.
  ///
  /// Android only.
  final String packageName;

  /// Name of the application under test on Android.
  final String appName;

  /// Called when a native action is performed.
  final void Function(String) logger;

  /// Creates a copy of this config but with the given fields replaced with the
  /// new values.
  AndroidAutomatorConfig copyWith({
    String? host,
    String? port,
    String? packageName,
    String? appName,
    Duration? connectionTimeout,
    Duration? findTimeout,
    KeyboardBehavior? keyboardBehavior,
    void Function(String)? logger,
  }) {
    return AndroidAutomatorConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      findTimeout: findTimeout ?? this.findTimeout,
      keyboardBehavior: keyboardBehavior ?? this.keyboardBehavior,
      logger: logger ?? this.logger,
    );
  }
}
