/// Indicates that `adbd` (ADB daemon) was not running when `adb` (ADB client)
/// was called.
///
/// See also:
///  - https://developer.android.com/studio/command-line/adb
class AdbDaemonNotRunning implements Exception {
  /// Creates a new [AdbDaemonNotRunning].
  const AdbDaemonNotRunning();

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbDaemonNotRunning] should be thrown.
  static const trigger = 'daemon not running; starting now at';
}

/// Indicates that `adb install` call failed with
/// INSTALL_FAILED_UPDATE_INCOMPATIBLE.
class AdbInstallFailedUpdateIncompatible implements Exception {
  /// Creates a new [AdbInstallFailedUpdateIncompatible];
  AdbInstallFailedUpdateIncompatible({required this.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbInstallFailedUpdateIncompatible] should be thrown.
  static const trigger = 'INSTALL_FAILED_UPDATE_INCOMPATIBLE';

  /// Raw error output that caused this exception.
  final String message;

  @override
  String toString() {
    return 'AdbInstallFailedUpdateIncompatible(message: $message)';
  }
}
