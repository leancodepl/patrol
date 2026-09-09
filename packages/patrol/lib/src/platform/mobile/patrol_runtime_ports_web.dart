/// Web stub: runtime port injection is iOS/macOS-only.
class PatrolRuntimePorts {
  PatrolRuntimePorts._();

  /// No-op on web.
  static Future<void> ensureLoaded() async {}

  /// Always null on web.
  static int? testServerPort() => null;

  /// Always null on web.
  static int? appServerPort() => null;

  /// Host of the native automation server.
  static String nativeServerHost() =>
      const String.fromEnvironment('PATROL_HOST', defaultValue: 'localhost');
}
