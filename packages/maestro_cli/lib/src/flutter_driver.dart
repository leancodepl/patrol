import 'dart:io';

import 'package:maestro_cli/src/logging.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
///
/// Prints standard output of "flutter drive".
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

  final stderr = res.stderr as String;
  if (stderr.isNotEmpty) {
    error(stderr);
    throw Error();
  }
}

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
///
/// Prints standard output of "flutter drive".
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

  final sub = res.stdout.listen((msg) {
    info('driver: ${systemEncoding.decode(msg)}');
  });

  await res.exitCode;
  await sub.cancel();
}
