import 'dart:io' show Process, systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:logging/logging.dart';
import 'package:mason_logger/mason_logger.dart' show green, red;
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/extensions/map.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

/// Thrown when `flutter drive` exits with non-zero exit code.
class FlutterDriverFailedException implements Exception {
  FlutterDriverFailedException(this.code)
      : assert(code != 0, 'exit code is 0, which means success'),
        super();

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

  String? host;
  String? port;
  String? flavor;
  late Map<String, String> dartDefines;

  final DisposeScope _disposeScope;
  final Logger _logger;

  void init({
    required String? host,
    required String? port,
    required String? flavor,
    required Map<String, String> dartDefines,
  }) {
    this.host = host;
    this.port = port;
    this.flavor = flavor;
    this.dartDefines = dartDefines;
  }

  /// Runs [target] on [device] and waits until the test completes.
  ///
  /// Prints stdout and stderr of "flutter drive".
  Future<void> run(String target, Device device) async {
    final deviceName = device.resolvedName;
    final targetName = basename(target);

    _logger.info('${green.wrap(">")} Running $targetName on $deviceName...');

    final env = {
      envHostKey: host,
      envPortKey: port,
    }.withNullsRemoved();

    int? exitCode;
    final process = await Process.start(
      'flutter',
      [
        '--no-version-check',
        ..._flutterTestArguments(
          target: target,
          device: device.id,
          flavor: flavor,
          dartDefines: {...dartDefines, ...env},
        ),
      ],
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

    final msg = exitCode == 0
        ? '${green.wrap("✓")} $targetName passed!'
        : '${red.wrap("✗")} $targetName failed';

    _logger.severe(msg);
    if (exitCode != 0) {
      throw FlutterDriverFailedException(exitCode);
    }
  }

  List<String> _flutterTestArguments({
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
      'test',
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
