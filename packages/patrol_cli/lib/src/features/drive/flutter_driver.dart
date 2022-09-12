import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';

class FlutterDriver {
  FlutterDriver(DisposeScope parentDisposeScope)
      : _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final DisposeScope _disposeScope;

  /// Runs flutter driver with the given [driver] and [target] and waits until
  /// the drive is done.
  ///
  /// Prints stdout and stderr of "flutter drive".
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required String? device,
    required String? flavor,
    required Map<String, String> dartDefines,
    required bool verbose,
  }) async {
    if (device != null) {
      log.info('Running $target with flutter_driver on $device...');
    } else {
      log.info('Running $target with flutter_driver...');
    }

    final env = _createEnv(
      host: host,
      port: port,
      verbose: verbose,
    );
    int? exitCode;
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

    process.stdout.listen((msg) {
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
    }).disposedBy(_disposeScope);

    process.stderr
        .listen((msg) => log.severe(systemEncoding.decode(msg).trim()))
        .disposedBy(_disposeScope);

    _disposeScope.addDispose(() async {
      if (exitCode != null) {
        return;
      }

      final msg = process.kill()
          ? 'Killed flutter_driver'
          : 'Failed to kill flutter_driver';
      log.fine(msg);
    });

    exitCode = await process.exitCode;

    final msg = 'flutter_driver exited with code $exitCode';
    if (exitCode == 0) {
      log.info(msg);
    } else if (exitCode == -15) {
      // Occurs when the VM is killed. Do nothing.
      // https://github.com/dart-lang/sdk/blob/master/pkg/dartdev/test/commands/create_integration_test.dart#L149-L152
    } else {
      throw Exception('$msg. See logs above.');
    }
  }

  Map<String, String> _createEnv({
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
}
