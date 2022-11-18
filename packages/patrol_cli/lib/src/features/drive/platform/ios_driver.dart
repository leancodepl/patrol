import 'dart:async';
import 'dart:io' show Platform, Process;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

class IOSDriver {
  IOSDriver({
    required DisposeScope parentDisposeScope,
    required ArtifactsRepository artifactsRepository,
    required Logger logger,
  })  : _disposeScope = DisposeScope(),
        _artifactsRepository = artifactsRepository,
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final DisposeScope _disposeScope;
  final ArtifactsRepository _artifactsRepository;
  final Logger _logger;

  static const _bundleId = 'pl.leancode.AutomatorServerUITests.xctrunner';

  Future<void> run({
    required String port,
    required Device device,
    required String? flavor,
  }) async {
    if (device.real) {
      await _runServerOnDevice(device: device, port: port);
    } else {
      await _runServerOnSimulator(device: device, port: port);
    }
  }

  Future<void> _runServerOnSimulator({
    required Device device,
    required String port,
  }) async {
    final artifactPath = _artifactsRepository.iosSimulatorPath;
    _logger.detail('Using artifact ${basename(artifactPath)}');

    final installProcess = await Process.start(
      'xcrun',
      [
        'simctl',
        'install',
        device.id,
        artifactPath,
      ],
      runInShell: true,
    )
      ..listenStdOut(_logger.detail).disposedBy(_disposeScope)
      ..listenStdErr(_logger.err).disposedBy(_disposeScope);

    _disposeScope.addDispose(() async {
      await Process.run(
        'xcrun',
        [
          'simctl',
          'uninstall',
          device.id,
          _bundleId,
        ],
        runInShell: true,
      );

      _logger.detail('Uninstalled $_bundleId');
    });

    await installProcess.exitCode;

    final runProcess = await Process.start(
      'xcrun',
      [
        'simctl',
        'launch',
        device.id,
        _bundleId,
      ],
      runInShell: true,
    )
      ..listenStdOut(_logger.detail).disposedBy(_disposeScope)
      ..listenStdErr(_logger.err).disposedBy(_disposeScope);

    await runProcess.exitCode;
  }

  /// Runs the server which is an infinite XCUITest.
  Future<void> _runServerOnDevice({
    required Device device,
    required String port,
  }) async {
    final artifactPath = _artifactsRepository.iosPath;
    _logger.detail('Using artifact ${basename(artifactPath)}');

    final process = await Process.start(
      'xcodebuild',
      [
        'test',
        '-project',
        'AutomatorServer.xcodeproj',
        '-scheme',
        'AutomatorServer',
        '-sdk',
        'iphoneos',
        '-destination',
        'platform=iOS,name=${device.name}',
      ],
      runInShell: true,
      workingDirectory: artifactPath,
      environment: {
        ...Platform.environment,
        // See https://stackoverflow.com/a/69237460/7009800
        'TEST_RUNNER_$envPortKey': port,
      },
    );

    _disposeScope
      // Uninstall AutomatorServer
      ..addDispose(() async {
        const bundleId = 'pl.leancode.AutomatorServerUITests.xctrunner';
        final process = await Process.run(
          'ideviceinstaller',
          ['--uninstall', bundleId, '--udid', device.id],
          runInShell: true,
        );

        final exitCode = process.exitCode;
        final msg = exitCode == 0
            ? 'Uninstalled AutomatorServer'
            : 'Failed to uninstall AutomatorServer (code $exitCode)';
        _logger.detail(msg);
      })
      ..addDispose(() async {
        final msg = process.kill()
            ? 'Killed xcodebuild'
            : 'Failed to kill xcodebuild (${await process.exitCode})';
        _logger.detail(msg);
      });

    final completer = Completer<void>();
    process.listenStdOut((line) {
      if (line.startsWith('PatrolServer')) {
        _logger.info(line);
      } else {
        _logger.detail(line);
      }

      if (line.contains('Server started')) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }).disposedBy(_disposeScope);

    process.listenStdErr((line) {
      _logger.err(line);
      if (line.contains('** TEST FAILED **')) {
        throw Exception(
          'Test failed. See logs above. Also, consider running with --verbose.',
        );
      }
    }).disposedBy(_disposeScope);

    await completer.future;
  }
}
