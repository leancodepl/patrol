import 'dart:async';
import 'dart:io';

import 'package:maestro_cli/src/logging.dart';
import 'package:maestro_cli/src/paths.dart';
import 'package:path/path.dart' as path;

Future<void> installApps() async {
  log.info('Installing server...');

  final artifactPath = getArtifactPath();

  var result = await Process.run(
    'adb',
    [
      'install',
      path.join(artifactPath, 'server.apk'),
    ],
  );

  var stderr = result.stderr as String;
  if (stderr.isNotEmpty) {
    log
      ..severe('Failed to install server')
      ..info(stderr);

    throw Error();
  }

  log
    ..info('Server installed')
    ..info('Installing instrumentation...');

  result = await Process.run(
    'adb',
    [
      'install',
      path.join(artifactPath, 'instrumentation.apk'),
    ],
  );

  stderr = result.stderr as String;
  if (stderr.isNotEmpty) {
    log
      ..severe('Failed to install instrumentation')
      ..info(stderr);
    throw Error();
  }

  log.info('Instrumentation installed');
}

Future<void> forwardPorts(int port) async {
  final res = await Process.run(
    'adb',
    [
      'forward',
      'tcp:$port',
      'tcp:$port',
    ],
  );

  final stderr = res.stderr as String;
  if (stderr.isNotEmpty) {
    log.info(stderr);
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
