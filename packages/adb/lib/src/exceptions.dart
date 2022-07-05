/// Indicates that adb call failed with INSTALL_FAILED_UPDATE_INCOMPATIBLE.
class AdbInstallFailedUpdateIncompatible implements Exception {
  AdbInstallFailedUpdateIncompatible._({
    required this.packageName,
    required this.message,
  });

  /// Creates a new instance of [AdbInstallFailedUpdateIncompatible] from
  /// [stderr].
  factory AdbInstallFailedUpdateIncompatible.fromStdErr(String stderr) {
    final str = stderr;

    const start = ': Package ';
    const end = ' signatures do not match';

    final startIndex = str.indexOf(start);
    final endIndex = str.indexOf(end, startIndex + start.length);

    final packageName = str.substring(startIndex + start.length, endIndex);

    return AdbInstallFailedUpdateIncompatible._(
      packageName: packageName,
      message: stderr,
    );
  }

  final String message;
  final String packageName;

  @override
  String toString() {
    return 'AdbInstallFailedUpdateIncompatible(packageName: $packageName, message: $message)';
  }
}
