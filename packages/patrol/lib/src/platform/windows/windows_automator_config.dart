import 'package:patrol/src/platform/windows/windows_automator.dart';

/// Configuration for [WindowsAutomator].
class WindowsAutomatorConfig {
  /// Creates a new [WindowsAutomatorConfig].
  const WindowsAutomatorConfig({
    String? host,
    String? port,
    Duration? connectionTimeout,
    void Function(String)? logger,
  }) : host =
           host ??
           const String.fromEnvironment(
             'PATROL_HOST',
             defaultValue: 'localhost',
           ),
       port =
           port ??
           const String.fromEnvironment(
             'PATROL_TEST_SERVER_PORT',
             defaultValue: '8081',
           ),
       connectionTimeout = connectionTimeout ?? const Duration(seconds: 60),
       logger = logger ?? _defaultPrintLogger;

  /// Host on which the Windows automator server is running.
  final String host;

  /// Port on [host] for the Windows automator server.
  final String port;

  /// Time after which the connection with the native automator will fail.
  final Duration connectionTimeout;

  /// Called when a native action is performed.
  final void Function(String) logger;
}

void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}
