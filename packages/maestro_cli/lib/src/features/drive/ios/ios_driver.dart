import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/constants.dart';
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
    required String device,
    required String? flavor,
    Map<String, String> dartDefines = const {},
    required bool verbose,
    required bool debug,
    bool simulator = false,
  }) async {
    await _forwardPorts(port); // TODO: Use device UDID
    await _runServer(
      deviceName: device,
      simulator: simulator,
      port: port,
    );
    await flutter_driver.runWithOutput(
      driver: driver,
      target: target,
      host: host,
      port: port,
      verbose: verbose,
      device: device,
      flavor: flavor,
      dartDefines: dartDefines,
    );

    await disposeScope.dispose();
  }

  /// Forwards ports using iproxy.
  Future<void> _forwardPorts(int port, {String? device}) async {
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
          //'--udid',
          //'00008101-001611D026A0001E'
        ], // TODO: use right device
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
    bool simulator = false,
  }) async {
    // TODO: don't hardcode working directory
    const xcProjPath = '/Users/bartek/dev/leancode/maestro/AutomatorServer/ios';

    // TODO: Fix failing to build when using Dart x86_64.
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
      workingDirectory: xcProjPath,
      environment: {...Platform.environment, envPortKey: port.toString()},
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
