import 'dart:async';
import 'dart:io' show Process, Platform;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:logging/logging.dart';
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

  Future<void> run({
    required String port,
    required Device device,
    required String? flavor,
  }) async {
    if (device.real) {
      await _forwardPorts(port: port, deviceId: device.id);
    }

    _logger.info(device);
    if (device.real) {
      await _runServerOnDevice(
        deviceName: device.name,
        deviceId: device.id,
        port: port,
      );
    } else {
      await _runServerOnSimulator(deviceId: device.id, port: port);
    }
  }

  /// Forwards ports using iproxy.
  Future<void> _forwardPorts({
    required String port,
    required String deviceId,
  }) async {
    final progress = _logger.progress('Forwarding ports');

    try {
      // See https://github.com/libimobiledevice/libusbmuxd/issues/103
      final process = await Process.start(
        'stdbuf',
        [
          '-i0',
          '-o0',
          '-e0',
          'iproxy',
          '$port:$port',
          '--udid',
          deviceId,
        ],
        runInShell: true,
      );

      _disposeScope.addDispose(() async {
        process.kill();
        _logger.fine('Killed iproxy');
      });

      final completer = Completer<void>();

      process.listenStdOut(
        (line) {
          const trigger = 'waiting for connection';
          if (line.contains(trigger) && !completer.isCompleted) {
            completer.complete();
          }
        },
      ).disposedBy(_disposeScope);

      process
          .listenStdErr((line) => _logger.warning('iproxy: $line'))
          .disposedBy(_disposeScope);

      await completer.future;
    } catch (err) {
      progress.fail('Failed to forward ports');
      rethrow;
    }

    progress.complete('Forwarded ports');
  }

  Future<void> _runServerOnSimulator({
    required String port,
    required String deviceId,
  }) async {
    // TODO: Use artifact appropriate for the Simulator architecture
    final artifactPath = _artifactsRepository.iosSimulatorArmPath;
    _logger.fine('Using artifact ${basename(artifactPath)}');

    final installProcess = await Process.start(
      'xcrun',
      [
        'simctl',
        'install',
        deviceId,
        artifactPath,
      ],
      runInShell: true,
    );

    _disposeScope.addDispose(() async {
      await Process.run(
        'xcrun',
        [
          'simctl',
          'uninstall',
          deviceId,
          'pl.leancode.AutomatorServerUITests.xctrunner',
        ],
      );
    });

    installProcess.listenStdOut(_logger.info).disposedBy(_disposeScope);
    installProcess.listenStdErr(_logger.fine).disposedBy(_disposeScope);

    await installProcess.exitCode;

    final runProcess = await Process.start(
      'xcrun',
      [
        'simctl',
        'launch',
        deviceId,
        'pl.leancode.AutomatorServerUITests.xctrunner',
      ],
      runInShell: true,
    );

    runProcess.listenStdOut(_logger.info).disposedBy(_disposeScope);
    runProcess.listenStdErr(_logger.fine).disposedBy(_disposeScope);

    await runProcess.exitCode;
  }

  /// Runs the server which is an infinite XCUITest.
  Future<void> _runServerOnDevice({
    required String port,
    required String deviceName,
    required String deviceId,
  }) async {
    final artifactPath = _artifactsRepository.iosPath;
    _logger.fine('Using artifact ${basename(artifactPath)}');

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
        'platform=iOS,name=$deviceName',
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
          ['--uninstall', bundleId, '--udid', deviceId],
          runInShell: true,
        );

        final exitCode = process.exitCode;
        final msg = exitCode == 0
            ? 'Uninstalled AutomatorServer'
            : 'Failed to uninstall AutomatorServer (code $exitCode)';
        _logger.fine(msg);
      })
      ..addDispose(() async {
        final msg = process.kill()
            ? 'Killed xcodebuild'
            : 'Failed to kill xcodebuild (${await process.exitCode})';
        _logger.fine(msg);
      });

    final completer = Completer<void>();
    process.listenStdOut((line) {
      if (line.startsWith('PatrolServer')) {
        _logger.info(line);
      } else {
        _logger.fine(line);
      }

      if (line.contains('Server started')) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }).disposedBy(_disposeScope);

    process.listenStdErr((line) {
      _logger.severe(line);
      if (line.contains('** TEST FAILED **')) {
        throw Exception(
          'Test failed. See logs above. Also, consider running with --verbose.',
        );
      }
    }).disposedBy(_disposeScope);

    await completer.future;
  }
}
