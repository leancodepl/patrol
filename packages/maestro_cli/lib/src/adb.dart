import 'dart:async';
import 'dart:io';

import 'package:maestro_cli/src/logging.dart';
import 'package:maestro_cli/src/paths.dart';
import 'package:path/path.dart' as path;

Future<void> installApps() async {
  info('Installing server...');

  final artifactPath = getArtifactPath();

  var result = await Process.run(
    'adb',
    [
      'install',
      path.join(artifactPath, 'server.apk'),
    ],
  );

  success('Server installed');

  var err = result.stderr as String;
  if (err.isNotEmpty) {
    error('Failed to install server');
    info(result.stderr.toString());
    throw Error();
  }

  info('Installing instrumentation...');

  result = await Process.run(
    'adb',
    [
      'install',
      path.join(artifactPath, 'instrumentation.apk'),
    ],
  );

  err = result.stderr as String;
  if (err.isNotEmpty) {
    error('Failed to install instrumentation');
    info(result.stderr.toString());
    throw Error();
  }

  success('Instrumentation installed');
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
  final err = res.stderr as String;

  if (err.isNotEmpty) {
    info(res.stderr.toString());
    throw Error();
  }
}

Future<void> runServer() async {
  info('Starting instrumentation server...');

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

  success('Instrumentation server started');

  unawaited(
    res.exitCode.then((code) {
      final msg = 'Instrumentation server exited with code $code';

      if (code != 0) {
        error(msg);
        throw Error();
      } else {
        info(msg);
      }
    }),
  );
}
