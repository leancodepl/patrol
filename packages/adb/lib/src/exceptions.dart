/// Used when `adb` command fails.
abstract class AdbException implements Exception {
  /// Creates a new [AdbException].
  const AdbException({required this.message});

  /// Raw error output that caused this exception.
  final String message;

  @override
  String toString() => 'AdbException: $message';
}

/// Indicates that `adb` executable was not found.
class AdbExecutableNotFound extends AdbException {
  /// Creates a new [AdbExecutableNotFound].
  const AdbExecutableNotFound({required super.message});

  @override
  String toString() => 'AdbExecutableNotFound: $message';
}

/// Indicates that `adbd` (ADB daemon) was not running when `adb` (ADB client)
/// was called.
///
/// See also:
///  - https://developer.android.com/studio/command-line/adb
class AdbDaemonNotRunning extends AdbException {
  /// Creates a new [AdbDaemonNotRunning].
  const AdbDaemonNotRunning({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbDaemonNotRunning] should be thrown.
  static const trigger = 'daemon not running; starting now at';

  @override
  String toString() => 'AdbDaemonNotRunning: $message';
}

/// Indicates that `adb install` call failed with
/// INSTALL_FAILED_UPDATE_INCOMPATIBLE.
class AdbInstallFailedUpdateIncompatible extends AdbException {
  /// Creates a new [AdbInstallFailedUpdateIncompatible];
  const AdbInstallFailedUpdateIncompatible({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbInstallFailedUpdateIncompatible] should be thrown.
  static const trigger = 'INSTALL_FAILED_UPDATE_INCOMPATIBLE';

  @override
  String toString() => 'AdbInstallFailedUpdateIncompatible: $message';
}

/// Indicates that `adb uninstall` call failed with
/// DELETE_FAILED_INTERNAL_ERROR.
class AdbDeleteFailedInternalError extends AdbException {
  /// Creates a new [AdbDeleteFailedInternalError];
  const AdbDeleteFailedInternalError({required super.message});

  /// If this string occurs in `adb`'s stderr, there's a good chance that
  /// [AdbDeleteFailedInternalError] should be thrown.
  static const trigger = 'DELETE_FAILED_INTERNAL_ERROR';

  @override
  String toString() => 'AdbDeleteFailedInternalError: $message';
}
