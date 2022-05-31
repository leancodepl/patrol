import 'dart:async';
import 'dart:io';

import 'package:maestro_cli/src/paths.dart';
import 'package:path/path.dart' as path;

Future<void> installApps() async {
  print('Installing server...');

  final pubCache = getApkInstallPath();

  var result = await Process.run(
    'adb',
    [
      'install',
      path.join(pubCache, 'server.apk'),
    ],
  );

  print('Server installed');

  var err = result.stderr as String;
  if (err.isNotEmpty) {
    print('Failed to install server');
    print(result.stderr);
    throw Error();
  }

  print('Installing instrumentation...');

  result = await Process.run(
    'adb',
    [
      'install',
      path.join(pubCache, 'instrumentation.apk'),
    ],
  );

  err = result.stderr as String;
  if (err.isNotEmpty) {
    print('Failed to install instrumentation');
    print(result.stderr);
    throw Error();
  }

  print('Instrumentation installed');
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
    print(res.stderr);
    throw Error();
  }
}

Future<void> runServer() async {
  print('Starting instrumentation server...');

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

  print('Instrumentation server started');

  unawaited(
    res.exitCode.then((code) {
      if (code != 0) {
        print('Instrumentation server exited with code $code');
        throw Error();
      }
    }),
  );
}
