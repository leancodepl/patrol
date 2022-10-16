import 'dart:async';
import 'dart:io' show Process, Platform;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:logging/logging.dart';
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

    if (device.real) {
      await _runServerPhysical(
        deviceName: device.name,
        deviceId: device.id,
        port: port,
      );
    } else {
      await _runServerSimulator(deviceId: device.id, port: port);
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

  Future<void> _runServerSimulator({
    required String port,
    required String deviceId,
  }) async {
    // FIXME: artifact path to .app
    _logger
        .fine('Using artifact in ${_artifactsRepository.iosArtifactDirPath}');

    // FIXME: fix artifact path to .app
    final installProcess = await Process.start(
      'xcrun',
      [
        'simctl',
        'install',
        deviceId,
        _artifactsRepository.iosArtifactDirPath,
      ],
      runInShell: true,
    );

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
  }

  /// Runs the server which is an infinite XCUITest.
  Future<void> _runServerPhysical({
    required String port,
    required String deviceName,
    required String deviceId,
  }) async {
    _logger
        .fine('Using artifact in ${_artifactsRepository.iosArtifactDirPath}');

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
      workingDirectory: _artifactsRepository.iosArtifactDirPath,
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
