import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

class FlutterDriverOptions {
  const FlutterDriverOptions({
    required this.driver,
    required this.target,
    required this.host,
    required this.port,
    required this.device,
    required this.flavor,
    required this.dartDefines,
    required this.verbose,
  });

  final String driver;
  final String target;
  final String host;
  final int port;
  final Device? device;
  final String? flavor;
  final Map<String, String> dartDefines;
  final bool verbose;
}

/// Thrown when `flutter_driver` fails to connect within the given timeframe.
class FlutterDriverConnectionFailedException implements Exception {
  /// Creates a new [FlutterDriverConnectionFailedException].
  FlutterDriverConnectionFailedException() : super();
}

class FlutterDriver {
  FlutterDriver(DisposeScope parentDisposeScope)
      : _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final DisposeScope _disposeScope;

  static const _maxRetries = 3;

  /// Runs flutter driver with the given [options] and waits until the drive
  /// completes.
  ///
  /// Prints stdout and stderr of "flutter drive".
  ///
  /// Will attempt to retry the driver run if the driver fails to connect to the
  /// VM within the timeout.
  Future<void> run(FlutterDriverOptions options) async {
    var retries = 1;
    while (true) {
      try {
        log.info('Will run flutter_driver, retry count: $retries');
        await _run(options);
      } on FlutterDriverConnectionFailedException {
        if (retries == _maxRetries) {
          rethrow;
        }

        retries++;
        log.info(
          'flutter_driver failed to connect to the VM. Restarting it and trying again...',
        );
        continue;
      }

      break;
    }
  }

  Future<void> _run(FlutterDriverOptions options) async {
    final device = options.device;
    if (device != null) {
      log.info(
        'Running ${options.target} with flutter_driver on ${device.resolvedName}...',
      );
    } else {
      log.info('Running ${options.target} with flutter_driver...');
    }

    final env = _createEnv(
      host: options.host,
      port: options.port,
      verbose: options.verbose,
    );
    int? exitCode;
    var failedToConnect = false;
    final process = await Process.start(
      'flutter',
      _flutterDriveArguments(
        driver: options.driver,
        target: options.target,
        device: device?.id,
        flavor: options.flavor,
        dartDefines: {...options.dartDefines, ...env},
      ),
      environment: env,
      runInShell: true,
    );
    String kill() {
      return process.kill()
          ? 'Killed flutter_driver'
          : 'Failed to kill flutter_driver';
    }

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

    process.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      log.severe(msg);

      if (msg.contains(
        'VMServiceFlutterDriver: Unknown pause event type Event. Assuming application is ready.',
      )) {
        log.info('flutter_driver failed to connect to the VM, killing it...');
        failedToConnect = true;
        kill();
      }
    }).disposedBy(_disposeScope);

    _disposeScope.addDispose(() async {
      if (exitCode != null) {
        return;
      }

      log.fine(kill());
    });

    exitCode = await process.exitCode;

    final msg = 'flutter_driver exited with code $exitCode';
    log.info(msg);

    if (failedToConnect) {
      throw FlutterDriverConnectionFailedException();
    }

    if (exitCode == -15) {
      // Occurs when the VM is killed. Do nothing.
      // https://github.com/dart-lang/sdk/blob/master/pkg/dartdev/test/commands/create_integration_test.dart#L149-L152
    } else if (exitCode != 0) {
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
