import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';

class IOSDeploy {
  IOSDeploy({
    required ProcessManager processManager,
    required FileSystem fs,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _processManager = processManager,
        _fs = fs,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final FileSystem _fs;
  final DisposeScope _disposeScope;
  final Logger _logger;

  /// Installs and launches the app on physical iOS device with [deviceId].
  ///
  /// To kill the app, send `kill` to the returned [Process]'s stdin.
  Future<Process> installAndLaunch(String deviceId) async {
    final process = await _processManager.start(
      [
        'ios-deploy',
        ...['--id', deviceId],
        ...[
          '--bundle',
          '../build/ios_integ/Build/Products/Debug-iphoneos/Runner.app'
        ],
        // TODO: Enable deltas (https://github.com/leancodepl/patrol/issues/871)
        // ...['--app_deltas', '../build/ios_integ/Runner-delta'],
        '--debug',
        '--no-wifi',
        ...[
          '--args',
          '--enable-dart-profiling --enable-checked-mode --verify-entry-points'
        ],
      ],
      runInShell: true,
      workingDirectory: _fs.currentDirectory.childDirectory('ios').path,
    );

    var launchSucceeded = false;

    process.disposedBy(_disposeScope);
    process.listenStdOut((line) {
      if (line == 'success') {
        launchSucceeded = true;
      }
    }).disposedBy(_disposeScope);

    var totalTimeElapsed = Duration.zero;
    while (!launchSucceeded) {
      const delta = Duration(milliseconds: 100);
      await Future<void>.delayed(delta);
      totalTimeElapsed += delta;

      final secondsElapsed = totalTimeElapsed.inSeconds;
      if (secondsElapsed > 1 && secondsElapsed % 30 == 0) {
        _logger.warn(
          'Waiting for ios-deploy to launch the app is taking unusually long time (${secondsElapsed}s)',
        );
      }
    }
    _logger.detail('ios-deploy successfully launched the app');
    return process;
  }
}
