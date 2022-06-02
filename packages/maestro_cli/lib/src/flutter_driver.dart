import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
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

  if (res.stdErr.isNotEmpty) {
    log.severe(res.stdErr);
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
