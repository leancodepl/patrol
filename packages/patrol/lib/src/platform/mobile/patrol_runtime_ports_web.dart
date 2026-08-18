/// Web stub: runtime port injection is iOS/macOS-only.
class PatrolRuntimePorts {
  PatrolRuntimePorts._();

  /// No-op on web.
  static Future<void> ensureLoaded() async {}

  /// Always null on web.
  static int? testServerPort() => null;

  /// Always null on web.
  static int? appServerPort() => null;
}
