import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/constants.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
Future<void> runTests({
  required String driver,
  required String target,
  required String host,
  required int port,
  required bool verbose,
  String? device,
  String? flavor,
  Map<String, String> dartDefines = const {},
}) async {
  if (device != null) {
    log.info('Running tests on $device...');
  } else {
    log.info('Running tests...');
  }

  final env = _dartDefines(host: host, port: port, verbose: verbose);

  final result = await Process.run(
    'flutter',
    _flutterDriveArguments(
      driver: driver,
      target: target,
      device: device,
      flavor: flavor,
      dartDefines: {...dartDefines, ...env},
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
  required String host,
  required int port,
  required bool verbose,
  String? device,
  String? flavor,
  Map<String, String> dartDefines = const {},
}) async {
  if (device != null) {
    log.info('Running tests with output on $device...');
  } else {
    log.info('Running tests with output...');
  }

  final env = _dartDefines(host: host, port: port, verbose: verbose);

  final process = await Process.start(
    'flutter',
    _flutterDriveArguments(
      driver: driver,
      target: target,
      device: device,
      flavor: flavor,
      dartDefines: {...dartDefines, ...env},
    ),
    environment: env,
    runInShell: true,
  );

  final stdOutSub = process.stdout.listen((msg) {
    final text = systemEncoding.decode(msg).trim();

    if (text.contains('I/flutter')) {
      final index = text.indexOf(':');
      final parts = [
        text.substring(0, index).trim(),
        text.substring(index + 1).trim()
      ];
      log.info(parts[1]);
    } else {
      log.fine(text);
    }
  });

  final stdErrSub = process.stderr.listen((msg) {
    final text = systemEncoding.decode(msg).trim();
    log.severe('ERR: $text');
  });

  final exitCode = await process.exitCode;
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
  required int port,
  required bool verbose,
}) {
  return {
    envHostKey: host,
    envPortKey: port.toString(),
    envVerboseKey: verbose.toString(),
  };
}

List<String> _flutterDriveArguments({
  required String driver,
  required String target,
  String? device,
  String? flavor,
  Map<String, String> dartDefines = const {},
}) {
  for (final dartDefine in dartDefines.entries) {
    final key = dartDefine.key;
    final value = dartDefine.value;

    if (key.contains(' ') || key.contains('=')) {
      throw FormatException(
        '--dart-define key "$value" contains whitespace or "="',
      );
    }

    if (value.contains(' ') || value.contains('=')) {
      throw FormatException(
        '--dart-define value "$value" contains whitespace or "="',
      );
    }
  }

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
