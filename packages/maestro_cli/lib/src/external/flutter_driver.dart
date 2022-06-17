import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
Future<void> runTests({
  required String driver,
  required String target,
  required String port,
  required String host,
  required bool verbose,
  String? device,
  String? flavor,
}) async {
  log.info('Running tests...');

  final env = _dartDefines(host: host, port: port, verbose: verbose);

  final result = await Process.run(
    'flutter',
    _flutterDriveArguments(
      driver: driver,
      target: target,
      device: device,
      flavor: flavor,
      dartDefines: env,
    ),
    environment: env,
    runInShell: true,
  );

  if (result.stdErr.isNotEmpty) {
    throw Exception(result.stdErr);
  }
}

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
///
/// Prints standard output of "flutter drive".
Future<void> runTestsWithOutput({
  required String driver,
  required String target,
  required String port,
  required String host,
  required bool verbose,
  String? device,
  String? flavor,
}) async {
  log.info('Running tests with output...');

  final env = _dartDefines(host: host, port: port, verbose: verbose);

  final result = await Process.start(
    'flutter',
    _flutterDriveArguments(
      driver: driver,
      target: target,
      device: device,
      flavor: flavor,
      dartDefines: env,
    ),
    environment: env,
    runInShell: true,
  );

  final stdOutSub = result.stdout.listen((msg) {
    final text = 'driver: ${systemEncoding.decode(msg)}';
    if (text.contains('I/flutter')) {
      log.info(text);
    } else {
      log.fine(text);
    }
  });

  final stdErrSub = result.stderr.listen((msg) {
    final text = 'driver: ${systemEncoding.decode(msg)}';
    log.severe(text);
  });

  final exitCode = await result.exitCode;
  await stdOutSub.cancel();
  await stdErrSub.cancel();

  final msg = 'flutter_driver exited with code $exitCode';
  if (exitCode == 0) {
    log.info(msg);
  } else {
    log.severe(msg);
  }
}

Map<String, String> _dartDefines({
  required String host,
  required String port,
  required bool verbose,
}) {
  return {
    'MAESTRO_HOST': host,
    'MAESTRO_PORT': port,
    'MAESTRO_VERBOSE': verbose.toString(),
  };
}

List<String> _flutterDriveArguments({
  required String driver,
  required String target,
  String? device,
  String? flavor,
  Map<String, String> dartDefines = const {},
}) {
  return [
    'drive',
    '--driver',
    driver,
    '--target',
    target,
    if (device != null) ...[
      '--device-id',
      device,
    ],
    if (flavor != null) ...[
      '--flavor',
      flavor,
    ],
    for (final dartDefine in dartDefines.entries) ...[
      '--dart-define',
      '${dartDefine.key}=${dartDefine.value}',
    ]
  ];
}
