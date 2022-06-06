import 'dart:async';
import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';
import 'package:path/path.dart' as path;

Future<void> installApps() async {
  final progress1 = log.progress('Installing server');
  try {
    await _installApk(serverArtifactFile);
  } catch (err) {
    progress1.fail('Failed to install server');
    rethrow;
  }
  progress1.complete('Installed server');

  final progress2 = log.progress('Installing instrumentation');
  try {
    await _installApk(instrumentationArtifactFile);
  } catch (err) {
    progress2.fail('Failed to install instrumentation');
    rethrow;
  }

  progress2.complete('Installed instrumentation');
}

Future<void> forwardPorts(int port) async {
  final progress = log.progress('Forwarding ports');

  final result = await Process.run(
    'adb',
    [
      'forward',
      'tcp:$port',
      'tcp:$port',
    ],
  );

  if (result.stdErr.isNotEmpty) {
    progress.fail('Failed to forward ports');
    throw Exception(result.stdErr);
  }

  progress.complete('Forwarded ports');
}

Future<void> runServer() async {
  final progress = log.progress('Starting instrumentation server');

  Process process;
  try {
    process = await Process.start(
      'adb',
      [
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

Future<void> _installApk(String name) async {
  final result = await Process.run(
    'adb',
    [
      'install',
      path.join(artifactPath, name),
    ],
  );

  if (result.stdErr.isNotEmpty) {
    throw Exception(result.stdErr);
  }
}
