import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
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

  /// Attaches to the running app. Returns a [Future] that completes when the
  /// connection is ready.
  Future<void> attach({
    required String deviceId,
    required String target,
    required Map<String, String> dartDefines,
  }) async {
    final process = await _processManager.start(
      [
        ...['flutter', 'attach'],
        '--no-version-check',
        '--debug',
        ...['--target', target],
        for (final dartDefine in dartDefines.entries) ...[
          '--dart-define',
          '${dartDefine.key}=${dartDefine.value}',
        ],
      ],
    )
      ..disposedBy(_disposeScope);

    final completer = Completer<void>();
    _disposeScope.addDispose(() async {
      if (!completer.isCompleted) {
        _logger.detail('Killed before app connected to Hot Restart');
        completer.complete();
      }
    });

    _logger.detail('Hot Restart: waiting for app to connect...');
    process
      ..listenStdOut((line) {
        if (line == 'Flutter run key commands.' && !completer.isCompleted) {
          _logger.success('Hot Restart: app connected (press "r" to restart)');
          completer.complete();
        }
        _logger.detail('\t: $line');
      })
      ..listenStdErr((l) => _logger.err('\t$l'));

    await completer.future;

    _stdin.listen((event) {
      final char = String.fromCharCode(event.first);
      if (char == 'r' || char == 'R') {
        _logger.success('Triggered Hot Restart...');
        process.stdin.add('R'.codeUnits);
      }
    });
  }

  /// Connects to app's logs. Returns a [Future] that completes when the logs
  /// are connected.
  Future<void> logs(String deviceId) async {
    _logger.detail('Logs: waiting for them...');
    final process = await _processManager.start(
      ['flutter', '--no-version-check', 'logs', '--device-id', deviceId],
      runInShell: true,
    )
      ..disposedBy(_disposeScope);

    final completer = Completer<void>();
    process.listenStdOut((line) {
      if (line.startsWith('Showing ') && line.endsWith('logs:')) {
        _logger.detail('Logs: connected');
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
    }).disposedBy(_disposeScope);

    process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(_disposeScope);

    return completer.future;
  }
}
