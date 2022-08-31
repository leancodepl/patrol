import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:maestro_cli/src/common/artifacts_repository.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/constants.dart';
import 'package:maestro_cli/src/features/drive/device.dart';
import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;

class IOSDriver {
  IOSDriver(
    DisposeScope parentDisposeScope,
    this._artifactsRepository,
  ) : _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ArtifactsRepository _artifactsRepository;

  final DisposeScope _disposeScope;

  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required Device device,
    required String? flavor,
    required Map<String, String> dartDefines,
    required bool verbose,
    bool simulator = false,
  }) async {
    if (device.real) {
      await _forwardPorts(port: port, deviceId: device.id);
    }
    await _runServer(
      deviceName: device.name,
      deviceId: device.id,
      simulator: simulator,
      port: port,
    );
    await flutter_driver.FlutterDriver(_disposeScope).run(
      driver: driver,
      target: target,
      host: host,
      port: port,
      verbose: verbose,
      device: device.name,
      flavor: flavor,
      dartDefines: dartDefines,
    );
  }

  /// Forwards ports using iproxy.
  Future<void> _forwardPorts({
    required int port,
    required String deviceId,
  }) async {
    final progress = log.progress('Forwarding ports');

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
        log.fine('Killed iproxy');
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
          .listenStdErr((line) => log.warning('iproxy: $line'))
          .disposedBy(_disposeScope);

      await completer.future;
    } catch (err) {
      progress.fail('Failed to forward ports');
      rethrow;
    }

    progress.complete('Forwarded ports');
  }

  /// Runs the server which is an infinite XCUITest.
  ///
  /// Returns when the server is installed and running.
  Future<void> _runServer({
    required int port,
    required String deviceName,
    required String deviceId,
    required bool simulator,
  }) async {
    // This xcodebuild fails when using Dart < 2.17.
    final process = await Process.start(
      'xcodebuild',
      [
        'test',
        '-workspace',
        'AutomatorServer.xcworkspace',
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
        'TEST_RUNNER_$envPortKey': port.toString()
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
        log.fine(msg);
      })
      ..addDispose(() async {
        final msg = process.kill()
            ? 'Killed xcodebuild'
            : 'Failed to kill xcodebuild (${await process.exitCode})';
        log.fine(msg);
      });

    final completer = Completer<void>();
    process.listenStdOut((line) {
      if (line.startsWith('MaestroServer')) {
        log.info(line);
      } else {
        log.fine(line);
      }

      if (line.contains('Server started')) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }).disposedBy(_disposeScope);

    process.listenStdErr((line) {
      log.severe(line);
      if (line.contains('** TEST FAILED **')) {
        throw Exception(
          'Test failed. See logs above. Also, consider running with --verbose.',
        );
      }
    }).disposedBy(_disposeScope);

    await completer.future;
  }
}
