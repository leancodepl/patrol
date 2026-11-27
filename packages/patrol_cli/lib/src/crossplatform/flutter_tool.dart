import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:meta/meta.dart';
import 'package:path/path.dart' show basename;
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
    @visibleForTesting this._restartRejectionGrace = const Duration(seconds: 2),
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

  /// How long a restart that printed compiler errors waits for `flutter
  /// attach` to report it rejected. Its full restart prints 'Restarted
  /// application' whether or not the program compiled, and the rejection only
  /// after that.
  final Duration _restartRejectionGrace;
  Timer? _restartSettleTimer;

  /// Lets `t` switch the test file the session runs; the key does nothing
  /// while this is null.
  TestSwitcher? testSwitcher;

  String get _keyCommands => [
    'Patrol develop key commands:',
    'r Hot restart',
    if (testSwitcher != null) 't Switch test file',
    'h Print this help message',
    'q Quit (terminate the process and application on the device)',
  ].join('\n');

  var _hotRestartActive = false;
  var _logsActive = false;
  var _logsSkipped = false;
  var _devtoolsUrl = '';
  io.Process? _attachProcess;

  /// Completes once the running `flutter attach` has connected to the app.
  Completer<void>? _attachConnected;
  var _listeningToKeys = false;

  /// How the running `flutter attach` was started, for [reattach].
  ({
    FlutterCommand flutterCommand,
    String deviceId,
    String target,
    String? debugUrl,
    String? appId,
    bool removeAdbForwards,
    Future<void> Function()? onQuit,
  })?
  _lastAttach;
  var _pendingHotRestart = false;
  void Function()? _onRestartCompleted;
  void Function(String compilerOutput)? _onRestartFailed;
  StringBuffer? _restartErrors;

  /// Sends a Hot Restart to the attached app - the same as pressing `r`.
  ///
  /// If `flutter attach` hasn't connected yet the request is queued and sent
  /// as soon as it does. Dropping it (the previous behaviour) left callers
  /// such as patrol_mcp waiting for a test run that never started.
  ///
  /// [onCompleted] fires once `flutter attach` reports the restart as
  /// completed ('Restarted application ...'), not when it is requested.
  /// Callers use it to tell output of the old and the new program apart.
  /// [onFailed] fires instead when the restart is rejected (compile error),
  /// with what `flutter attach` printed to stderr since the request: the
  /// compiler's diagnostics. Exactly one of the two fires, at most once; after
  /// compiler errors, a completed restart is reported up to
  /// [_restartRejectionGrace] late.
  void hotRestart({
    void Function()? onCompleted,
    void Function(String compilerOutput)? onFailed,
  }) {
    _restartSettleTimer?.cancel();
    _onRestartCompleted = onCompleted;
    _onRestartFailed = onFailed;
    _restartErrors = StringBuffer();
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

  void _onRestartedApplication() {
    if (_restartErrors?.isEmpty ?? true) {
      _settleRestart(completed: true);
      return;
    }
    _restartSettleTimer?.cancel();
    _restartSettleTimer = Timer(
      _restartRejectionGrace,
      () => _settleRestart(completed: true),
    );
  }

  void _settleRestart({required bool completed}) {
    _restartSettleTimer?.cancel();
    _restartSettleTimer = null;
    final onCompleted = _onRestartCompleted;
    final onFailed = _onRestartFailed;
    final errors = _restartErrors?.toString().trim() ?? '';
    _onRestartCompleted = null;
    _onRestartFailed = null;
    _restartErrors = null;
    if (completed) {
      onCompleted?.call();
    } else {
      onFailed?.call(errors);
    }
  }

  final _hotRestartReady = Completer<void>();

  /// Completes once `flutter attach` will act on a hot restart.
  ///
  /// A restart requested earlier is held until then, so a caller that reports
  /// on the restart waits for this before claiming it was sent.
  Future<void> get hotRestartReady => _hotRestartReady.future;

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

  Future<String> _readDebugUrlFromFlutterLogs(
    String deviceId, {
    required FlutterCommand flutterCommand,
  }) async {
    final urlCompleter = Completer<String>();
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

  /// Replaces the running `flutter attach` with one that compiles the program
  /// with [dartDefines], and hot restarts through it as [hotRestart] does. The
  /// app keeps running: a terminated `flutter attach` only detaches from it.
  ///
  /// The old process has to be gone before the new one starts, because on its
  /// way out it deletes the app's DevFS on the device, which the new one uses.
  Future<void> reattach({
    required Map<String, String> dartDefines,
    void Function()? onCompleted,
    void Function(String compilerOutput)? onFailed,
  }) async {
    final last = _lastAttach;
    final old = _attachProcess;
    if (last == null || old == null) {
      throw StateError('Not attached to the app');
    }

    _hotRestartActive = false;
    await old.killTree();
    await old.exitCode.timeout(
      _reattachExitTimeout,
      onTimeout: () {
        old.kill(io.ProcessSignal.sigkill);
        return -1;
      },
    );

    hotRestart(onCompleted: onCompleted, onFailed: onFailed);
    await attach(
      flutterCommand: last.flutterCommand,
      deviceId: last.deviceId,
      target: last.target,
      debugUrl: last.debugUrl,
      appId: last.appId,
      dartDefines: dartDefines,
      openBrowser: false,
      removeAdbForwards: last.removeAdbForwards,
      onQuit: last.onQuit,
    );
  }

  static const _reattachExitTimeout = Duration(seconds: 10);

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
    _lastAttach = (
      flutterCommand: flutterCommand,
      deviceId: deviceId,
      target: target,
      debugUrl: debugUrl,
      appId: appId,
      removeAdbForwards: removeAdbForwards,
      onQuit: onQuit,
    );
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

      final completer = _attachConnected = Completer<void>();
      scope.addDispose(() {
        if (!completer.isCompleted) {
          _logger.detail('Killed before attached to the app');
          completer.complete();
        }
      });

      if (!_listeningToKeys) {
        _listeningToKeys = true;
        _listenToKeys(scope, target: target, onQuit: onQuit);
      }

      _logger.detail('Hot Restart: waiting for attach to the app...');
      process
          .listenStdOut((line) {
            if (line == 'Flutter run key commands.' && !completer.isCompleted) {
              _logger.success(
                'Hot Restart: attached to the app\n$_keyCommands',
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
              completer.complete();
            }

            if (line.startsWith('Restarted application')) {
              _onRestartedApplication();
            }

            if (line.startsWith('Try again after fixing the above error')) {
              _settleRestart(completed: false);
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

      process
          .listenStdErr((line) {
            if (line.startsWith('Waiting for another flutter command')) {
              // This is a warning that we can ignore
              return;
            }
            _restartErrors?.writeln(line);
            _logger.err('\t$line');
          })
          .disposedBy(scope);

      await completer.future;
    });
  }

  /// Handles the session's keys. Listens once, for every `flutter attach` the
  /// session runs: stdin takes a single listener.
  void _listenToKeys(
    DisposeScope scope, {
    required String target,
    required Future<void> Function()? onQuit,
  }) {
    var quitting = false;

    // The test files offered after `t`, while the user is choosing one.
    List<String>? choices;
    var typed = '';

    Future<void> onChoiceKey(List<String> offered, String char) async {
      if (RegExp('[0-9]').hasMatch(char)) {
        typed += char;
        return;
      }
      choices = null;
      final index = int.tryParse(typed);
      typed = '';
      if ((char != '\r' && char != '\n') || index == null) {
        _logger.info('Test switch cancelled.');
        return;
      }
      if (index < 1 || index > offered.length) {
        _logger.warn('No test file numbered $index.');
        return;
      }
      final testFile = offered[index - 1];
      final switcher = testSwitcher;
      if (switcher == null) {
        return;
      }
      _logger.success('Hot Restart into $testFile...');
      final failure = await switcher.switchTo(testFile);
      if (failure != null) {
        _logger.warn(
          'Still running the previous test file: '
          '${failure.split('\n').first}',
        );
      }
    }

    void offerTestFiles(TestSwitcher switcher) {
      final offered = switcher.listTests();
      if (offered.isEmpty) {
        _logger.warn('No test files to switch to.');
        return;
      }
      choices = offered;
      _logger.info(
        [
          'Type the number of the test file to run, then Enter:',
          for (final (i, file) in offered.indexed) '${i + 1} $file',
        ].join('\n'),
      );
    }

    _stdin
        .listen((event) async {
          if (choices case final offered?) {
            for (final char in String.fromCharCodes(event).split('')) {
              if (choices == null) {
                break;
              }
              await onChoiceKey(offered, char);
            }
            return;
          }

          final char = String.fromCharCode(event.first);
          if ((char == 't' || char == 'T') && testSwitcher != null) {
            offerTestFiles(testSwitcher!);
          } else if (char == 'r' || char == 'R') {
            if (!_hotRestartActive) {
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
            _attachProcess?.stdin.add('R'.codeUnits);
          } else if (char == 'h' || char == 'H') {
            final helpText = StringBuffer(_keyCommands);

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
            if (_attachConnected case final connected?
                when !connected.isCompleted) {
              connected.complete();
            }

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
  }

  /// Connects to app's logs. Returns a [Future] that completes when the logs
  /// are connected.
  @visibleForTesting
  Future<void> logs(
    String deviceId, {
    required FlutterCommand flutterCommand,
    Completer<String>? observationUrlCompleter,
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
        if (!completer.isCompleted) {
          completer.complete();
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
              completer.complete();
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

      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      await completer.future;
    });
  }

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

/// What `t` in a develop session needs to switch the test file it runs.
class TestSwitcher {
  const TestSwitcher({required this.listTests, required this.switchTo});

  /// The test files to offer, as the user names them.
  final List<String> Function() listTests;

  /// Hot-restarts the session into the test file. Returns null once it runs
  /// it, otherwise why it does not.
  final Future<String?> Function(String testFile) switchTo;
}

class StdinModes {
  StdinModes({required this.echoMode, required this.lineMode});

  final bool echoMode;
  final bool lineMode;
}
