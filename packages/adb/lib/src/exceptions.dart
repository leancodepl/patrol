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
  AdbInstallFailedUpdateIncompatible._({
    required this.packageName,
    required this.message,
  });

  /// Creates a new instance of [AdbInstallFailedUpdateIncompatible] from
  /// [stderr].
  factory AdbInstallFailedUpdateIncompatible.fromStdErr(String stderr) {
    final str = stderr;

    // not pretty, but works
    const start = ': Existing package ';
    const end = ' signatures do not match';

    final startIndex = str.indexOf(start);
    final endIndex = str.indexOf(end, startIndex + start.length);

    final packageName = str.substring(startIndex + start.length, endIndex);

    return AdbInstallFailedUpdateIncompatible._(
      packageName: packageName,
      message: stderr,
    );
  }

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbInstallFailedUpdateIncompatible] should be thrown.
  static const trigger = 'INSTALL_FAILED_UPDATE_INCOMPATIBLE';

  /// Raw error output that caused this exception.
  final String message;

  /// Package which could not be installed.
  final String packageName;

  @override
  String toString() {
    return 'AdbInstallFailedUpdateIncompatible(packageName: $packageName, message: $message)';
  }
}
