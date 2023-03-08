import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';

class FlutterTool {
  FlutterTool({
    required ProcessManager processManager,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _processManager = processManager,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final DisposeScope _disposeScope;
  final Logger _logger;

  // idea: make attach return some AppController, which is an object that implements
  // hot restart, quitting, etc. If is no longer functional after the app dies.

  // TODO: implement
  Future<void> attach({
    required String deviceId,
    required String target,
    required String? flavor,
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

    _logger.detail('Waiting for app to connect for Hot Restart...');
    process
      ..listenStdOut((l) => _logger.detail('\t: $l'))
      ..listenStdErr((l) => _logger.err('\t$l'));
  }

  Future<void> logs(String deviceId) async {
    _logger.detail('Waiting for logs...');
    final process = await _processManager.start(
      ['flutter', '--no-version-check', 'logs', '--device-id', deviceId],
      runInShell: true,
    )
      ..disposedBy(_disposeScope);

    process.listenStdOut((line) {
      if (line.startsWith('Showing ')) {
        _logger.success('Connected to logs');
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
  }
}
