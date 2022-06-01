import 'dart:io';

import 'package:maestro_cli/src/logging.dart';

Future<void> runTests(String driver, String target) async {
  info('Running tests...');

  final res = await Process.run(
    'flutter',
    [
      'drive',
      '--driver',
      driver,
      '--target',
      target,
    ],
  );
  final err = res.stderr as String;

  if (err.isNotEmpty) {
    error(res.stderr.toString());
    throw Error();
  }
}

Future<void> runTestsWithOutput(String driver, String target) async {
  info('Running tests with output...');

  final res = await Process.start(
    'flutter',
    [
      'drive',
      '--driver',
      driver,
      '--target',
      target,
    ],
  );

  final sub = res.stdout.listen((msg) => info(systemEncoding.decode(msg)));
  await res.exitCode;
  await sub.cancel();
}
