import 'dart:io' show systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' show absolute, basename, join;
import 'package:patrol_cli/src/common/extensions/core.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:process/process.dart';

extension TargetPlatformX on TargetPlatform {
  String get artifactType {
    switch (this) {
      case TargetPlatform.android:
        return 'apk';
      case TargetPlatform.iOS:
        return 'app';
    }
  }

  String get command {
    switch (this) {
      case TargetPlatform.android:
        return 'apk';
      case TargetPlatform.iOS:
        return 'ios';
    }
  }
}

/// Thrown when `flutter drive` exits with non-zero exit code.
class FlutterBuildFailedException implements Exception {
  FlutterBuildFailedException(this.code)
      : assert(code != 0, 'exit code is 0, which means success'),
        super();

  final int code;

  @override
  String toString() => '`flutter build` exited with code $code';
}

/// Thrown when `flutter drive` exits with non-zero exit code.
class FlutterDriverFailedException implements Exception {
  FlutterDriverFailedException(this.code)
      : assert(code != 0, 'exit code is 0, which means success'),
        super();

  final int code;

  @override
  String toString() => '`flutter drive` exited with code $code';
}

/// Wrapper around the flutter tool.
class FlutterTool {
  FlutterTool({
    required ProcessManager processManager,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _processManager = processManager,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  late String _driver;
  String? _flavor;
  late Map<String, String> _dartDefines;
  late Map<String, String> _env;

  final ProcessManager _processManager;
  final DisposeScope _disposeScope;
  final Logger _logger;

  void init({
    required String driver,
    required String? host,
    required String? port,
    required String? flavor,
    required Map<String, String> dartDefines,
  }) {
    _driver = driver;
    _flavor = flavor;
    _dartDefines = dartDefines;

    _env = {
      envHostKey: host,
      envPortKey: port,
    }.withNullsRemoved();
  }

  Future<void> build(String target, Device device) async {
    final targetName = basename(target);
    final platform = device.targetPlatform;

    _logger.info(
      '${green.wrap(">")} Building ${platform.artifactType} for $targetName...',
    );

    int? exitCode;
    final process = await _processManager.start(
      [
        'flutter',
        '--no-version-check',
        ...['build', platform.command],
        '--debug',
        ...['--target', target],
        if (_flavor != null) ...['--flavor', _flavor!],
        if (platform == TargetPlatform.iOS)
          if (device.real) '--no-simulator' else '--simulator',
        for (final dartDefine in {..._env, ..._dartDefines}.entries) ...[
          '--dart-define',
          '${dartDefine.key}=${dartDefine.value}',
        ]
      ],
      runInShell: true,
    );

    String kill() {
      return process.kill()
          ? 'Killed flutter build'
          : 'Failed to kill `flutter build`';
    }

    process.stdout.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.detail(msg);
    }).disposedBy(_disposeScope);

    process.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.err(msg);
    }).disposedBy(_disposeScope);

    _disposeScope.addDispose(() async {
      if (exitCode != null) {
        return;
      }

      _logger.detail(kill());
    });

    exitCode = await process.exitCode;

    final msg = exitCode == 0
        ? '${green.wrap("✓")} Building ${platform.artifactType} for $targetName succeeded!'
        : '${red.wrap("✗")} Build ${platform.artifactType} for $targetName failed';

    _logger.err(msg);
    if (exitCode != 0) {
      throw FlutterBuildFailedException(exitCode);
    }
  }

  /// Runs [target] on [device] and waits until the test completes.
  ///
  /// Prints stdout and stderr of "flutter drive".
  Future<void> drive(String target, Device device) async {
    final deviceName = device.resolvedName;
    final targetName = basename(target);

    _logger.info('${green.wrap(">")} Running $targetName on $deviceName...');

    int? exitCode;
    final process = await _processManager.start(
      [
        'flutter',
        '--no-version-check',
        ..._flutterDriveArguments(
          driver: _driver,
          target: target,
          device: device.id,
          flavor: _flavor,
          platform: device.targetPlatform,
          simulator: !device.real,
        ),
      ],
      environment: {
        ..._env,
        // below must be synced with the patrol driver from package:patrol
        ...{
          'DRIVER_DEVICE_ID': device.id,
          'DRIVER_DEVICE_OS': device.targetPlatform.name.toLowerCase(),
        }
      },
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
          _logger.detail(line);
        }
      }
    }).disposedBy(_disposeScope);

    process.stderr.listen((rawMsg) {
      final msg = systemEncoding.decode(rawMsg).trim();
      _logger.err(msg);
    }).disposedBy(_disposeScope);

    _disposeScope.addDispose(() async {
      if (exitCode != null) {
        return;
      }

      _logger.detail(kill());
    });

    exitCode = await process.exitCode;

    final msg = exitCode == 0
        ? '${green.wrap("✓")} $targetName passed!'
        : '${red.wrap("✗")} $targetName failed';

    _logger.err(msg);
    if (exitCode != 0) {
      throw FlutterDriverFailedException(exitCode);
    }
  }

  List<String> _flutterDriveArguments({
    required String driver,
    required String target,
    required String? device,
    required String? flavor,
    required TargetPlatform platform,
    required bool simulator,
  }) {
    String getApplicationBinaryPath() {
      if (platform == TargetPlatform.android) {
        final prefix = absolute(join('build', 'app', 'outputs', 'flutter-apk'));
        if (flavor != null) {
          return join(prefix, 'app-${flavor.toLowerCase()}-debug.apk');
        } else {
          return join(prefix, 'app-debug.apk');
        }
      } else {
        if (simulator) {
          return 'build/ios/iphonesimulator/Runner.app';
        } else {
          return 'build/ios/iphoneos/Runner.app';
        }
      }
    }

    return [
      'drive',
      '--no-pub',
      '--driver',
      driver,
      ...['--target', target],
      ...['--use-application-binary', getApplicationBinaryPath()],
      if (device != null) ...['--device-id', device],
      if (flavor != null) ...['--flavor', flavor],
    ];
  }
}
