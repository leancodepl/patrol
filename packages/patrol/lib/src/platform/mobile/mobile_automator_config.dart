import 'package:patrol/src/platform/mobile/mobile_automator.dart';
import 'package:patrol/src/platform/mobile/patrol_runtime_ports.dart';

void _defaultPrintLogger(String message) {
  // TODO: Use a logger instead of print
  // ignore: avoid_print
  print('Patrol (native): $message');
}

/// Configuration for [MobileAutomator].
class MobileAutomatorConfig {
  /// Creates a new [MobileAutomatorConfig].
  const MobileAutomatorConfig({
    String? host,
    String? port,
    Duration? connectionTimeout,
    Duration? findTimeout,
    void Function(String)? logger,
  }) : host =
           host ??
           const String.fromEnvironment(
             'PATROL_HOST',
             defaultValue: 'localhost',
           ),
       _portOverride = port,
       connectionTimeout = connectionTimeout ?? const Duration(seconds: 60),
       findTimeout = findTimeout ?? const Duration(seconds: 10),
       logger = logger ?? _defaultPrintLogger;

  final String? _portOverride;

  static String _defaultPort() {
    final injectedPort = PatrolRuntimePorts.testServerPort();
    if (injectedPort != null) {
      return injectedPort.toString();
    }
    return const String.fromEnvironment(
      'PATROL_TEST_SERVER_PORT',
      defaultValue: '8081',
    );
  }

  /// Host on which Patrol server instrumentation is running.
  final String host;

  /// Port on [host] on which Patrol server instrumentation is running.
  String get port => _portOverride ?? _defaultPort();

  /// The explicitly configured port, if any.
  ///
  /// Unlike [port], reading this does not resolve the default port, so it can
  /// be copied between configs before the runtime ports are loaded.
  String? get portOverride => _portOverride;

  /// Time after which the connection with the native automator will fail.
  ///
  /// It must be longer than [findTimeout].
  final Duration connectionTimeout;

  /// Time to wait for native views to appear.
  final Duration findTimeout;

  /// Called when a native action is performed.
  final void Function(String) logger;
}
