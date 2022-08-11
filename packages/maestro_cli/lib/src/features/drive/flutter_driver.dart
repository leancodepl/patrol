import 'dart:io';

import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/constants.dart';

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
Future<void> run({
  required String driver,
  required String target,
  required String host,
  required int port,
  String? device,
  String? flavor,
  required Map<String, String> dartDefines,
  required bool verbose,
}) async {
  if (device != null) {
    log.info('Running $target on $device...');
  } else {
    log.info('Running $target...');
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

  if (result.stdOut.isNotEmpty) {
    throw Exception(result.stdOut);
  }
}

/// Runs flutter driver with the given [driver] and [target] and waits until the
/// drive is done.
///
/// Prints standard output of "flutter drive".
Future<void> runWithOutput({
  required String driver,
  required String target,
  required String host,
  required int port,
  String? device,
  String? flavor,
  required Map<String, String> dartDefines,
  required bool verbose,
}) async {
  if (device != null) {
    log.info('Running $target with output on $device...');
  } else {
    log.info('Running $target with output...');
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
    final lines = systemEncoding
        .decode(msg)
        .split('\n')
        .map((str) => str.trim())
        .toList()
      ..removeWhere((element) => element.isEmpty);

    for (final line in lines) {
      // On iOS, "flutter" is not prefixed
      final flutterPrefix = RegExp('flutter: ');

      // On Android, "flutter" is prefixed with "I\"
      final flutterWithPortPrefix = RegExp(r'I\/flutter \(\s*[0-9]+\): ');
      if (line.startsWith(flutterWithPortPrefix)) {
        log.info(line.replaceFirst(flutterWithPortPrefix, ''));
      } else if (line.startsWith(flutterPrefix)) {
        log.info(line.replaceFirst(flutterPrefix, ''));
      } else {
        log.fine(line);
      }
    }
  });

  final stdErrSub = process.stderr.listen((msg) {
    final text = systemEncoding.decode(msg).trim();
    log.severe(text);
  });

  final exitCode = await process.exitCode;
  await stdOutSub.cancel();
  await stdErrSub.cancel();

  final msg = 'flutter_driver exited with code $exitCode';
  if (exitCode == 0) {
    log.info(msg);
  } else {
    log.warning('$msg. See logs above.');
    //throw Exception('$msg. See logs above.');
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
  required String? device,
  required String? flavor,
  required Map<String, String> dartDefines,
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
