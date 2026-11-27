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
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:process/process.dart';

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

final _ansiEscape = RegExp(r'\x1B\[[0-9;?]*[ -/]*[@-~]');

enum SessionCommand {
  hotRestart('R'),
  quit('Q');

  const SessionCommand(this.value);

  final String value;
}

class PatrolStatus {
  const PatrolStatus({
    required this.isDevelopRunning,
    this.projectRoot,
    required this.testState,
    this.versionWarning,
    required this.output,
    this.currentTestFile,
    this.warning,
    this.deviceSelectionNote,
    this.error,
    this.deviceName,
    this.deviceId,
    this.devicePlatform,
  });

  final bool isDevelopRunning;

  /// The project this result came from, so a caller working across checkouts
  /// can tell which one it is. Absent until a project resolves.
  final String? projectRoot;

  /// Set when the project's `patrol` is not one this CLI can drive.
  final String? versionWarning;

  final TestState testState;
  final String output;
  final String? currentTestFile;
  final String? warning;
  final String? deviceSelectionNote;

  /// The failure details the test reported, when it failed.
  final String? error;
  final String? deviceName;
  final String? deviceId;
  final String? devicePlatform;

  String get summary => testState.summary;

  Map<String, Object> toMap() => {
    'isDevelopRunning': isDevelopRunning,
    'projectRoot': ?projectRoot,
    'versionWarning': ?versionWarning,
    'testState': testState.name,
    'currentTestFile': ?currentTestFile,
    'warning': ?warning,
    'deviceSelectionNote': ?deviceSelectionNote,
    'error': ?error,
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

/// Reads the devices Flutter reports as attached.
typedef AttachedDevicesReader =
    Future<List<Device>> Function({required FlutterCommand flutterCommand});

/// Resolves the project a call is about, and the call's test file as that
/// project sees it.
typedef ProjectRootResolver =
    Future<ResolvedProject> Function({
      String? testFile,
      String? requestedRoot,
      bool remember,
    });

final class PatrolSession {
  PatrolSession({
    required this._resolveProjectRoot,
    required this._listAttachedDevices,
    this._processManager = const LocalProcessManager(),
    required this._logger,
    io.Stdout? diagnosticSink,
    this.developArgs = const [],
    this.logFile,
    this.showTerminal = false,
    DevelopServiceFactory? developServiceFactory,

    void Function(String root)? enterProjectDirectory,
    this._hotRestartReadyTimeout = const Duration(seconds: 90),
    this._teardownTimeout = const Duration(seconds: 30),
  }) : _enterProjectDirectory =
           enterProjectDirectory ?? ((root) => io.Directory.current = root),
       _diagnosticSink = diagnosticSink ?? io.stderr,
       _createDevelopService =
           developServiceFactory ?? DevelopSessionFactory.create;

  final ProjectRootResolver _resolveProjectRoot;
  final AttachedDevicesReader _listAttachedDevices;
  final ProcessManager _processManager;

  /// The test file as the resolved project sees it, which is not the path the
  /// caller gave when the file was named against a workspace root above it.
  String? _projectRelativeTestFile;

  String? _projectRoot;

  /// The project this session drives. Available once [ensureProjectResolved]
  /// has run, which every tool does before touching the session.
  String get flutterProjectPath =>
      _projectRoot ?? (throw StateError('Project root not resolved yet'));

  /// The project this session drives, or null before one is resolved.
  String? get projectRoot => _projectRoot;

  /// Enters the resolved project.
  ///
  /// The build reads the process's working directory. Injectable so a test does
  /// not move the test runner.
  final void Function(String root) _enterProjectDirectory;

  /// Resolves the project this call is about.
  ///
  /// Resolution needs the client's roots, which arrive with the handshake, so it
  /// cannot happen before the first call.
  ///
  /// A [testFile] pins down which project is meant, so a root resolved without
  /// one is revisited when the file turns out to live elsewhere. A live session
  /// keeps the project it started in.
  Future<void> ensureProjectResolved({
    String? testFile,
    String? requestedRoot,
  }) async {
    if (_projectRoot != null &&
        (_isRunning || (testFile == null && requestedRoot == null))) {
      return;
    }
    final resolved = await _resolveProjectRoot(
      testFile: testFile,
      requestedRoot: requestedRoot,
    );
    _projectRoot = resolved.root;
    _projectRelativeTestFile = resolved.testFile;
    _projectProblem = null;
    _enterProjectDirectory(resolved.root);
  }

  /// Records that no project could be resolved, so a status can say so instead
  /// of reporting a session that has nowhere to run.
  void noteProjectUnresolved(String reason) => _projectProblem = reason;

  String? _projectProblem;

  /// Points the session at the project this request is about, or explains why it
  /// cannot be.
  ///
  /// A session holds one project while it lives, because the app, the device and
  /// the ports belong to it. Once it is gone, a request naming another project
  /// moves the server there.
  Future<String?> _anchor({
    required String testFile,
    required String? requestedRoot,
  }) async {
    if (!_isRunning) {
      await ensureProjectResolved(
        testFile: testFile,
        requestedRoot: requestedRoot,
      );
      return null;
    }

    await ensureProjectResolved();
    if (requestedRoot == null) {
      return null;
    }
    // Resolved only to name the project in the refusal, so it is not remembered.
    final ResolvedProject requested;
    try {
      requested = await _resolveProjectRoot(
        testFile: testFile,
        requestedRoot: requestedRoot,
        remember: false,
      );
    } on ProjectResolutionException catch (err) {
      return '$err';
    }
    if (_sameDirectory(requested.root, flutterProjectPath)) {
      return null;
    }
    return 'This server is running "$_currentTestFile" in '
        '$flutterProjectPath. Quit that session before running in '
        '${requested.root}.';
  }

  /// Whether two paths lead to the same directory, symlinks included: on macOS
  /// a temporary directory is reached as both `/var/…` and `/private/var/…`.
  bool _sameDirectory(String a, String b) {
    if (p.equals(a, b)) {
      return true;
    }
    try {
      return io.Directory(a).resolveSymbolicLinksSync() ==
          io.Directory(b).resolveSymbolicLinksSync();
    } on io.FileSystemException {
      return false;
    }
  }

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

  /// How long a hot restart waits for `flutter attach` to become ready. Long
  /// enough for a slow iOS attach and shorter than the caller's run timeout, so
  /// an attach that never finishes is reported while the caller still waits.
  final Duration _hotRestartReadyTimeout;

  var _isRunning = false;
  String? _currentTestFile;
  final _outputs = <String>[];
  final _errorDetails = <String>[];
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

  /// Whether the develop args ask for the version check the server otherwise
  /// turns off, having answered it without a subprocess.
  bool get _callerChecksCompatibility =>
      developArgs.contains('--check-compatibility');

  /// Identifies the session whose callbacks may still change this object's
  /// state.
  Object? _liveSession;

  /// Whether a develop session is loaded.
  bool get isRunning => _isRunning;

  /// The device discovered by the last [startAndWait] call.
  Device? get device => _developService?.device;
  int? get testServerPort => _testServerPort;

  var _portForwarded = false;

  /// The resolved project's `patrol` incompatibility, read on every call so an
  /// upgrade while the server runs counts.
  String? get _versionWarning {
    final root = _projectRoot;
    if (root == null) {
      return null;
    }
    return patrolIncompatibility(
      PubspecReader(
        projectRoot: const LocalFileSystem().directory(root),
      ).getPatrolVersion(),
    );
  }

  /// Makes the native automator reachable on `localhost:[testServerPort]`.
  ///
  /// Android needs an `adb forward`; iOS simulator traffic is already local. The
  /// forward ends with the session, since it would keep the host port pointing
  /// at the Android device for a later iOS session.
  Future<void> ensureNativeAutomatorReachable() async {
    final device = this.device;
    final scope = _disposeScope;
    if (_portForwarded ||
        device == null ||
        scope == null ||
        scope.disposed ||
        device.targetPlatform != TargetPlatform.android) {
      return;
    }

    final port = _testServerPort ?? defaultTestServerPort;
    final removeForward = await Adb().forwardPorts(
      fromHost: port,
      toDevice: port,
      device: device.id,
    );
    if (scope.disposed) {
      // The session ended while the forward was being set up.
      await removeForward();
      return;
    }
    // A disposer that throws stops the rest of the session's teardown.
    scope.addDispose(() async {
      try {
        await removeForward();
      } catch (err) {
        _logger.detail('Failed to remove adb forward of port $port: $err');
      }
    });
    _portForwarded = true;
  }

  /// Returns null if started successfully, or a warning message if blocked
  Future<String?> _start(
    String testFile, {
    String? device,
    String? projectRoot,
    Duration? timeout,
  }) async {
    if (await _anchor(testFile: testFile, requestedRoot: projectRoot)
        case final blocked?) {
      return blocked;
    }

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
      if (await _waitForHotRestartReady(within: timeout) case final blocked?) {
        return blocked;
      }
      sendCommand(SessionCommand.hotRestart);
      return null;
    }

    await awaitTeardown();

    final resolvedCwd = p.canonicalize(flutterProjectPath);
    // The develop command opens the file from the project, so a file named
    // against a workspace root above it needs the project's own path.
    final target = _projectRelativeTestFile ?? testFile;

    // Parse additional flags using the same ArgParser definitions as the CLI.
    // This supports both develop-specific flags and global flags (e.g.
    // --verbose, --flutter-command) so that PATROL_FLAGS works with everything
    // that `patrol develop` accepts.
    final flagParts = [
      ...developArgs,
      // The check runs `flutter doctor --verbose` before the build, and Android
      // runs with it end without PATROL_LOG entries.
      if (!_callerChecksCompatibility) '--no-check-compatibility',
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
        target: target,
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
        attached = await _listAttachedDevices(
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
      target: target,
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

    // Opened only for a session that starts: a refused run has no cleanup to
    // close it.
    await _startLogStreamingAndTerminal();

    // Create a DisposeScope for the session lifecycle
    final disposeScope = DisposeScope();
    _disposeScope = disposeScope;

    // Create a StreamController to feed FlutterTool's stdin programmatically
    final stdinController = StreamController<List<int>>.broadcast();
    _stdinController = stdinController;

    // DevelopSessionFactory wires up the CLI components. Its onExit completes
    // a completer, because the server outlives every session it runs.
    final exitCompleter = Completer<void>();
    // A session's callbacks answer for that session only: the previous one's
    // backend can report its exit while this one is already running.
    final token = Object();
    _liveSession = token;
    final developService = _createDevelopService(
      projectRoot: resolvedCwd,
      disposeScope: disposeScope,
      stdin: stdinController.stream,
      verbose: verbose,
      onExit: () async {
        if (identical(_liveSession, token) && !exitCompleter.isCompleted) {
          exitCompleter.complete();
        }
      },
      onLogEntry: (entry) {
        if (identical(_liveSession, token)) {
          _handleEntry(entry);
        }
      },
      onTestsCompleted: (result) {
        if (identical(_liveSession, token)) {
          _handleTestsCompleted(result);
        }
      },
    );
    _developService = developService;

    _isRunning = true;
    _cleanupFuture = null;
    _currentTestFile = testFile;
    _testState = TestState.running;
    _quitRequested = false;
    _finishWarning = null;
    _outputs.clear();
    _errorDetails.clear();
    // Create the completer eagerly so callbacks can signal it even if
    // test completion happens before _waitForFinish is called.
    _finishCompleter = Completer<void>();

    // Run the develop service in the background.
    // Test completion is detected by structured callbacks,
    // NOT by developService.run() returning (the process stays alive for
    // hot restart in develop mode).
    _sessionEnded = _runDevelopSession(developService, options, exitCompleter);

    return null;
  }

  Future<void> _runDevelopSession(
    DevelopService developService,
    DevelopOptions options,
    Completer<void> exitCompleter,
  ) {
    // developService.run() blocks for the entire develop session
    // (gradle/xcodebuild + flutter attach stay alive for hot restart). Test
    // completion is detected by callbacks, not by run() returning; the returned
    // future is what a caller waits on to know the session is gone.
    return Future.any([developService.run(options), exitCompleter.future])
        .then((_) async {
          // Session ended (e.g. user sent quit). If tests haven't already
          // been marked as done by callbacks, mark idle.
          if (_testState == TestState.running) {
            _testState = TestState.idle;
          }
          _completeFinish();
          await _cleanup();
        })
        .catchError((Object err, StackTrace st) async {
          // A ToolExit carries a message written for the user, such as a
          // `patrol` version the CLI can't drive, so it is the warning.
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
          await _cleanup();
        });
  }

  Future<void>? _cleanupFuture;

  /// Completes when the running session has ended and released its resources.
  Future<void>? _sessionEnded;

  /// How long a caller waits for a session to finish tearing down.
  final Duration _teardownTimeout;

  /// Stops an active develop session and waits for its child processes to be
  /// torn down. Safe to call when idle or repeatedly.
  Future<void> dispose() async {
    if (_isRunning) {
      sendCommand(SessionCommand.quit);
    }
    await awaitTeardown();
  }

  /// Quits the running session and returns once it has released its resources.
  Future<String> quit() async {
    final message = sendCommand(SessionCommand.quit);
    await awaitTeardown();
    return message;
  }

  /// Waits for a teardown that is under way, if any.
  ///
  /// A session removes its `adb forward` on its way out, so the next session
  /// installs its own only after that.
  Future<void> awaitTeardown() async {
    final deadline = Stopwatch()..start();
    for (final pending in [?_sessionEnded, ?_cleanupFuture]) {
      final left = _teardownTimeout - deadline.elapsed;
      if (left <= Duration.zero) {
        _reportSlowTeardown();
        return;
      }
      try {
        await pending.timeout(left);
      } on TimeoutException {
        _reportSlowTeardown();
        return;
      }
    }
    // The log file stays open until it is closed here or by a session's cleanup.
    if (!_isRunning) {
      await _logStreaming.stopLogging();
    }
  }

  /// A teardown that overruns leaves the previous session's `adb forward`
  /// removal ahead of the next session's, which the host-port-keyed remove then
  /// takes away from it.
  void _reportSlowTeardown() => _logger.warn(
    'The previous session is still shutting down after '
    '${_teardownTimeout.inSeconds}s.',
  );

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
    // `device` reports no session once this one ends. A session started while
    // we were awaiting owns the field now.
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
    if (entry is ErrorEntry) {
      _errorDetails.add(entry.message);
      return;
    }

    if (entry is TestEntry &&
        entry.status == TestEntryStatus.failure &&
        _testState == TestState.running) {
      if (entry.error case final error?) {
        _errorDetails.add(error);
      }
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
    return line.replaceAll(_ansiEscape, '').trim();
  }

  /// Returns null once a hot restart will be acted on, or a message explaining
  /// why it will not be sent.
  ///
  /// `flutter attach` drops a restart sent before its key-commands banner, and
  /// on iOS that banner can come after the test completion signal.
  ///
  /// [within] bounds the wait by what the caller asked for.
  Future<String?> _waitForHotRestartReady({Duration? within}) async {
    final service = _developService;
    if (service == null) {
      return null;
    }

    final limit = within == null || within > _hotRestartReadyTimeout
        ? _hotRestartReadyTimeout
        : within;
    try {
      await service.hotRestartReady.timeout(limit);
      return null;
    } on TimeoutException {
      return 'The session is running "$_currentTestFile" but it did not become '
          'ready for hot restart within ${limit.inSeconds}s, so no restart was '
          'sent. Quit and run again.';
    }
  }

  String sendCommand(SessionCommand command) {
    final controller = _stdinController;
    if (!_isRunning || controller == null) {
      throw StateError('No active patrol session');
    }

    try {
      controller.add(command.value.codeUnits);
    } catch (err) {
      _logger.warn('Failed to send ${command.name}: $err');
      throw StateError(
        'Failed to send ${command.name} to patrol session: $err',
      );
    }

    switch (command) {
      case SessionCommand.quit:
        _quitRequested = true;
        _testState = TestState.idle;
        _completeFinish();
        unawaited(_cleanup());
        return 'Quit command sent to patrol session';
      case SessionCommand.hotRestart:
        _outputs.clear();
        _errorDetails.clear();
        _testState = TestState.running;
        _finishWarning = null;
        // Complete the old completer so any previous waiters are unblocked, then
        // immediately create a fresh one. This avoids a race where callbacks
        // could fire between null-ing and lazy re-creation in _waitForFinish.
        _completeFinish();
        _finishCompleter = Completer<void>();
        return 'Hot restart sent to patrol session';
    }
  }

  PatrolStatus getStatus({String? overrideWarning}) {
    final dev = device;
    return PatrolStatus(
      isDevelopRunning: _isRunning,
      projectRoot: _projectRoot,
      versionWarning: _versionWarning,
      testState: _testState,
      output: _formatLogs(_outputs),
      currentTestFile: _currentTestFile,
      warning: overrideWarning ?? _finishWarning ?? _projectProblem,
      deviceSelectionNote: _deviceSelectionNote,
      error: _errorDetails.isNotEmpty ? _errorDetails.join('\n') : null,
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
  /// the previous run. Callers report a refusal as an error and never pass that
  /// state on as this run's outcome.
  Future<({PatrolStatus status, bool started})> startAndWait(
    String testFile, {
    Duration? timeout,
    String? device,
    String? projectRoot,
  }) async {
    final refusal = await _start(
      testFile,
      device: device,
      projectRoot: projectRoot,
      timeout: timeout,
    );
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
        await _processManager.run([
          'osascript',
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
