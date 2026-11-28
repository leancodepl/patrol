import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:meta/meta.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/completer.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

class FlutterTool {
  FlutterTool({
    required this._stdin,
    required this._processManager,
    required this._platform,
    required DisposeScope parentDisposeScope,
    required this._logger,
    this.projectRoot,
    this.onQuit,
    required this._onExit,
    @visibleForTesting this._adbTimeout = const Duration(seconds: 5),
  }) : _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  /// The project `flutter attach` and `flutter logs` run in; the process's
  /// working directory when null.
  final String? projectRoot;

  final Stream<List<int>> _stdin;
  final ProcessManager _processManager;
  final NativePlatform _platform;
  final DisposeScope _disposeScope;
  final Logger _logger;
  final Future<void> Function()? onQuit;

  /// Runs when the user quits. It owns disposing what the session started:
  /// this tool knows only its own processes, not the backends'.
  final Future<void> Function() _onExit;

  final Duration _adbTimeout;

  var _hotRestartActive = false;
  var _logsActive = false;
  var _logsSkipped = false;
  var _devtoolsUrl = '';
  io.Process? _attachProcess;
  var _pendingHotRestart = false;
  int? _attachExitCode;
  String? _attachFailure;
  final _attachFailed = Completer<String>();
  void Function()? _onRestartCompleted;
  void Function()? _onRestartFailed;

  /// Sends a Hot Restart to the attached app - the same as pressing `r`.
  ///
  /// If `flutter attach` hasn't connected yet the request is queued and sent
  /// as soon as it does. Once `flutter attach` has exited outside a quit, the
  /// request is refused with a warning and neither callback fires.
  ///
  /// [onCompleted] fires once `flutter attach` reports the restart as
  /// completed ('Restarted application ...'), not when it is requested.
  /// Callers use it to tell output of the old and the new program apart.
  /// [onFailed] fires instead when the restart is rejected (compile error);
  /// for a request that is sent, exactly one of the two fires, at most once.
  void hotRestart({void Function()? onCompleted, void Function()? onFailed}) {
    // Repeats the stderr tail: a restart comes long after the exit scrolled by.
    if (_attachFailure case final failure?) {
      _logger.warn(failure);
      return;
    }
    _onRestartCompleted = onCompleted;
    _onRestartFailed = onFailed;
    final process = _attachProcess;
    if (process == null || !_hotRestartActive) {
      _logger.warn(
        'Hot Restart: not attached to the app yet, will restart once attached',
      );
      _pendingHotRestart = true;
      return;
    }
    _logger.success('Hot Restart requested...');
    process.stdin.add('R'.codeUnits);
  }

  void _settleRestart(void Function()? callback) {
    _onRestartCompleted = null;
    _onRestartFailed = null;
    callback?.call();
  }

  final _hotRestartReady = Completer<void>();

  /// Completes once `flutter attach` will act on a hot restart.
  ///
  /// A restart requested earlier is held until then, so a caller that reports
  /// on the restart waits for this before claiming it was sent.
  Future<void> get hotRestartReady => _hotRestartReady.future;

  /// Why `flutter attach` exited outside a quit, once it has: its exit code and
  /// what it wrote to stderr. Hot restart is unavailable from then on.
  String? get attachFailure => _attachFailure;

  /// The exit code of `flutter attach` once it has exited outside a quit.
  int? get attachExitCode => _attachExitCode;

  static String _attachUnavailable(int code) =>
      'Hot Restart is not available: ${_exitSummary('flutter attach', code)}';

  /// Completes with [attachFailure] once `flutter attach` has exited outside a
  /// quit.
  Future<String> get attachFailed => _attachFailed.future;

  /// Forwards logs and hot restarts the app when "r" is pressed.
  Future<void> attachForHotRestart({
    required FlutterCommand flutterCommand,
    required String deviceId,
    required String target,
    required String? appId,
    required Map<String, String> dartDefines,
    required bool openDevtools,
    bool attachUsingUrl = false,
    Future<String>? debugUrl,
    bool forwardFlutterLogs = true,
    bool removeAdbForwards = false,
    Future<void> Function()? onQuit,
  }) async {
    _logsSkipped = !forwardFlutterLogs;

    StdinModes? previousStdinModes;
    if (io.stdin.hasTerminal) {
      try {
        previousStdinModes = enableInteractiveMode();
      } on io.StdinException catch (err) {
        _logger.detail('Interactive shell mode unavailable: $err');
      }
    }

    Future<void> onQuitWithRevertInteractiveMode() async {
      if (previousStdinModes != null) {
        try {
          revertInteractiveMode(previousStdinModes);
        } catch (err) {
          // The terminal outlives us; failing to restore it must not stop the
          // cleanup below, nor be reported as the cleanup failing.
          _logger.detail('Could not restore the terminal: $err');
        }
      }
      if (onQuit != null) {
        await onQuit();
      }
    }

    if (attachUsingUrl) {
      final url =
          await (debugUrl ??
              _readDebugUrlFromFlutterLogs(
                deviceId,
                flutterCommand: flutterCommand,
              ));
      if (url == null) {
        return;
      }

      await attach(
        flutterCommand: flutterCommand,
        target: target,
        deviceId: deviceId,
        appId: appId,
        debugUrl: url,
        dartDefines: dartDefines,
        openBrowser: openDevtools,
        removeAdbForwards: removeAdbForwards,
        onQuit: onQuitWithRevertInteractiveMode,
      );
    } else {
      await Future.wait<void>([
        if (forwardFlutterLogs) logs(deviceId, flutterCommand: flutterCommand),
        attach(
          flutterCommand: flutterCommand,
          target: target,
          deviceId: deviceId,
          appId: appId,
          dartDefines: dartDefines,
          openBrowser: openDevtools,
          removeAdbForwards: removeAdbForwards,
          onQuit: onQuitWithRevertInteractiveMode,
        ),
      ]);
    }
  }

  /// Completes with null once the session is disposed before the URL arrives.
  Future<String?> _readDebugUrlFromFlutterLogs(
    String deviceId, {
    required FlutterCommand flutterCommand,
  }) async {
    final urlCompleter = Completer<String?>();
    // The error can be set before anything awaits this below.
    urlCompleter.future.ignore();
    await logs(
      deviceId,
      flutterCommand: flutterCommand,
      observationUrlCompleter: urlCompleter,
    );

    return urlCompleter.future;
  }

  /// Runs `adb` with [arguments] and returns its stdout, or null when adb is
  /// missing, fails or does not finish within the adb timeout. A wedged adb
  /// server never answers, so adb is killed then.
  Future<String?> _runAdb(List<String> arguments) async {
    final io.Process process;
    try {
      process = await _processManager.start(['adb', ...arguments]);
    } on Object {
      return null;
    }
    final stdout = process.stdout.transform(utf8.decoder).join();
    unawaited(process.stderr.drain<void>());
    try {
      final exitCode = await process.exitCode.timeout(_adbTimeout);
      return exitCode == 0 ? await stdout : null;
    } on TimeoutException {
      process.kill();
      stdout.ignore();
      _logger.detail('adb ${arguments.join(' ')} did not finish in time');
      return null;
    }
  }

  /// The `adb` forwards for [deviceId] as `local remote` pairs, or none when
  /// adb is not there or knows no such device.
  Future<Set<String>> _adbForwards(String deviceId) async {
    final listing = await _runAdb(['forward', '--list']);
    if (listing == null) {
      return const {};
    }
    return {
      for (final line in LineSplitter.split(listing))
        if (line.trim().split(RegExp(r'\s+')) case [
          final serial,
          final local,
          final remote,
        ] when serial == deviceId)
          '$local $remote',
    };
  }

  /// Removes the VM service forwards among [pairs]. Patrol's own forwards map
  /// a port to the same port and are removed by the code that made them.
  Future<void> _removeAttachForwards(String deviceId, Set<String> pairs) async {
    for (final pair in pairs) {
      final [local, remote] = pair.split(' ');
      if (!remote.startsWith('tcp:') || local == remote) {
        continue;
      }
      final removed = await _runAdb([
        ...['-s', deviceId],
        'forward',
        '--remove',
        local,
      ]);
      if (removed != null) {
        _logger.detail('Removed adb forward $local left by flutter attach');
      }
    }
  }

  /// Attaches to the running app. Returns a [Future] that completes when the
  /// connection is ready.
  ///
  /// If [openBrowser] is true, Dart DevTools (with Patrol extension page
  /// selected) will be automatically opened in the browser once DevTools URL is
  /// printed by Flutter CLI.
  @visibleForTesting
  Future<void> attach({
    required FlutterCommand flutterCommand,
    required String deviceId,
    required String target,
    String? debugUrl,
    required String? appId,
    required Map<String, String> dartDefines,
    required bool openBrowser,
    bool removeAdbForwards = false,
    Future<void> Function()? onQuit,
  }) async {
    await _disposeScope.run((scope) async {
      // `flutter attach` forwards the VM service port for itself and removes
      // the forward only on its own exit, which a killed tool never reaches.
      // Its forwards are the ones that appear until it connects; later ones
      // belong to other tools on the same device.
      Set<String>? forwardsBefore;
      Future<Set<String>>? attachForwards;
      if (removeAdbForwards) {
        forwardsBefore = await _adbForwards(deviceId);
        // Registered before the process, so it runs after the process is gone.
        scope.addDispose(() async {
          if (attachForwards case final forwards?) {
            await _removeAttachForwards(deviceId, await forwards);
          }
        });
      }

      final process =
          await _processManager.start([
              ...[flutterCommand.executable, ...flutterCommand.arguments],
              'attach',
              '--no-version-check',
              '--suppress-analytics',
              '--debug',
              ...['--device-id', deviceId],
              if (debugUrl != null) ...['--debug-url', debugUrl],
              if (appId != null) ...['--app-id', appId],
              ...['--target', target],
              for (final dartDefine in dartDefines.entries) ...[
                '--dart-define',
                '${dartDefine.key}=${dartDefine.value}',
              ],
            ], workingDirectory: projectRoot)
            ..disposedByTree(scope);
      _attachProcess = process;

      final completer = Completer<void>();
      scope.addDispose(() {
        if (!completer.isCompleted) {
          _logger.detail('Killed before attached to the app');
        }
        completer.maybeComplete();
      });

      var quitting = false;
      _reportExit(process, scope, 'flutter attach', (code, reason) {
        if (scope.disposed || quitting) {
          return;
        }
        _hotRestartActive = false;
        _attachExitCode = code;
        final failure = 'Hot Restart is not available: $reason';
        _attachFailure = failure;
        _attachFailed.maybeComplete(failure);
        _logger.err(_attachUnavailable(code));
        completer.maybeComplete();
      });

      _stdin
          .listen((event) async {
            final char = String.fromCharCode(event.first);
            if (char == 'r' || char == 'R') {
              if (!_hotRestartActive) {
                if (_attachFailure case final failure?) {
                  _logger.warn(failure);
                  return;
                }
                _logger.warn(
                  'Hot Restart: not attached to the app yet, will restart once '
                  'attached',
                );
                _pendingHotRestart = true;
                return;
              }

              _logger.success(
                'Hot Restart for entrypoint ${basename(target)}...',
              );
              process.stdin.add('R'.codeUnits);
            } else if (char == 'h' || char == 'H') {
              final helpText = StringBuffer(
                'Patrol develop key commands:\n'
                'r Hot restart\n'
                'h Print this help message\n'
                'q Quit (terminate the process and application on the device)',
              );

              if (_devtoolsUrl.isNotEmpty) {
                helpText.writeln('\nDevTools: $_devtoolsUrl');
              } else {
                helpText.writeln('\nDevTools: not available yet');
              }

              _logger.success(helpText.toString());
            } else if (char == 'q' || char == 'Q') {
              if (quitting) {
                return;
              }
              quitting = true;
              _logger.success('Quitting process...');
              completer.maybeComplete();

              // Call the uninstall function if provided
              if (onQuit != null) {
                try {
                  await onQuit();
                } catch (err) {
                  _logger.err('Failed to clean up app: $err');
                }
              }

              try {
                await _onExit();
              } catch (err) {
                _logger.err('Failed during exit: $err');
              }
            }
          })
          .disposedBy(scope);

      _logger.detail('Hot Restart: waiting for attach to the app...');
      process
          .listenStdOut((line) {
            if (line == 'Flutter run key commands.' && !completer.isCompleted) {
              _logger.success(
                'Hot Restart: attached to the app\n'
                'Patrol develop key commands:\n'
                'r Hot restart\n'
                'h Print this help message\n'
                'q Quit (terminate the process and application on the device)',
              );
              _hotRestartActive = true;
              if (forwardsBefore case final before?) {
                attachForwards = _adbForwards(
                  deviceId,
                ).then((after) => after.difference(before));
              }
              if (!_hotRestartReady.isCompleted) {
                _hotRestartReady.complete();
              }
              if (_pendingHotRestart) {
                _pendingHotRestart = false;
                _logger.success('Hot Restart: sending the queued restart');
                process.stdin.add('R'.codeUnits);
              }

              if (!_logsActive && !_logsSkipped) {
                _logger.warn('Hot Restart: logs are not connected yet');
              }
              completer.maybeComplete();
            }

            if (line.startsWith('Restarted application')) {
              _settleRestart(_onRestartCompleted);
            }

            if (line.startsWith('Try again after fixing the above error')) {
              _settleRestart(_onRestartFailed);
            }

            if (line.startsWith('The Flutter DevTools debugger and profiler')) {
              _devtoolsUrl = getDevtoolsUrl(line);
              _logger.success(
                'Patrol DevTools extension is available at $_devtoolsUrl',
              );

              if (openBrowser) {
                unawaited(openDevtoolsPage(_devtoolsUrl));
              }
            }

            _logger.detail('\t: $line');
          })
          .disposedBy(scope);

      await completer.future;
    });
  }

  /// Connects to app's logs. Returns a [Future] that completes when the logs
  /// are connected.
  @visibleForTesting
  Future<void> logs(
    String deviceId, {
    required FlutterCommand flutterCommand,
    Completer<String?>? observationUrlCompleter,
  }) async {
    await _disposeScope.run((scope) async {
      _logger.detail('Logs: waiting for them...');
      final process =
          await _processManager.start(
              [
                ...[flutterCommand.executable, ...flutterCommand.arguments],
                '--no-version-check',
                '--suppress-analytics',
                'logs',
                '--device-id',
                deviceId,
              ],
              runInShell: true,
              workingDirectory: projectRoot,
            )
            ..disposedByTree(scope);

      final completer = Completer<void>();
      scope.addDispose(() {
        completer.maybeComplete();
        observationUrlCompleter?.maybeComplete();
      });

      _reportExit(process, scope, 'flutter logs', (code, _) {
        final summary = _exitSummary('flutter logs', code);
        if (!completer.isCompleted) {
          _logger.err('Logs are not available: $summary');
          completer.maybeComplete();
        }

        if (observationUrlCompleter case final urlCompleter?
            when !urlCompleter.isCompleted) {
          urlCompleter.completeError(
            ToolExit('$summary before reporting the Dart VM service URL'),
          );
        }
      });

      process
          .listenStdOut((line) {
            final urlCompleter = observationUrlCompleter;
            if (line.contains('Dart VM service') &&
                urlCompleter != null &&
                !urlCompleter.isCompleted) {
              urlCompleter.complete(getObservationUrl(line));
            }
            if (line.startsWith('Showing ') && line.endsWith('logs:')) {
              _logger.success('Hot Restart: logs connected');
              _logsActive = true;

              if (!_hotRestartActive) {
                _logger.warn('Hot Restart: not attached to the app yet');
              }
              completer.maybeComplete();
            }

            // Skip the log line that contains "PATROL_LOG" prefix
            const patrolLogPrefix = 'PATROL_LOG';
            if (line.contains(patrolLogPrefix)) {
              return;
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
          })
          .disposedBy(scope);

      await completer.future;
    });
  }

  /// Forwards the process stderr and, once it exits, hands [onExit] its exit
  /// code and a description of that exit that ends with the stderr tail.
  ///
  /// The lines explaining an exit can still be in flight when its exit code
  /// arrives, so the description is built once stderr drains. Only the tail is
  /// kept: a long session can produce thousands of lines.
  void _reportExit(
    io.Process process,
    DisposeScope scope,
    String command,
    void Function(int code, String reason) onExit,
  ) {
    final stderrLines = <String>[];
    final drained = Completer<void>();

    process
        .listenStdErr((line) {
          if (line.startsWith('Waiting for another flutter command')) {
            // This is a warning that we can ignore
            return;
          }
          stderrLines.add(line);
          if (stderrLines.length > _maxStderrLines) {
            stderrLines.removeAt(0);
          }
          _logger.err('\t$line');
        }, onDone: drained.maybeComplete)
        .disposedBy(scope);

    process.exitCode.then((code) async {
      await drained.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {},
      );
      onExit(code, _describeExit(command, code, stderrLines));
    });
  }

  static const _maxStderrLines = 20;

  String _describeExit(String command, int code, List<String> stderrLines) {
    final lines = stderrLines.where((line) => line.trim().isNotEmpty);
    final reason = lines.isEmpty ? '' : ':\n\t${lines.join('\n\t')}';
    return '${_exitSummary(command, code)}$reason';
  }

  static String _exitSummary(String command, int code) =>
      '`$command` exited with code $code';

  /// Enables interactive mode. Returns the previous stdin modes.
  StdinModes enableInteractiveMode() {
    final stdinModes = StdinModes(
      echoMode: io.stdin.echoMode,
      lineMode: io.stdin.lineMode,
    );

    // Prevents keystrokes from being printed automatically. Needs to be
    // disabled for lineMode to be disabled too.
    io.stdin.echoMode = false;

    try {
      // Causes the stdin stream to provide the input as soon as it arrives (one
      // key press at a time).
      io.stdin.lineMode = false;
    } on io.StdinException {
      _restoreEchoMode(stdinModes.echoMode);
      rethrow;
    }

    _logger.detail('Interactive shell mode enabled.');

    return stdinModes;
  }

  void _restoreEchoMode(bool echoMode) {
    try {
      io.stdin.echoMode = echoMode;
    } on io.StdinException catch (err) {
      _logger.detail('Could not restore echo mode: $err');
    }
  }

  void revertInteractiveMode(StdinModes stdinModes) {
    // Windows allows setting echoMode only while lineMode is enabled.
    // stdin may already be closed (e.g. after Ctrl+C); the terminal is going
    // away anyway, so a failure here is harmless.
    try {
      io.stdin.lineMode = stdinModes.lineMode;
    } on io.StdinException catch (err) {
      _logger.detail('Failed to revert interactive shell mode: $err');
      return;
    }
    _restoreEchoMode(stdinModes.echoMode);

    _logger.detail('Interactive shell mode disabled.');
  }

  /// Opens [url] in the system browser.
  Future<void> openDevtoolsPage(String url) async {
    io.Process? process;
    switch (_platform.operatingSystem) {
      case NativePlatform.macOS:
        process = await _processManager.start(['open', url]);
      case NativePlatform.windows:
        process = await _processManager.start(['cmd', '/c', 'start', '', url]);
      case NativePlatform.linux:
        process = await _processManager.start(['xdg-open', url]);
    }

    await process?.exitCode;
  }
}

/// Rewrites the DevTools URL Flutter prints into the Patrol extension page.
String getDevtoolsUrl(String line) {
  final rawUrl = getObservationUrl(line);
  final uri = Uri.parse(rawUrl);
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList()
    ..add('patrol_ext');
  return uri.replace(pathSegments: segments).toString();
}

/// Returns the URL that [line] carries, e.g. the Dart VM service URL from
/// "The Dart VM service is listening on http://…".
String getObservationUrl(String line) {
  final startIndex = line.indexOf('http');
  if (startIndex == -1) {
    throw FormatException(
      'Could not find a valid URL starting with "http" in line: "$line"',
    );
  }
  return line.substring(startIndex);
}

class StdinModes {
  StdinModes({required this.echoMode, required this.lineMode});

  final bool echoMode;
  final bool lineMode;
}
