import 'dart:async';
import 'dart:io';

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
    await _runServer(
      deviceName: device.name,
      deviceId: device.id,
      simulator: !device.real,
      port: port,
    );
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

  /// Runs the server which is an infinite XCUITest.
  Future<void> _runServer({
    required String port,
    required String deviceName,
    required String deviceId,
    required bool simulator,
  }) async {
    _logger
        .fine('Using artifact in ${_artifactsRepository.iosArtifactDirPath}');

    // This xcodebuild fails when using Dart < 2.17.
    final process = await Process.start(
      'xcodebuild',
      [
        'test',
        '-project',
        'AutomatorServer.xcodeproj',
        '-scheme',
        'AutomatorServer',
        '-sdk',
        if (simulator) 'iphonesimulator' else 'iphoneos',
        '-destination',
        'platform=iOS${simulator ? " Simulator" : ""},name=$deviceName',
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
        final process = simulator
            ? await Process.run(
                'xcrun',
                ['simctl', 'uninstall', deviceId, bundleId],
                runInShell: true,
              )
            : await Process.run(
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
