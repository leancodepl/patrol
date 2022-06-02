import 'dart:async';
import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';
import 'package:path/path.dart' as path;

Future<void> installApps() async {
  try {
    log.info('Installing server...');
    await _installApk(serverArtifactFile);
  } catch (err) {
    log.severe('Failed to install server');
    rethrow;
  }

  log.info('Server installed');

  try {
    log.info('Installing instrumentation...');
    await _installApk(instrumentationArtifactFile);
  } catch (err) {
    log.severe('Failed to install instrumentation');
    rethrow;
  }

  log.info('Instrumentation installed');
}

Future<void> forwardPorts(int port) async {
  final result = await Process.run(
    'adb',
    [
      'forward',
      'tcp:$port',
      'tcp:$port',
    ],
  );

  if (result.stdErr.isNotEmpty) {
    log.info(result.stdErr);
    throw Error();
  }
}

Future<void> runServer() async {
  log.info('Starting instrumentation server...');

  final res = await Process.start(
    'adb',
    [
      'shell',
      'am',
      'instrument',
      '-w',
      'pl.leancode.automatorserver.test/androidx.test.runner.AndroidJUnitRunner',
    ],
  );

  log.info('Instrumentation server started');

  unawaited(
    res.exitCode.then((code) {
      final msg = 'Instrumentation server exited with code $code';

      if (code != 0) {
        log.severe(msg);
        throw Error();
      } else {
        log.info(msg);
      }
    }),
  );
}

Future<void> _installApk(String name) async {
  final result = await Process.run(
    'adb',
    [
      'install',
      path.join(artifactsPath, name),
    ],
  );

  if (result.stdErr.isNotEmpty) {
    throw Exception(result.stdErr);
  }
}
