import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
Future<void> runTests(
  String driver,
  String target, {
  String? device,
  String? flavor,
  Map<String, String> dartDefines = const <String, String>{},
}) async {
  log.info('Running tests...');

  final res = await Process.run(
    'flutter',
    _flutterDriveArguments(
      driver: driver,
      target: target,
      device: device,
      flavor: flavor,
      dartDefines: {'MAESTRO_HOST': 'localhost', 'MAESTRO_PORT': '8081'},
    ),
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
Future<void> runTestsWithOutput({
  required String driver,
  required String target,
  required String port,
  required String host,
  String? device,
  String? flavor,
}) async {
  log.info('Running tests with output...');

  final env = {'MAESTRO_HOST': host, 'MAESTRO_PORT': port};

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

List<String> _flutterDriveArguments({
  required String driver,
  required String target,
  String? device,
  String? flavor,
  Map<String, String> dartDefines = const <String, String>{},
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
