import 'dart:io';

import 'package:maestro_cli/src/logging.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
///
/// Prints standard output of "flutter drive".
Future<void> runTests(String driver, String target) async {
  log.info('Running tests...');

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
    log.severe(stderr);
    throw Error();
  }
}

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
///
/// Prints standard output of "flutter drive".
Future<void> runTestsWithOutput(String driver, String target) async {
  log.info('Running tests with output...');

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
    final text = 'driver: ${systemEncoding.decode(msg)}';
    if (text.contains('I/flutter')) {
      log.info(text);
    } else {
      log.fine(text);
    }
  });

  await res.exitCode;
  await sub.cancel();
}
