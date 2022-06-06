import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
Future<void> runTests(String driver, String target, {String? device}) async {
  log.info('Running tests...');

  final res = await Process.run(
    'flutter',
    [
      'drive',
      '--driver',
      driver,
      '--target',
      target,
      if (device != null) ...[
        '--device-id',
        device,
      ],
    ],
    runInShell: true,
  );

  if (res.stdErr.isNotEmpty) {
    throw Exception(res.stdErr);
  }
}

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
///
/// Prints standard output of "flutter drive".
Future<void> runTestsWithOutput(
  String driver,
  String target, {
  String? device,
}) async {
  log.info('Running tests with output...');

  final res = await Process.start(
    'flutter',
    [
      'drive',
      '--driver',
      driver,
      '--target',
      target,
      if (device != null) ...[
        '--device-id',
        device,
      ],
    ],
    runInShell: true,
  );

  final stdOutSub = res.stdout.listen((msg) {
    final text = 'driver: ${systemEncoding.decode(msg)}';
    if (text.contains('I/flutter')) {
      log.info(text);
    } else {
      log.fine(text);
    }
  });

  final stdErrSub = res.stderr.listen((msg) {
    final text = 'driver: ${systemEncoding.decode(msg)}';
    log.severe(text);
  });

  final exitCode = await res.exitCode;
  await stdOutSub.cancel();
  await stdErrSub.cancel();

  final msg = 'flutter_driver exited with code $exitCode';
  if (exitCode == 0) {
    log.info(msg);
  } else {
    log.severe(msg);
  }
}
