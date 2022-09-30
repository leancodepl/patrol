import 'dart:io' show Process, systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/extensions/map.dart';
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
  });

  final String driver;
  final String target;
  final String? host;
  final String? port;
  final Device? device;
  final String? flavor;
  final Map<String, String> dartDefines;
}

/// Thrown when `flutter drive` exits with non-zero exit code.
class FlutterDriverFailedException implements Exception {
  FlutterDriverFailedException(this.code) : super();

  final int code;

  @override
  String toString() => 'flutter_driver exited with code $code';
}

class FlutterDriver {
  FlutterDriver({
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final DisposeScope _disposeScope;
  final Logger _logger;

  /// Runs flutter driver with the given [options] and waits until the drive
  /// completes.
  ///
  /// Prints stdout and stderr of "flutter drive".
  Future<void> run(FlutterDriverOptions options) async {
    final deviceName = options.device?.resolvedName;
    final targetName = basename(options.target);
    if (deviceName != null) {
      _logger.info('Running $targetName with flutter_driver on $deviceName...');
    } else {
      _logger.info('Running $targetName with flutter_driver...');
    }

    final env = {
      envHostKey: options.host,
      envPortKey: options.port,
    }.withNullsRemoved();

    int? exitCode;
    final process = await Process.start(
      'flutter',
      _flutterDriveArguments(
        driver: options.driver,
        target: options.target,
        device: options.device?.id,
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
          _logger.info(line.replaceFirst(flutterWithPortPrefix, ''));
        } else if (line.startsWith(flutterPrefix)) {
          _logger.info(line.replaceFirst(flutterPrefix, ''));
        } else {
          _logger.fine(line);
        }
      }
    }).disposedBy(_disposeScope);

    process.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.severe(msg);
    }).disposedBy(_disposeScope);

    _disposeScope.addDispose(() async {
      if (exitCode != null) {
        return;
      }

      _logger.fine(kill());
    });

    exitCode = await process.exitCode;

    final msg = 'flutter_driver exited with code $exitCode';
    _logger.info(msg);

    if (exitCode == -15) {
      // Occurs when the VM is killed. Do nothing because it was most probably
      // killed by us.
      // https://github.com/dart-lang/sdk/blob/master/pkg/dartdev/test/commands/create_integration_test.dart#L149-L152
    } else if (exitCode != 0) {
      throw FlutterDriverFailedException(exitCode);
    }
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
