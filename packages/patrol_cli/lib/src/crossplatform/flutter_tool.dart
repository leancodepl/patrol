import 'dart:async';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';

class FlutterTool {
  FlutterTool({
    required Stream<List<int>> stdin,
    required ProcessManager processManager,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _stdin = stdin,
        _processManager = processManager,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final Stream<List<int>> _stdin;
  final ProcessManager _processManager;
  final DisposeScope _disposeScope;
  final Logger _logger;

  bool _hotRestartActive = false;
  bool _logsActive = false;

  /// Forwards logs and hot restarts the app when "r" is pressed.
  Future<void> attachForHotRestart({
    required String deviceId,
    required String target,
    required String? appId,
    required Map<String, String> dartDefines,
  }) async {
    if (io.stdin.hasTerminal) {
      _enableInteractiveMode();
    }

    await Future.wait<void>([
      logs(deviceId),
      attach(
        deviceId: deviceId,
        target: target,
        appId: appId,
        dartDefines: dartDefines,
      ),
    ]);
  }

  /// Attaches to the running app. Returns a [Future] that completes when the
  /// connection is ready.
  @visibleForTesting
  Future<void> attach({
    required String deviceId,
    required String target,
    required String? appId,
    required Map<String, String> dartDefines,
  }) async {
    await _disposeScope.run((scope) async {
      final process = await _processManager.start(
        [
          ...['flutter', 'attach'],
          '--no-version-check',
          '--debug',
          '--no-sound-null-safety',
          ...['--device-id', deviceId],
          if (appId != null) ...['--app-id', appId],
          ...['--target', target],
          for (final dartDefine in dartDefines.entries) ...[
            '--dart-define',
            '${dartDefine.key}=${dartDefine.value}',
          ],
        ],
      )
        ..disposedBy(scope);

      _stdin.listen((event) {
        final char = String.fromCharCode(event.first);
        if (char == 'r' || char == 'R') {
          if (!_hotRestartActive) {
            _logger.warn('Hot Restart: not attached to the app yet!');
            return;
          }

          _logger.success('Hot Restart for entrypoint ${basename(target)}...');
          process.stdin.add('R'.codeUnits);
        }
      }).disposedBy(scope);

      final completer = Completer<void>();
      scope.addDispose(() async {
        if (!completer.isCompleted) {
          _logger.detail('Killed before attached to the app');
          completer.complete();
        }
      });

      _logger.detail('Hot Restart: waiting for attach to the app...');
      process.listenStdOut((line) {
        if (line == 'Flutter run key commands.' && !completer.isCompleted) {
          _logger.success(
            'Hot Restart: attached to the app (press "r" to restart)',
          );
          _hotRestartActive = true;

          if (!_logsActive) {
            _logger.warn('Hot Restart: logs are not connected yet');
          }
          completer.complete();
        }
        _logger.detail('\t: $line');
      }).disposedBy(scope);

      process.listenStdErr((line) {
        if (line.startsWith('Waiting for another flutter command')) {
          // This is a warning that we can ignore
          return;
        }
        _logger.err('\t$line');
      }).disposedBy(scope);

      await completer.future;
    });
  }

  /// Connects to app's logs. Returns a [Future] that completes when the logs
  /// are connected.
  @visibleForTesting
  Future<void> logs(String deviceId) async {
    await _disposeScope.run((scope) async {
      _logger.detail('Logs: waiting for them...');
      final process = await _processManager.start(
        ['flutter', '--no-version-check', 'logs', '--device-id', deviceId],
        runInShell: true,
      )
        ..disposedBy(scope);

      final completer = Completer<void>();
      scope.addDispose(() async {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      process.listenStdOut((line) {
        if (line.startsWith('Showing ') && line.endsWith('logs:')) {
          _logger.success('Hot Restart: logs connected');
          _logsActive = true;

          if (!_hotRestartActive) {
            _logger.warn('Hot Restart: not attached to the app yet');
          }
          completer.complete();
        }

        // On iOS, "flutter" is not prefixed
        final flutterPrefix = RegExp('flutter: ');

        // On Android, "flutter" is prefixed with "I\"
        final flutterWithPortPrefix = RegExp(r'I\/flutter \(\s*[0-9]+\): ');
        if (line.startsWith(flutterWithPortPrefix)) {
          _logger.info('\t${line.replaceFirst(flutterWithPortPrefix, '')}');
        } else if (line.startsWith(flutterPrefix)) {
          _logger.info('\t${line.replaceFirst(flutterPrefix, '')}');
        } else {
          _logger.detail('\t$line');
        }
      }).disposedBy(scope);

      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      await completer.future;
    });
  }

  void _enableInteractiveMode() {
    // Prevents keystrokes from being printed automatically. Needs to be
    // disabled for lineMode to be disabled too.
    io.stdin.echoMode = false;

    // Causes the stdin stream to provide the input as soon as it arrives (one
    // key press at a time).
    io.stdin.lineMode = false;

    _logger.detail('Interactive shell mode enabled.');
  }
}
