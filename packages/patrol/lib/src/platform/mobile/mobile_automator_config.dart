import 'package:patrol/src/platform/mobile/mobile_automator.dart';

void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}

/// Configuration for [MobileAutomator].
class MobileAutomatorConfig {
  /// Creates a new [MobileAutomatorConfig].
  const MobileAutomatorConfig({
    this.host = const String.fromEnvironment(
      'PATROL_HOST',
      defaultValue: 'localhost',
    ),
    this.port = const String.fromEnvironment(
      'PATROL_TEST_SERVER_PORT',
      defaultValue: '8081',
    ),
    this.connectionTimeout = const Duration(seconds: 60),
    this.findTimeout = const Duration(seconds: 10),
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

  /// Called when a native action is performed.
  final void Function(String) logger;
}
