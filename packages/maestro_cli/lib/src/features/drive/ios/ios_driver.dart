import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/common/paths.dart' as paths;
import 'package:maestro_cli/src/features/drive/constants.dart';
import 'package:maestro_cli/src/features/drive/device.dart';
import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;
import 'package:maestro_cli/src/features/drive/platform_driver.dart';

class IOSDriver extends PlatformDriver {
  IOSDriver();

  final DisposeScope disposeScope = DisposeScope();

  @override
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required Device device,
    required String? flavor,
    required Map<String, String> dartDefines,
    required bool verbose,
    required bool debug,
    bool simulator = false,
  }) async {
    if (device.real) {
      await _forwardPorts(port: port, deviceId: device.id);
    }
    final cancel = await _runServer(
      deviceName: device.name,
      simulator: simulator,
      port: port,
      debug: debug,
    );
    await flutter_driver.runWithOutput(
      driver: driver,
      target: target,
      host: host,
      port: port,
      verbose: verbose,
      device: device.name,
      flavor: flavor,
      dartDefines: dartDefines,
    );

    await disposeScope.dispose();
    await cancel();
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

      disposeScope.addDispose(() async {
        log.info('Killing iproxy...');
        process.kill();
        log.info('iproxy killed');
      });

      final completer = Completer<void>();

      process.listenStdOut(
        (line) {
          const trigger = 'waiting for connection';
          if (line.contains(trigger) && !completer.isCompleted) {
            completer.complete();
          }
        },
      ).disposed(disposeScope);

      process
          .listenStdErr((line) => log.warning('iproxy: $line'))
          .disposed(disposeScope);

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
  Future<Future<void> Function()> _runServer({
    required int port,
    required String deviceName,
    required bool simulator,
    required bool debug,
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
      workingDirectory:
          debug ? paths.debugIOSArtifactDir : paths.iosArtifactDir,
      environment: {
        ...Platform.environment,
        // See https://stackoverflow.com/a/69237460/7009800
        'TEST_RUNNER_$envPortKey': port.toString()
      },
    );

    final completer = Completer<void>();
    final stdOutSub = process.listenStdOut((line) {
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
    });

    final stdErrSub = process.listenStdErr((line) {
      log.severe(line);
      if (line.contains('** TEST FAILED **')) {
        throw Exception(
          'Test failed. See logs above. Also, consider running with --verbose.',
        );
      }
    });

    completer.complete();

    return () async {
      await process.exitCode.then((exitCode) async {
        await stdOutSub.cancel();
        await stdErrSub.cancel();

        final msg = 'xcodebuild exited with code $exitCode';
        if (exitCode == 0) {
          log.info(msg);
        } else {
          log.severe(msg);
        }
      });
    };
  }
}
