/// Linux automator.
///
/// Patrol supports Linux desktop only for Dart-side (Flutter) interactions.
/// There is no native automation server on Linux, so this automator has no
/// actions. Native actions called on Linux throw [UnsupportedError].
class LinuxAutomator {
  /// Creates a new [LinuxAutomator].
  const LinuxAutomator();
}
