import 'dart:async';
import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';
import 'package:path/path.dart' as path;

/// Indicates that adb call failed with INSTALL_FAILED_UPDATE_INCOMPATIBLE.
class AdbInstallFailedUpdateIncompatible implements Exception {
  AdbInstallFailedUpdateIncompatible._({
    required this.packageName,
    required this.message,
  });

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
    return 'AdbInstallFailedUpdateIncompatible{packageName: $packageName, message: $message}';
  }
}

Future<void> installApps({String? device}) async {
  final progress1 = log.progress('Installing server');
  try {
    await _forceInstallApk(serverArtifactFile, device: device);
  } catch (err) {
    progress1.fail('Failed to install server');
    rethrow;
  }
  progress1.complete('Installed server');

  final progress2 = log.progress('Installing instrumentation');
  try {
    await _forceInstallApk(instrumentationArtifactFile, device: device);
  } catch (err) {
    progress2.fail('Failed to install instrumentation');
    rethrow;
  }

  progress2.complete('Installed instrumentation');
}

Future<void> forwardPorts(int port, {String? device}) async {
  final progress = log.progress('Forwarding ports');

  final result = await Process.run(
    'adb',
    [
      if (device != null) ...[
        '-s',
        device,
      ],
      'forward',
      'tcp:$port',
      'tcp:$port',
    ],
    runInShell: true,
  );

  if (result.stdErr.isNotEmpty) {
    progress.fail('Failed to forward ports');
    throw Exception(result.stdErr);
  }

  progress.complete('Forwarded ports');
}

Future<void> runServer({String? device}) async {
  final progress = log.progress('Starting instrumentation server');

  Process process;
  try {
    process = await Process.start(
      'adb',
      [
        if (device != null) ...[
          '-s',
          device,
        ],
        'shell',
        'am',
        'instrument',
        '-w',
        'pl.leancode.automatorserver.test/androidx.test.runner.AndroidJUnitRunner',
      ],
    );
  } catch (err) {
    progress.fail('Failed to start instrumentation server');
    rethrow;
  }

  unawaited(
    process.exitCode.then((code) {
      final msg = 'Instrumentation server exited with code $code';

      if (code != 0) {
        log.severe(msg);
        throw Exception(msg);
      } else {
        log.info(msg);
      }
    }),
  );

  progress.complete('Started instrumentation server');
}

/// Installs APK named [name] in [artifactPath].
///
/// If the install fails because of INSTALL_FAILED_UPDATE_INCOMPATIBLE, it's
/// reinstalled.
Future<void> _forceInstallApk(String name, {required String? device}) async {
  try {
    await _installApk(name, device: device);
  } on AdbInstallFailedUpdateIncompatible catch (err) {
    await _uninstallApk(err.packageName, device: device);
    await _installApk(name, device: device);
  }
}

Future<ProcessResult> _uninstallApk(
  String packageName, {
  required String? device,
}) async {
  final result = await Process.run(
    'adb',
    [
      if (device != null) ...[
        '-s',
        device,
      ],
      'uninstall',
      packageName,
    ],
    runInShell: true,
  );

  if (result.stdErr.isNotEmpty) {
    throw Exception(result.stdErr);
  }

  return result;
}

Future<ProcessResult> _installApk(
  String name, {
  required String? device,
}) async {
  final result = await Process.run(
    'adb',
    [
      if (device != null) ...[
        '-s',
        device,
      ],
      'install',
      path.join(artifactPath, name),
    ],
    runInShell: true,
  );

  if (result.stdErr.isNotEmpty) {
    if (result.stdErr.contains('INSTALL_FAILED_UPDATE_INCOMPATIBLE')) {
      throw AdbInstallFailedUpdateIncompatible.fromStdErr(result.stdErr);
    }

    throw Exception(result.stdErr);
  }

  return result;
}
