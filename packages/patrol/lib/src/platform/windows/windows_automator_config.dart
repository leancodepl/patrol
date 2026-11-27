import 'package:patrol/src/platform/windows/windows_automator.dart';

/// Configuration for [WindowsAutomator].
class WindowsAutomatorConfig {
  /// Creates a new [WindowsAutomatorConfig].
  const WindowsAutomatorConfig({
    String? host,
    String? port,
    Duration? connectionTimeout,
    Duration? findTimeout,
    void Function(String)? logger,
  }) :        // Sidecar binds IPv4 loopback; prefer 127.0.0.1 so Windows does not
       // resolve `localhost` to ::1 and miss the server.
       host =
           host ??
           const String.fromEnvironment(
             'PATROL_HOST',
             defaultValue: '127.0.0.1',
           ),
       port =
           port ??
           const String.fromEnvironment(
             'PATROL_TEST_SERVER_PORT',
             defaultValue: '8081',
           ),
       connectionTimeout = connectionTimeout ?? const Duration(seconds: 60),
       findTimeout = findTimeout ?? const Duration(seconds: 10),
       logger = logger ?? _defaultPrintLogger;

  /// Host on which the Windows automator server is running.
  final String host;

  /// Port on [host] for the Windows automator server.
  final String port;

  /// Time after which the HTTP connection with the automator sidecar fails.
  ///
  /// Must be longer than [findTimeout].
  final Duration connectionTimeout;

  /// Time to wait for desktop UI elements to appear.
  final Duration findTimeout;

  /// Called when a native action is performed.
  final void Function(String) logger;

  /// Creates a copy of this config with the given fields replaced.
  WindowsAutomatorConfig copyWith({
    String? host,
    String? port,
    Duration? connectionTimeout,
    Duration? findTimeout,
    void Function(String)? logger,
  }) {
    return WindowsAutomatorConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      findTimeout: findTimeout ?? this.findTimeout,
      logger: logger ?? this.logger,
    );
  }
}

void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}
