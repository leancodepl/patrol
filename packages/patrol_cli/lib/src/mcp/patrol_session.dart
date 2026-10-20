import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:adb/adb.dart';
import 'package:args/args.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/commands/develop_session_factory.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';

import 'device_lister.dart';
import 'device_selection.dart';
import 'flutter_command_resolver.dart';
import 'log_streaming.dart';

/// An [io.Stdout] wrapper that forwards writes to [_inner] (e.g. stderr) and
/// also captures complete lines, invoking [_onLine] for each one.
/// This lets us redirect mason_logger output away from the JSON-protocol stdout
/// while still capturing it for the patrol.log file and output buffer.
class _CapturingStdout implements io.Stdout {
  _CapturingStdout(this._inner, this._onLine);

  final io.Stdout _inner;
  final void Function(String line) _onLine;
  final _buffer = StringBuffer();

  void _processChunk(String text) {
    // Split on newlines, buffering incomplete lines
    final parts = text.split('\n');
    for (var i = 0; i < parts.length; i++) {
      _buffer.write(parts[i]);
      if (i < parts.length - 1) {
        // We hit a newline boundary -- emit the complete line
        final line = _buffer.toString();
        _buffer.clear();
        if (line.isNotEmpty) {
          _onLine(line);
        }
      }
    }
  }

  @override
  void write(Object? object) {
    final text = '$object';
    _inner.write(text);
    _processChunk(text);
  }

  @override
  void writeln([Object? object = '']) {
    final text = '$object';
    _inner.writeln(text);
    _processChunk('$text\n');
  }

  @override
  void writeAll(Iterable<Object?> objects, [String sep = '']) {
    final text = objects.join(sep);
    _inner.writeAll(objects, sep);
    _processChunk(text);
  }

  @override
  void writeCharCode(int charCode) {
    _inner.writeCharCode(charCode);
    _processChunk(String.fromCharCode(charCode));
  }

  @override
  void add(List<int> data) {
    _inner.add(data);
    _processChunk(utf8.decode(data, allowMalformed: true));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _inner.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<List<int>> stream) => _inner.addStream(stream);

  @override
  Future<void> close() {
    // Flush any partial line still sitting in the buffer.
    final remaining = _buffer.toString();
    _buffer.clear();
    if (remaining.isNotEmpty) {
      _onLine(remaining);
    }
    return _inner.close();
  }

  @override
  Future<void> get done => _inner.done;

  @override
  Encoding get encoding => _inner.encoding;

  @override
  set encoding(Encoding value) => _inner.encoding = value;

  @override
  Future<void> flush() => _inner.flush();

  @override
  bool get hasTerminal => _inner.hasTerminal;

  @override
  String get lineTerminator => _inner.lineTerminator;

  @override
  set lineTerminator(String value) => _inner.lineTerminator = value;

  @override
  io.IOSink get nonBlocking => _inner.nonBlocking;

  @override
  bool get supportsAnsiEscapes => _inner.supportsAnsiEscapes;

  @override
  int get terminalColumns => _inner.terminalColumns;

  @override
  int get terminalLines => _inner.terminalLines;
}

enum TestState {
  idle,
  running,
  finishedPassed,
  finishedFailed;

  String get summary => switch (this) {
    finishedPassed => 'Tests completed successfully ✅',
    finishedFailed => 'Tests failed ❌',
    running => 'Tests are currently running...',
    idle => 'Patrol session is idle',
  };
}

enum SessionCommand {
  hotRestart('R'),
  quit('Q');

  const SessionCommand(this.value);

  final String value;
}

class PatrolStatus {
  const PatrolStatus({
    required this.isDevelopRunning,
    required this.projectRoot,
    required this.testState,
    this.versionWarning,
    required this.output,
    this.currentTestFile,
    this.warning,
    this.deviceSelectionNote,
    this.deviceName,
    this.deviceId,
    this.devicePlatform,
  });

  final bool isDevelopRunning;

  /// The project this server is anchored to. Fixed when the server starts, so a
  /// caller working across checkouts can tell which one a result came from.
  final String projectRoot;

  /// Set when the project's `patrol` is not one this CLI can drive.
  final String? versionWarning;

  final TestState testState;
  final String output;
  final String? currentTestFile;
  final String? warning;
  final String? deviceSelectionNote;
  final String? deviceName;
  final String? deviceId;
  final String? devicePlatform;

  String get summary => testState.summary;

  Map<String, Object> toMap() => {
    'isDevelopRunning': isDevelopRunning,
    'projectRoot': projectRoot,
    'versionWarning': ?versionWarning,
    'testState': testState.name,
    'currentTestFile': ?currentTestFile,
    'warning': ?warning,
    'deviceSelectionNote': ?deviceSelectionNote,
    'deviceName': ?deviceName,
    'deviceId': ?deviceId,
    'devicePlatform': ?devicePlatform,
    'output': output,
    'summary': summary,
  };
}

/// Creates the [DevelopService] a session drives. Injectable so the session can
/// be tested without building an app.
typedef DevelopServiceFactory =
    DevelopService Function({
      required String projectRoot,
      required DisposeScope disposeScope,
      required Stream<List<int>> stdin,
      Future<void> Function()? onExit,
      void Function(TestCompletionResult result)? onTestsCompleted,
      void Function(Entry entry)? onLogEntry,
      bool verbose,
    });

final class PatrolSession {
  PatrolSession({
    required this.flutterProjectPath,
    required Logger logger,
    io.Stdout? diagnosticSink,
    this.developArgs = const [],
    this.logFile,
    this.showTerminal = false,
    DevelopServiceFactory? developServiceFactory,
    Duration hotRestartReadyTimeout = const Duration(seconds: 90),
  }) : _hotRestartReadyTimeout = hotRestartReadyTimeout,
       _logger = logger,
       _diagnosticSink = diagnosticSink ?? io.stderr,
       _createDevelopService =
           developServiceFactory ?? DevelopSessionFactory.create;

  final String flutterProjectPath;

  /// Extra arguments for `patrol develop`, already split into an argument list.
  final List<String> developArgs;

  /// Where session logs go, or null for `patrol.log` in the project root.
  final String? logFile;

  final bool showTerminal;

  final Logger _logger;
  final DevelopServiceFactory _createDevelopService;

  /// Where diagnostics go while the real stdout carries JSON-RPC. Captured at
  /// construction, before any [io.IOOverrides] zone is installed.
  final io.Stdout _diagnosticSink;

  /// Install as `stdout` for the whole MCP command: forwards every write to
  /// [_diagnosticSink] and captures the lines for `status` and `patrol.log`.
  late final io.Stdout capturingStdout = _CapturingStdout(
    _diagnosticSink,
    _pushOutput,
  );

  static const _maxOutputLines = 200;

  /// Matches patrol_cli's own default; only used when a session has not
  /// reported its port yet.
  static const _defaultTestServerPort = 8081;

  /// How long a hot restart waits for `flutter attach` to become ready. Long
  /// enough for a slow iOS attach, short enough to report back instead of
  /// hanging for the caller's whole run timeout.
  final Duration _hotRestartReadyTimeout;

  var _isRunning = false;
  String? _currentTestFile;
  final _outputs = <String>[];
  TestState _testState = TestState.idle;

  /// Set while quitting so a backend exit we caused isn't reported as a crash.
  var _quitRequested = false;

  /// Warning attached to the next returned status (e.g. unexpected app exit).
  String? _finishWarning;

  Completer<void>? _finishCompleter;
  DisposeScope? _disposeScope;
  StreamController<List<int>>? _stdinController;
  DevelopService? _developService;
  int? _testServerPort;

  /// A note about device selection surfaced in the next status (e.g. which
  /// device was auto-selected, or that a `device` argument was overridden).
  String? _deviceSelectionNote;

  final _logStreaming = LogStreaming.instance;

  /// The device discovered by the last [startAndWait] call.
  Device? get device => _developService?.device;
  int? get testServerPort => _testServerPort;

  var _portForwarded = false;

  /// Read once per server: the answer cannot change while it runs.
  late final String? _versionWarning = patrolIncompatibility(
    PubspecReader(
      projectRoot: const LocalFileSystem().directory(flutterProjectPath),
    ).getPatrolVersion(),
  );

  /// Makes the native automator reachable on `localhost:[testServerPort]`.
  ///
  /// Android needs an `adb forward`; iOS simulator traffic is already local. The
  /// forward is torn down with the session, because a leftover one keeps the
  /// host port pointing at the Android device — a later iOS session then reads
  /// that device's tree instead of the simulator's, with no error to show for it.
  Future<void> ensureNativeAutomatorReachable() async {
    final device = this.device;
    final scope = _disposeScope;
    if (_portForwarded ||
        device == null ||
        scope == null ||
        device.targetPlatform != TargetPlatform.android) {
      return;
    }

    final port = _testServerPort ?? _defaultTestServerPort;
    scope.addDispose(
      await Adb().forwardPorts(
        fromHost: port,
        toDevice: port,
        device: device.id,
      ),
    );
    _portForwarded = true;
  }

  /// Returns null if started successfully, or a warning message if blocked
  Future<String?> _start(String testFile, {String? device}) async {
    // A `patrol` this CLI cannot drive stops the run, as it does under `patrol
    // develop`. `--no-check-compatibility` in the develop args opts out, the
    // same flag the CLI takes.
    if (_versionWarning case final incompatible?
        when !developArgs.contains('--no-check-compatibility')) {
      return incompatible;
    }

    _deviceSelectionNote = null;
    if (_isRunning) {
      if (_currentTestFile != testFile) {
        return 'Patrol session is already running "$_currentTestFile". '
            'Cannot start different test "$testFile". '
            'Use quit first or run the same test file.';
      }
      // Same test file - hot restart. The device can't change on hot restart.
      if (device != null) {
        _deviceSelectionNote =
            'Device "$device" ignored: hot-restarting the running session on '
            '${this.device?.name ?? 'the current device'}. Use quit '
            'first to switch devices.';
      }
      if (await _waitForHotRestartReady() case final blocked?) {
        return blocked;
      }
      sendCommand(SessionCommand.hotRestart);
      return null;
    }

    await _startLogStreamingAndTerminal();

    final resolvedCwd = p.canonicalize(flutterProjectPath);

    // Parse additional flags using the same ArgParser definitions as the CLI.
    // This supports both develop-specific flags and global flags (e.g.
    // --verbose, --flutter-command) so that PATROL_FLAGS works with everything
    // that `patrol develop` accepts.
    final flagParts = [
      ...developArgs,
      // With the check on, every Android run measured here ended with no
      // PATROL_LOG entries at all and a failure the test never had. It spawns
      // `flutter doctor --verbose` before the build, which is the suspected
      // cause, but only the effect is established. Opt back in by passing
      // `--check-compatibility` to the command.
      '--no-check-compatibility',
    ];

    final flutterResolution = FlutterCommandResolver().resolve(
      projectRoot: resolvedCwd,
    );
    final flutterCommand = flutterResolution.command;

    // First parse: see what the develop args already specify.
    final DevelopOptions flagOptions;
    final ArgResults globalResults;
    try {
      (flagOptions, globalResults) = DevelopOptions.parseArgs(
        flagParts,
        target: testFile,
        flutterCommand: flutterCommand,
      );
    } on FormatException catch (err) {
      // Reaches the caller as a refusal; otherwise it escapes the tool callback
      // and the client is told only "Tool execution failed".
      return 'Cannot start: ${err.message} Check the develop flags this server '
          'was started with.';
    }
    final verbose = globalResults['verbose'] as bool? ?? false;

    // Resolve the device. Precedence: a `--device` in the develop args >
    // `device` argument > auto-selection.
    if (flagOptions.devices.isNotEmpty) {
      if (device != null) {
        _deviceSelectionNote =
            'Ignored device "$device": the develop args already pin '
            '--device ${flagOptions.devices.join(', ')}.';
      }
    } else if (device != null) {
      flagParts.addAll(['--device', device]);
    } else {
      final List<Device> attached;
      try {
        attached = await listAttachedDevices(
          flutterCommand: flutterCommand ?? const FlutterCommand('flutter'),
        );
      } catch (err) {
        return 'Failed to detect attached devices: $err';
      }
      final selected = autoSelectDevice(attached);
      if (selected == null) {
        return 'No Android or iOS device detected. Start an emulator or '
            'simulator (or connect a device) and try again.';
      }
      flagParts.addAll(['--device', selected.id]);
      if (supportedDevices(attached).length > 1) {
        _deviceSelectionNote =
            'Auto-selected ${selected.name} (${selected.id}); '
            'pass "device" to run on a different one.';
      }
    }

    // Final parse, now including the resolved `--device` (if any).
    final (options, _) = DevelopOptions.parseArgs(
      flagParts,
      target: testFile,
      flutterCommand: flutterCommand,
    );

    // Log the effective Flutter command once (to stderr via the logging sink).
    final flagCmd = globalResults['flutter-command'] as String?;
    final effective = options.flutterCommand;
    final effectiveStr = [
      effective.executable,
      ...effective.arguments,
    ].join(' ');
    if (flagCmd != null && flagCmd.isNotEmpty) {
      _logger.info(
        'Flutter command: $effectiveStr (from --flutter-command in PATROL_FLAGS)',
      );
    } else if (flutterResolution.isWarning) {
      _logger.warn(
        'Flutter command: $effectiveStr -- ${flutterResolution.reason}',
      );
    } else {
      _logger.info(
        'Flutter command: $effectiveStr (${flutterResolution.reason})',
      );
    }
    _testServerPort = options.testServerPort;

    // Create a DisposeScope for the session lifecycle
    final disposeScope = DisposeScope();
    _disposeScope = disposeScope;

    // Create a StreamController to feed FlutterTool's stdin programmatically
    final stdinController = StreamController<List<int>>.broadcast();
    _stdinController = stdinController;

    // Use DevelopSessionFactory to wire up all CLI components in one call,
    // with a custom onExit that signals a completer instead of exit(0).
    final exitCompleter = Completer<void>();
    final developService = _createDevelopService(
      projectRoot: resolvedCwd,
      disposeScope: disposeScope,
      stdin: stdinController.stream,
      verbose: verbose,
      onExit: () async {
        if (!exitCompleter.isCompleted) {
          exitCompleter.complete();
        }
      },
      onLogEntry: _handleEntry,
      onTestsCompleted: _handleTestsCompleted,
    );
    _developService = developService;

    _isRunning = true;
    _cleanupFuture = null;
    _currentTestFile = testFile;
    _testState = TestState.running;
    _quitRequested = false;
    _finishWarning = null;
    _outputs.clear();
    // Create the completer eagerly so callbacks can signal it even if
    // test completion happens before _waitForFinish is called.
    _finishCompleter = Completer<void>();

    // Run the develop service in the background.
    // Test completion is detected by structured callbacks,
    // NOT by developService.run() returning (the process stays alive for
    // hot restart in develop mode).
    _runDevelopSession(developService, options, exitCompleter);

    return null;
  }

  void _runDevelopSession(
    DevelopService developService,
    DevelopOptions options,
    Completer<void> exitCompleter,
  ) {
    // Fire-and-forget: developService.run() blocks for the entire develop
    // session (gradle/xcodebuild + flutter attach stay alive for hot restart).
    // Test completion is detected by callbacks, not by run() returning.
    unawaited(
      Future.any([developService.run(options), exitCompleter.future])
          .then((_) {
            // Session ended (e.g. user sent quit). If tests haven't already
            // been marked as done by callbacks, mark idle.
            if (_testState == TestState.running) {
              _testState = TestState.idle;
            }
            _completeFinish();
            unawaited(_cleanup());
          })
          .catchError((Object err, StackTrace st) {
            // patrol_cli throws ToolExit for expected, actionable failures such
            // as a `patrol` version the CLI can't drive. Those carry a message
            // written for the user, so surface it as the status warning rather
            // than a stack trace the agent has to interpret.
            if (err is ToolExit) {
              _finishWarning = err.message;
              _pushOutput(err.message);
            } else {
              _logger.warn('Develop session error: $err\n$st');
              _pushOutput('ERROR: $err');
            }
            if (_testState == TestState.running) {
              _testState = TestState.finishedFailed;
            }
            _completeFinish();
            unawaited(_cleanup());
          }),
    );
  }

  Future<void>? _cleanupFuture;

  /// Stops an active develop session and waits for its child processes to be
  /// torn down. Safe to call when idle or repeatedly.
  Future<void> dispose() async {
    if (_isRunning) {
      sendCommand(SessionCommand.quit);
    }
    // Await any in-flight teardown -- the quit above, or one the session
    // already started on its own -- so children are reaped before we exit.
    final cleanup = _cleanupFuture;
    if (cleanup != null) {
      await cleanup;
    }
  }

  /// Cleans up the session. Memoized -- callers share one teardown.
  Future<void> _cleanup() => _cleanupFuture ??= _doCleanup();

  Future<void> _doCleanup() async {
    // Capture this session's resources before the first await -- a new session
    // could reassign these fields while we're awaiting below.
    final scope = _disposeScope;
    final stdinController = _stdinController;
    final service = _developService;
    _isRunning = false;
    _currentTestFile = null;
    _testServerPort = null;
    _deviceSelectionNote = null;
    _portForwarded = false;

    await _logStreaming.stopLogging();

    try {
      if (scope != null && !scope.disposed) {
        await scope.dispose();
      }
    } catch (err) {
      _logger.detail('Error disposing scope: $err');
    }
    await stdinController?.close();
    // Drop the service, or `device` would keep naming the dead session's device
    // and screenshot/native-tree would act on it instead of reporting that there
    // is no session. Guarded: a session started while we were awaiting owns the
    // field now.
    if (_developService == service) {
      _developService = null;
    }
    _logger.detail('Develop session ended');
  }

  void _pushOutput(String line) {
    _outputs.add(line);
    if (_outputs.length > _maxOutputLines) {
      _outputs.removeRange(0, _outputs.length - _maxOutputLines);
    }

    final cleanLine = _normalizeLine(line);
    if (cleanLine.isNotEmpty) {
      _logStreaming.writeLog(cleanLine);
    }
  }

  /// Structured signal from patrol framework (via PATROL_LOG ConfigEntry) that
  /// all tests were executed in develop mode.
  void _handleEntry(Entry entry) {
    if (entry is TestEntry &&
        entry.status == TestEntryStatus.failure &&
        _testState == TestState.running) {
      _testState = TestState.finishedFailed;
      _completeFinish();
      return;
    }

    if (entry is ConfigEntry &&
        entry.config[ConfigEntry.developCompletedKey] == true &&
        _testState == TestState.running) {
      _testState = TestState.finishedPassed;
      _completeFinish();
    }
  }

  /// Backend exit signal from [DevelopService].
  ///
  /// In develop mode runs stay alive for hot restart, so a backend exit while
  /// running means the app shut down early -- report it as a failure. Our own
  /// quit also exits it but flips to idle first; [_quitRequested] covers the race.
  void _handleTestsCompleted(TestCompletionResult result) {
    if (_quitRequested || _testState != TestState.running) {
      return;
    }

    _testState = TestState.finishedFailed;
    // Surface the underlying error (backend threw rather than exiting cleanly)
    // so it isn't swallowed by the generic warning below.
    final error = result.error;
    if (error != null) {
      _pushOutput('ERROR: $error');
      _logger.err('Backend exit error: $error');
    }
    _finishWarning =
        'The app stopped without the test reporting completion, so there is no '
        'test result. A failing assertion is reported as a failed test, so look '
        'in the output below for something else: a crash, a build that did not '
        'finish, or a toolchain that never connected.';
    _completeFinish();
  }

  String _normalizeLine(String line) {
    return line.replaceAll(RegExp(r'\x1B\[[0-9;?]*[ -/]*[@-~]'), '').trim();
  }

  /// Returns null once a hot restart will be acted on, or a message explaining
  /// why it will not be sent.
  ///
  /// `flutter attach` becomes ready only after it prints its key-commands
  /// banner, which races the test completion signal — that one travels on the
  /// separate `flutter logs` stream and wins on iOS. A restart sent in that
  /// window is discarded, so without this wait the tool would report a restart
  /// it never performed and the run would then time out or be blamed on the app
  /// exiting.
  Future<String?> _waitForHotRestartReady() async {
    final service = _developService;
    if (service == null) {
      return null;
    }

    try {
      await service.hotRestartReady.timeout(_hotRestartReadyTimeout);
      return null;
    } on TimeoutException {
      return 'The session is running "$_currentTestFile" but it did not become '
          'ready for hot restart within '
          '${_hotRestartReadyTimeout.inSeconds}s, so no restart was sent. '
          'Quit and run again.';
    }
  }

  String sendCommand(SessionCommand command) {
    if (command == SessionCommand.quit) {
      final controller = _stdinController;
      if (!_isRunning || controller == null) {
        throw StateError('No active patrol session');
      }

      _quitRequested = true;
      controller.add('Q'.codeUnits);
      _testState = TestState.idle;
      _completeFinish();
      unawaited(_cleanup());

      return 'Quit command sent to patrol session';
    }

    if (command == SessionCommand.hotRestart) {
      final controller = _stdinController;
      if (!_isRunning || controller == null) {
        throw StateError('No active patrol session');
      }

      try {
        controller.add('R'.codeUnits);
      } catch (err) {
        _logger.warn('Failed to send hot restart: $err');
        throw StateError('Failed to send hot restart to patrol session: $err');
      }

      _outputs.clear();
      _testState = TestState.running;
      _finishWarning = null;
      // Complete the old completer so any previous waiters are unblocked, then
      // immediately create a fresh one. This avoids a race where callbacks
      // could fire between null-ing and lazy re-creation in _waitForFinish.
      _completeFinish();
      _finishCompleter = Completer<void>();

      return 'Hot restart sent to patrol session';
    }

    throw StateError('Unknown command: ${command.value}');
  }

  PatrolStatus getStatus({String? overrideWarning}) {
    final dev = _developService?.device;
    return PatrolStatus(
      isDevelopRunning: _isRunning,
      projectRoot: flutterProjectPath,
      versionWarning: _versionWarning,
      testState: _testState,
      output: _formatLogs(_outputs),
      currentTestFile: _currentTestFile,
      warning: overrideWarning ?? _finishWarning,
      deviceSelectionNote: _deviceSelectionNote,
      deviceName: dev?.name,
      deviceId: dev?.id,
      devicePlatform: dev?.targetPlatform.name,
    );
  }

  Future<PatrolStatus> _waitForFinish({Duration? timeout}) async {
    if (!_isRunning ||
        _testState == TestState.finishedPassed ||
        _testState == TestState.finishedFailed) {
      return getStatus();
    }

    _finishCompleter ??= Completer<void>();

    try {
      final future = _finishCompleter!.future;
      if (timeout != null) {
        await future.timeout(timeout);
      } else {
        await future;
      }
    } on TimeoutException {
      // The run didn't finish in time but is still running in the background.
      // Surface the timeout distinctly, not a `running` snapshot the caller
      // can't tell apart from a normal in-progress run.
      return getStatus(
        overrideWarning:
            'Run timed out, but the test is still running in the background. '
            'Call status to check progress, or quit to stop it.',
      );
    }

    return getStatus();
  }

  String _formatLogs(List<String> logs) {
    if (logs.isEmpty) {
      return 'No output available';
    }

    return logs.join('\n');
  }

  void _completeFinish() {
    if (_finishCompleter case final completer? when !completer.isCompleted) {
      completer.complete();
    }
  }

  /// Runs [testFile] and waits for it to finish.
  ///
  /// `started` is false when the run was refused (another test is loaded, or the
  /// session never became ready for a hot restart). The status then describes
  /// the session as it already was — in particular `testState` still refers to
  /// the previous run — so callers must report a refusal as an error rather than
  /// pass that state on as this run's outcome.
  Future<({PatrolStatus status, bool started})> startAndWait(
    String testFile, {
    Duration? timeout,
    String? device,
  }) async {
    final refusal = await _start(testFile, device: device);
    if (refusal != null) {
      return (status: getStatus(overrideWarning: refusal), started: false);
    }
    return (status: await _waitForFinish(timeout: timeout), started: true);
  }

  /// Automatically start log streaming and optionally launch terminal
  Future<void> _startLogStreamingAndTerminal() async {
    try {
      final logPath = await _logStreaming.startLogging(
        flutterProjectPath,
        logFile: logFile,
      );

      if (showTerminal && io.Platform.isMacOS) {
        await io.Process.run('osascript', [
          '-e',
          'tell application "Terminal"',
          '-e',
          "do script \"echo 'Patrol Test Logs - Live Stream'; echo ''; tail -f '$logPath'\" in front window",
          '-e',
          'end tell',
        ]);
      } else if (!showTerminal) {
        _logger.info('Log file created at: $logPath');
      } else {
        _logger.info(
          'Log file created at: $logPath '
          '(automatic terminal launch is only available on macOS)',
        );
      }
    } catch (err) {
      // Don't fail the entire operation if log streaming fails
      _logger.warn('Failed to start log streaming or terminal: $err');
    }
  }
}
