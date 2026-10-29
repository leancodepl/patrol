import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:adb/adb.dart';
import 'package:args/args.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/commands/develop_session_factory.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/cli_origin.dart';
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

import 'device_selection.dart';
import 'flutter_command_resolver.dart';
import 'log_streaming.dart';
import 'suite_run.dart';

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
    this.deviceName,
    this.deviceId,
    this.devicePlatform,
    this.quietFor,
    this.lastTestEntry,
    this.stallNote,
    this.error,
    this.cli,
    this.cliPinWarning,
    this.logFile,
    this.terminalWarning,
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

  final String? deviceName;
  final String? deviceId;
  final String? devicePlatform;

  /// How long the run has been quiet, absent when nothing is running.
  final Duration? quietFor;

  /// The last test the session saw start, pass or fail.
  final String? lastTestEntry;

  /// Set when the quiet has lasted long enough to be worth reporting.
  final String? stallNote;

  /// Why the first failing test failed: its name and the error lines patrol
  /// reported for it.
  final String? error;

  /// The `patrol_cli` serving this server.
  final CliOrigin? cli;

  /// Set when the project pins a `patrol_cli` other than the one serving it.
  final String? cliPinWarning;

  /// The file the session writes its whole output to while it runs.
  final String? logFile;

  /// Why the Terminal window following [logFile] did not open.
  final String? terminalWarning;

  String get summary => testState.summary;

  Map<String, Object> toMap() => {
    'isDevelopRunning': isDevelopRunning,
    'projectRoot': ?projectRoot,
    'versionWarning': ?versionWarning,
    'testState': testState.name,
    'currentTestFile': ?currentTestFile,
    'warning': ?warning,
    'deviceSelectionNote': ?deviceSelectionNote,
    'deviceName': ?deviceName,
    'deviceId': ?deviceId,
    'devicePlatform': ?devicePlatform,
    'quietForSeconds': ?quietFor?.inSeconds,
    'lastTestEntry': ?lastTestEntry,
    'stallNote': ?stallNote,
    'error': ?error,
    'cli': ?cli?.toMap(),
    'cliPinWarning': ?cliPinWarning,
    'logFile': ?logFile,
    'terminalWarning': ?terminalWarning,
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
    NativePlatform? platform,
    required this._logger,
    io.Stdout? diagnosticSink,
    this.developArgs = const [],
    this.logFile,
    this.showTerminal = false,
    DevelopServiceFactory? developServiceFactory,

    void Function(String root)? enterProjectDirectory,
    this._hotRestartReadyTimeout = const Duration(seconds: 90),
    // Above the develop service's 30 s bound on the uninstall, so a slow but
    // healthy uninstall finishes inside it.
    this._teardownTimeout = const Duration(seconds: 45),
    CliOrigin? cliOrigin,
    List<String>? suiteCommand,
    this._suiteStopGrace = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _platform = platform ?? NativePlatform.current!,
       _now = now ?? DateTime.now,
       _suiteCommand = suiteCommand ?? selfCommand(),
       cliOrigin =
           cliOrigin ??
           CliOrigin.fromScript(io.Platform.script, version: constants.version),
       _enterProjectDirectory =
           enterProjectDirectory ?? ((root) => io.Directory.current = root),
       _diagnosticSink = diagnosticSink ?? io.stderr,
       _createDevelopService =
           developServiceFactory ?? DevelopSessionFactory.create;

  final DateTime Function() _now;
  final ProjectRootResolver _resolveProjectRoot;
  final AttachedDevicesReader _listAttachedDevices;
  final ProcessManager _processManager;
  final NativePlatform _platform;

  /// The log a Terminal window already follows.
  String? _terminalLogPath;

  /// The log the last run wrote to.
  String? _logPath;
  String? _terminalWarning;

  /// The test file as the resolved project sees it, which is not the path the
  /// caller gave when the file was named against a workspace root above it.
  String? _projectRelativeTestFile;

  String? _projectRoot;

  /// The project this session drives. Available once [ensureProjectResolved]
  /// has run, which every tool does before touching the session.
  String get flutterProjectPath =>
      _projectRoot ?? (throw StateError('Project root not resolved yet'));

  /// The project this session drives, or null while none has resolved.
  String? get projectRoot => _projectRoot;

  /// The Flutter command the last session in [projectRoot] started with, or
  /// the one [FlutterCommandResolver] picks there while none has started.
  FlutterCommand get flutterCommand {
    final root = _projectRoot;
    final started = _startedFlutterCommand;
    if (started != null && started.$1 == root) {
      return started.$2;
    }
    final resolved = root == null
        ? null
        : FlutterCommandResolver().resolve(projectRoot: root).command;
    return resolved ?? const FlutterCommand('flutter');
  }

  (String, FlutterCommand)? _startedFlutterCommand;

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
        (_live || (testFile == null && requestedRoot == null))) {
      return;
    }
    await _resolveAndEnter(testFile: testFile, requestedRoot: requestedRoot);
  }

  Future<void> _resolveAndEnter({
    String? testFile,
    String? requestedRoot,
  }) async {
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
    required String? testFile,
    required String? requestedRoot,
  }) async {
    if (!_isRunning) {
      if (cliOrigin.source == CliSource.project) {
        final requested = await _resolveProjectRoot(
          testFile: testFile,
          requestedRoot: requestedRoot,
          remember: false,
        );
        if (!_servesFromProject(requested.root)) {
          return _foreignProjectRefusal(requested.root);
        }
      }
      await _resolveAndEnter(testFile: testFile, requestedRoot: requestedRoot);
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
    // A session that ended during the awaits above has nothing left to
    // protect; the caller starts cold.
    if (!_isRunning || _sameDirectory(requested.root, flutterProjectPath)) {
      return null;
    }
    return 'This server is running "$_currentTestFile" in $flutterProjectPath. '
        'Quit that session before running in ${requested.root}.';
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

  /// Install as `stderr` for the whole MCP command. A failed build reports its
  /// cause only there.
  late final io.Stdout capturingStderr = _CapturingStdout(
    _diagnosticSink,
    _pushOutput,
  );

  static const _maxOutputLines = 200;

  /// How long a hot restart waits for `flutter attach` to become ready. Long
  /// enough for a slow iOS attach and shorter than the caller's run timeout, so
  /// an attach that never finishes is reported while the caller still waits.
  final Duration _hotRestartReadyTimeout;

  var _isRunning = false;

  /// Set while a cold start is under way, before a develop service exists for a
  /// quit to act on.
  var _starting = false;
  var _cancelRequested = false;

  /// The test a start in progress is for, and the start itself, so a quit can
  /// wait for the start to notice the cancellation.
  String? _startingTestFile;
  Completer<void>? _startDone;

  /// Whether a run is in progress or on its way there.
  bool get _live => _isRunning || _starting;

  /// What a caller is told when their own `quit` stopped the run they asked for.
  static const _cancelled = 'The run was cancelled before it started.';
  String? _currentTestFile;
  final _outputs = <String>[];

  static const _notUpYet =
      'The app has not come up yet (it may still be building, installing or '
      'launching).';

  /// How long a run may say nothing before the quiet itself is reported.
  static const _quietBeforeStalled = Duration(minutes: 3);

  /// When the session last heard anything from the run, and the last test entry
  /// it saw.
  DateTime? _lastHeardAt;

  /// Whether the running session's app has come up. The build before it logs
  /// nothing without `--verbose`, so quiet counts only from here.
  bool _appUp = false;

  void _markAppUp() {
    if (!_appUp) {
      _appUp = true;
      _lastHeardAt = _now();
    }
  }

  DateTime? _lastTestEntryAt;
  String? _lastTestEntry;
  TestState _testState = TestState.idle;

  /// Set while quitting so a backend exit we caused isn't reported as a crash.
  var _quitRequested = false;

  /// Warning attached to the next returned status (e.g. unexpected app exit).
  String? _finishWarning;

  Completer<void>? _finishCompleter;

  /// What the session in progress owns. A session that ends late can only ever
  /// clean up its own resources, never the ones a newer session holds.
  _LiveSession? _liveSession;
  DisposeScope? get _disposeScope => _liveSession?.scope;
  StreamController<List<int>>? get _stdinController => _liveSession?.stdin;
  DevelopService? get _developService => _liveSession?.service;
  int? _testServerPort;

  /// A note about device selection surfaced in the next status (e.g. which
  /// device was auto-selected, or that a `device` argument was overridden).
  String? _deviceSelectionNote;

  final _logStreaming = LogStreaming.instance;

  /// Whether the develop args ask for the version check the server otherwise
  /// turns off, having answered it without a subprocess.
  bool get _callerChecksCompatibility =>
      developArgs.contains('--check-compatibility');

  /// Whether a develop session is loaded or starting.
  bool get isRunning => _isRunning || _starting;

  /// The device discovered by the last [startAndWait] call.
  Device? get device => _developService?.device;
  int? get testServerPort => _testServerPort;

  /// The remote debugging port of the Chrome a web session drives.
  String? get webDebuggerPort => _developService?.webDebuggerPort;

  /// The Chrome tab the web session's app runs in.
  String? get webAppPageId => _developService?.webAppPageId;

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

  /// Why a run refuses the resolved project's `patrol`, unless the develop args
  /// ask to run anyway.
  String? get _incompatibilityRefusal {
    if (developArgs.contains('--no-check-compatibility')) {
      return null;
    }
    return switch (_versionWarning) {
      final incompatible? =>
        '$incompatible\n'
            'To run anyway, start the server with '
            '`patrol mcp -- --no-check-compatibility`.',
      null => null,
    };
  }

  /// The `patrol_cli` serving this server.
  final CliOrigin cliOrigin;

  /// Set when the resolved project's lockfile pins a `patrol_cli` other than
  /// the one serving it. Runs use the serving one.
  String? get _cliPinWarning {
    final root = _projectRoot;
    if (root == null || _servesFromProject(root)) {
      return null;
    }
    final pinned = PubspecReader(
      projectRoot: const LocalFileSystem().directory(root),
    ).getLockedVersion('patrol_cli');
    if (pinned == null || pinned == cliOrigin.version) {
      return null;
    }
    return 'This project pins patrol_cli $pinned, but this server is '
        '${cliOrigin.source.name} patrol_cli ${cliOrigin.version}, so runs '
        'use ${cliOrigin.version}. To run the pinned one, point the patrol '
        "server in your editor's MCP config for this project at "
        '"command": "dart", "args": ["run", "patrol_cli:main", "mcp"]. Where '
        'each editor keeps that config: '
        'https://patrol.leancode.co/documentation/other/patrol-mcp#cli-as-a-project-dev-dependency';
  }

  /// Whether [root] is the project whose dev dependency serves this server, or
  /// lies below it in the same workspace.
  bool _servesFromProject(String root) {
    final own = cliOrigin.projectRoot;
    if (cliOrigin.source != CliSource.project || own == null) {
      return false;
    }
    return _sameDirectory(root, own) ||
        p.isWithin(_canonical(own), _canonical(root));
  }

  String _canonical(String path) {
    try {
      return io.Directory(path).resolveSymbolicLinksSync();
    } on io.FileSystemException {
      return p.canonicalize(path);
    }
  }

  /// A server launched from one project's dev dependency runs that project's
  /// pinned CLI, so it refuses another project.
  String _foreignProjectRefusal(String root) =>
      'This server is patrol_cli ${cliOrigin.version} from the dev '
      'dependencies of ${cliOrigin.projectRoot}, so it runs tests only there. '
      'For $root, use a globally activated server (`patrol mcp`), or give that '
      "project its own `dart run patrol_cli:main mcp` in your editor's MCP "
      'config.';

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
    if (_starting) {
      return 'A run of "$_startingTestFile" is still starting. Wait for it, '
          'or quit first.';
    }
    if (_suiteLive) {
      return 'A suite is running and holds the device and its ports. Wait for '
          'it with status, or quit to stop it, before running a single test.';
    }
    if (_isRunning) {
      return _restart(
        testFile,
        device: device,
        projectRoot: projectRoot,
        timeout: timeout,
      );
    }

    _starting = true;
    _startingTestFile = testFile;
    _cancelRequested = false;
    final startDone = _startDone = Completer<void>();
    try {
      if (await _anchor(testFile: testFile, requestedRoot: projectRoot)
          case final blocked?) {
        return blocked;
      }
      if (_incompatibilityRefusal case final refusal?) {
        return refusal;
      }
      if (_cancelRequested) {
        return _cancelled;
      }
      _deviceSelectionNote = null;
      return await _startCold(testFile, device: device);
    } finally {
      _starting = false;
      _startingTestFile = null;
      startDone.complete();
    }
  }

  /// Hot-restarts the running session with [testFile], which has to be the one
  /// it is running: the device cannot change on a hot restart either.
  Future<String?> _restart(
    String testFile, {
    required String? device,
    required String? projectRoot,
    required Duration? timeout,
  }) async {
    if (await _anchor(testFile: testFile, requestedRoot: projectRoot)
        case final blocked?) {
      return blocked;
    }
    if (!_isRunning) {
      return _start(
        testFile,
        device: device,
        projectRoot: projectRoot,
        timeout: timeout,
      );
    }

    _deviceSelectionNote = null;
    if (_currentTestFile != testFile) {
      return 'Patrol session is already running "$_currentTestFile". '
          'Cannot start different test "$testFile". '
          'Use quit first or run the same test file.';
    }
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

  /// Builds, installs and hands the session to `patrol develop`.
  ///
  /// Checks for a cancellation at every step that can be reached after a caller
  /// asked to stop.
  Future<String?> _startCold(String testFile, {required String? device}) async {
    await awaitTeardown();
    if (_cancelRequested) {
      return _cancelled;
    }
    // The previous run's own teardown uninstalls the app and deletes the
    // entrypoint it generated, which is the path this run is about to write.
    if (_runInFlight) {
      return 'The previous develop session is still shutting down (waited '
          '${_teardownTimeout.inSeconds}s). Wait a moment and call run again; '
          'restart the MCP server if this persists.';
    }

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
      // Reaches the caller as a refusal with the flag error.
      return 'Cannot start: ${err.message} Check the develop flags this server '
          'was started with.';
    }
    final verbose = globalResults['verbose'] as bool? ?? false;

    final picked = await _pickDevice(
      device,
      pinned: flagOptions.devices,
      flutterCommand: flutterCommand,
    );
    if (_cancelRequested) {
      return _cancelled;
    }
    if (picked.refusal case final refusal?) {
      return refusal;
    }
    if (picked.device case final id?) {
      flagParts.addAll(['--device', id]);
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
    _startedFlutterCommand = (flutterProjectPath, effective);
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

    if (_cancelRequested) {
      return _cancelled;
    }
    // Opened only for a session that starts: a refused run has no cleanup to
    // close it.
    await _startLogStreamingAndTerminal();

    // Create a DisposeScope for the session lifecycle
    final disposeScope = DisposeScope();

    // Create a StreamController to feed FlutterTool's stdin programmatically
    final stdinController = StreamController<List<int>>.broadcast();

    // DevelopSessionFactory wires up the CLI components. Its onExit completes
    // a completer, because the server outlives every session it runs.
    final exitCompleter = Completer<void>();
    if (_cancelRequested) {
      await _logStreaming.stopLogging();
      return _cancelled;
    }

    // A session's callbacks answer for that session only: the previous one's
    // backend can report its exit while this one is already running.
    final live = _LiveSession(scope: disposeScope, stdin: stdinController);
    _liveSession = live;
    live.service = _createDevelopService(
      projectRoot: resolvedCwd,
      disposeScope: disposeScope,
      stdin: stdinController.stream,
      verbose: verbose,
      onExit: () async {
        if (identical(_liveSession, live) && !exitCompleter.isCompleted) {
          exitCompleter.complete();
        }
      },
      onLogEntry: (entry) {
        if (identical(_liveSession, live)) {
          _handleEntry(entry);
        }
      },
      onTestsCompleted: (result) {
        if (identical(_liveSession, live)) {
          _handleTestsCompleted(result);
        }
      },
    );
    _isRunning = true;
    _currentTestFile = testFile;
    _testState = TestState.running;
    _quitRequested = false;
    _finishWarning = null;
    _outputs.clear();
    _clearFailure();
    _lastHeardAt = _now();
    _appUp = false;
    _lastTestEntryAt = null;
    _lastTestEntry = null;
    unawaited(
      live.service.hotRestartReady.then((_) {
        if (identical(_liveSession, live)) {
          _markAppUp();
        }
      }, onError: (_) {}),
    );
    // Create the completer eagerly so callbacks can signal it even if
    // test completion happens before _waitForFinish is called.
    _finishCompleter = Completer<void>();

    // Run the develop service in the background.
    // Test completion is detected by structured callbacks,
    // NOT by developService.run() returning (the process stays alive for
    // hot restart in develop mode).
    _sessionEnded = _runDevelopSession(live, options, exitCompleter);

    return null;
  }

  /// The device a run adds to its flags, or why there is none. Precedence: a
  /// `--device` the develop args [pinned] > the call's [device] >
  /// auto-selection.
  Future<({String? device, String? refusal})> _pickDevice(
    String? device, {
    required List<String> pinned,
    required FlutterCommand? flutterCommand,
  }) async {
    if (pinned.isNotEmpty) {
      if (device != null) {
        _deviceSelectionNote =
            'Ignored device "$device": the develop args already pin '
            '--device ${pinned.join(', ')}.';
      }
      return (device: null, refusal: null);
    }
    if (device != null) {
      return (device: device, refusal: null);
    }
    final List<Device> attached;
    try {
      attached = await _listAttachedDevices(
        flutterCommand: flutterCommand ?? const FlutterCommand('flutter'),
      );
    } catch (err) {
      return (device: null, refusal: 'Failed to detect attached devices: $err');
    }
    final selected = autoSelectDevice(attached);
    if (selected == null) {
      return (
        device: null,
        refusal:
            'No Android or iOS device detected. Start an emulator or '
            'simulator (or connect a device) and try again, or pass '
            'device: "chrome" to run in a browser.',
      );
    }
    if (supportedDevices(attached).length > 1) {
      _deviceSelectionNote =
          'Auto-selected ${selected.name} (${selected.id}); '
          'pass "device" to run on a different one.';
    }
    return (device: selected.id, refusal: null);
  }

  Future<void> _runDevelopSession(
    _LiveSession live,
    DevelopOptions options,
    Completer<void> exitCompleter,
  ) {
    // developService.run() blocks for the entire develop session
    // (gradle/xcodebuild + flutter attach stay alive for hot restart). Test
    // completion is detected by callbacks, not by run() returning; the returned
    // future is what a caller waits on to know the session is gone.
    final run = live.service.run(options);
    _runInFlight = true;
    _runReturned = run.then(
      (_) => _runInFlight = false,
      onError: (_) => _runInFlight = false,
    );
    return Future.any([run, exitCompleter.future])
        .then((_) async {
          // Session ended (e.g. user sent quit). If tests haven't already
          // been marked as done by callbacks, mark idle.
          if (identical(_liveSession, live)) {
            if (_testState == TestState.running) {
              _testState = TestState.idle;
            }
            _completeFinish();
          }
          await _cleanupOf(live);
        })
        .catchError((Object err, StackTrace st) async {
          // A ToolExit carries a message written for the user, such as a
          // `patrol` version the CLI can't drive, so it is the warning.
          if (identical(_liveSession, live)) {
            if (err is ToolExit) {
              _finishWarning = err.message;
              _pushOutput(err.message);
            } else {
              _logger
                ..err('ERROR: $err')
                ..detail('$st');
            }
            if (_testState == TestState.running) {
              _testState = TestState.finishedFailed;
            }
            _completeFinish();
          }
          await _cleanupOf(live);
        });
  }

  /// Completes when the running session has ended and released its resources.
  Future<void>? _sessionEnded;

  /// Completes when the last session's `run()` has returned, which is after
  /// the session ended: its own teardown uninstalls the app and deletes the
  /// generated entrypoint.
  Future<void>? _runReturned;
  bool _runInFlight = false;

  /// How long a caller waits for a session to finish tearing down.
  final Duration _teardownTimeout;

  static const _maxErrorLines = 60;

  final _errorLines = <String>[];
  String? _failedTest;

  void _clearFailure() {
    _failedTest = null;
    _errorLines.clear();
  }

  void _addErrorLine(String line) {
    if (_errorLines.length < _maxErrorLines) {
      _errorLines.add(line);
    }
  }

  String? get _error {
    if (_failedTest == null && _errorLines.isEmpty) {
      return null;
    }
    return [
      if (_failedTest case final test?) 'Test "$test" failed.',
      ..._errorLines,
    ].join('\n');
  }

  /// Stops an active develop session and waits for its child processes to be
  /// torn down. Safe to call when idle or repeatedly.
  Future<void> dispose() async {
    await quit();
    // A session whose app died is already tearing down without a quit.
    await awaitTeardown();
  }

  /// Quits the running session and returns once it has released its resources.
  ///
  /// A run still starting is cancelled, and the start is waited for so it cannot
  /// come up after this returns.
  Future<String> quit() async {
    if (_suiteStart case final start? when !start.isCompleted) {
      _suiteCancelRequested = true;
      await start.future.timeout(_teardownTimeout, onTimeout: () {});
    }
    if (_suite case final suite? when suite.isRunning) {
      await suite.stop();
      return 'Stopped the suite.';
    }
    if (_starting) {
      _cancelRequested = true;
      await _startDone?.future.timeout(_teardownTimeout, onTimeout: () {});
      if (!_isRunning) {
        return 'Cancelled the run that was starting.';
      }
    }
    if (!_isRunning) {
      return 'No patrol session is running.';
    }
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
    for (final pending in [
      ?_sessionEnded,
      ?_liveSession?.cleanup,
      ?_runReturned,
    ]) {
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

  /// Cleans up [live]. Memoized -- callers share one teardown per session.
  Future<void> _cleanupOf(_LiveSession live) =>
      live.cleanup ??= _doCleanup(live);

  Future<void> _doCleanup(_LiveSession live) async {
    if (identical(_liveSession, live)) {
      _isRunning = false;
      _currentTestFile = null;
      _testServerPort = null;
      _deviceSelectionNote = null;
      _portForwarded = false;
      await _logStreaming.stopLogging();
    }

    try {
      if (!live.scope.disposed) {
        await live.scope.dispose();
      }
    } catch (err) {
      _logger.detail('Error disposing scope: $err');
    }
    await live.stdin.close();
    // `device`, screenshot and native-tree read the live session, so a session
    // that has ended is let go.
    if (identical(_liveSession, live)) {
      _liveSession = null;
    }
    _logger.detail('Develop session ended');
  }

  void _pushOutput(String line) {
    _lastHeardAt = _now();
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
    _markAppUp();
    _lastHeardAt = _now();
    if (entry is TestEntry) {
      _lastTestEntry = entry.name;
      _lastTestEntryAt = _lastHeardAt;
    }
    // patrol logs a failing test's details before its failure entry, and the
    // run ends on that entry, so later lines belong to other tests.
    if (entry is ErrorEntry) {
      if (_testState == TestState.running) {
        _addErrorLine(entry.message);
      }
      return;
    }
    if (entry is TestEntry &&
        entry.status == TestEntryStatus.failure &&
        _testState == TestState.running) {
      _failedTest = entry.name;
      if (entry.error case final error?) {
        _addErrorLine(error);
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
      _logger.err('ERROR: $error');
    }
    _finishWarning =
        'The app stopped without the test reporting completion, so there is no '
        'test result. A failing assertion is reported as a failed test, so look '
        'in the output below for something else: a crash, a build that did not '
        'finish, or a toolchain that never connected.';
    _completeFinish();
    // The app is gone, so the session is over and the next run starts cold.
    if (_liveSession case final live?) {
      unawaited(_cleanupOf(live));
    }
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
        if (_liveSession case final live?) {
          unawaited(_cleanupOf(live));
        }
        return 'Quit command sent to patrol session';
      case SessionCommand.hotRestart:
        _outputs.clear();
        _clearFailure();
        _lastHeardAt = _now();
        _lastTestEntry = null;
        _lastTestEntryAt = null;
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

  /// How long the running session has heard nothing since its app came up,
  /// absent before that and when no run is waiting on the device.
  Duration? get _quietFor {
    if (!_isRunning || !_appUp || _testState != TestState.running) {
      return null;
    }
    final since = _lastHeardAt;
    return since == null ? null : _now().difference(since);
  }

  /// Names the quiet once it lasts [_quietBeforeStalled].
  String? _stallNote(Duration? quiet) {
    if (quiet == null || quiet < _quietBeforeStalled) {
      return null;
    }
    final buffer = StringBuffer(
      'The run has logged nothing for ${_describe(quiet)}',
    );
    final lastAt = _lastTestEntryAt;
    if (_lastTestEntry case final last? when lastAt != null) {
      buffer.write(
        '; the last test entry was "$last", '
        '${_describe(_now().difference(lastAt))} ago',
      );
    } else {
      buffer.write(' and no test has been reported yet');
    }
    return '$buffer.';
  }

  static String _describe(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '${seconds}s';
    }
    return '${duration.inMinutes}m${(seconds % 60).toString().padLeft(2, '0')}s';
  }

  PatrolStatus getStatus({String? overrideWarning}) {
    final dev = device;
    final quiet = _quietFor;
    return PatrolStatus(
      isDevelopRunning: _isRunning,
      projectRoot: _projectRoot,
      versionWarning: _versionWarning,
      testState: _testState,
      output: _formatLogs(_outputs),
      currentTestFile: _currentTestFile,
      warning: overrideWarning ?? _finishWarning ?? _projectProblem,
      deviceSelectionNote: _deviceSelectionNote,
      deviceName: dev?.name,
      deviceId: dev?.id,
      devicePlatform: dev?.targetPlatform.name,
      quietFor: quiet,
      lastTestEntry: _lastTestEntry,
      stallNote: _stallNote(quiet),
      error: _error,
      cli: cliOrigin,
      cliPinWarning: _cliPinWarning,
      logFile: _logPath,
      terminalWarning: _terminalWarning,
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
      final stalled = _stallNote(_quietFor);
      return getStatus(
        overrideWarning: [
          'Run timed out, but the test is still running in the background.',
          if (!_appUp) _notUpYet,
          ?stalled,
          'Call status to check progress, or quit to stop it.',
        ].join(' '),
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

  /// The command that starts this CLI, which a suite run runs `patrol test`
  /// with.
  final List<String> _suiteCommand;

  final Duration _suiteStopGrace;

  /// The last suite run, kept after it ends so its result can still be read.
  SuiteRun? _suite;

  Completer<void>? _suiteStart;
  var _suiteCancelRequested = false;

  bool get _suiteLive =>
      (_suiteStart != null && !_suiteStart!.isCompleted) ||
      (_suite?.isRunning ?? false);

  /// Whether a suite run is starting or running.
  bool get isSuiteRunning => _suiteLive;

  /// The last suite run's state, or null when this server has run none.
  Map<String, Object>? get suiteStatus => _suite?.toMap();

  /// Runs `patrol test` on [targets], or on the whole suite when they are
  /// empty, and waits up to [wait] for it to finish.
  ///
  /// Returns the suite's state, or why it did not start: a develop session or
  /// another suite holds the device, or the project cannot be run here.
  Future<({Map<String, Object>? status, String? refusal})> startSuite({
    required List<String> targets,
    String? tags,
    String? excludeTags,
    String? device,
    String? projectRoot,
    required Duration wait,
  }) async {
    if (_live) {
      return (
        status: null,
        refusal:
            'A develop session is ${_starting ? 'starting' : 'running'} '
            '"${_currentTestFile ?? _startingTestFile}" and holds the device '
            'and its ports. Quit it before running a suite.',
      );
    }
    if (_suiteLive) {
      return (
        status: null,
        refusal:
            'A suite is already running. Call status with waitMinutes to wait '
            'for it, or quit to stop it.',
      );
    }

    final start = _suiteStart = Completer<void>();
    _suiteCancelRequested = false;
    final SuiteRun suite;
    try {
      final prepared = await _prepareSuite(
        targets: targets,
        tags: tags,
        excludeTags: excludeTags,
        device: device,
        projectRoot: projectRoot,
      );
      if (prepared.refusal case final refusal?) {
        return (status: null, refusal: refusal);
      }
      suite = prepared.suite!;
    } finally {
      start.complete();
    }
    await suite.waitFor(wait);
    return (status: suite.toMap(), refusal: null);
  }

  /// Resolves the project, the device and the command line of a suite run and
  /// starts it, or explains why it cannot.
  Future<({SuiteRun? suite, String? refusal})> _prepareSuite({
    required List<String> targets,
    required String? tags,
    required String? excludeTags,
    required String? device,
    required String? projectRoot,
  }) async {
    final first = targets.firstOrNull;
    if (await _anchor(testFile: first, requestedRoot: projectRoot)
        case final blocked?) {
      return (suite: null, refusal: blocked);
    }
    if (_incompatibilityRefusal case final refusal?) {
      return (suite: null, refusal: refusal);
    }
    final root = flutterProjectPath;
    final projectTargets = [
      for (final target in targets) _asProjectSees(target, first: first!),
    ];
    final flutterCommand = FlutterCommandResolver()
        .resolve(projectRoot: root)
        .command;
    final List<String> pinned;
    try {
      pinned = SuiteCommandLine.pinnedDevices(developArgs);
    } on FormatException catch (err) {
      return (
        suite: null,
        refusal:
            'Cannot start: ${err.message} Check the develop flags this server '
            'was started with.',
      );
    }
    _deviceSelectionNote = null;
    final picked = await _pickDevice(
      device,
      pinned: pinned,
      flutterCommand: flutterCommand,
    );
    if (_suiteCancelRequested) {
      return (suite: null, refusal: 'Cancelled the suite that was starting.');
    }
    if (picked.refusal case final refusal?) {
      return (suite: null, refusal: refusal);
    }
    final resultsDir = await io.Directory.systemTemp.createTemp(
      'patrol_mcp_suite_',
    );
    final resultsFile = p.join(resultsDir.path, 'results.jsonl');
    final commandLine = SuiteCommandLine.build(
      serverArgs: developArgs,
      targets: projectTargets,
      tags: tags,
      excludeTags: excludeTags,
      device: picked.device,
      flutterCommand: flutterCommand == null
          ? null
          : [flutterCommand.executable, ...flutterCommand.arguments].join(' '),
      resultsFile: resultsFile,
    );

    await _startLogStreamingAndTerminal();
    final suite = _suite = await SuiteRun.start(
      processManager: _processManager,
      command: [..._suiteCommand, ...commandLine.arguments],
      projectRoot: root,
      resultsFile: resultsFile,
      targets: targets,
      droppedFlags: commandLine.dropped,
      deviceSelectionNote: _deviceSelectionNote,
      platform: _platform,
      stopGrace: _suiteStopGrace,
      onOutput: (line) {
        final clean = _normalizeLine(line);
        if (clean.isNotEmpty) {
          _logStreaming.writeLog(clean);
        }
      },
    );
    _deviceSelectionNote = null;
    unawaited(
      suite.done.then((_) async {
        if (!_live) {
          await _logStreaming.stopLogging();
        }
        try {
          await resultsDir.delete(recursive: true);
        } on io.FileSystemException {
          // Left for the system to clear.
        }
      }),
    );
    return (suite: suite, refusal: null);
  }

  /// [target] as the resolved project sees it. The first target resolved the
  /// project, and the others are named against the same directory it was.
  String _asProjectSees(String target, {required String first}) {
    if (p.isAbsolute(target)) {
      return p.relative(target, from: flutterProjectPath);
    }
    final relativeFirst = _projectRelativeTestFile;
    if (relativeFirst == null || relativeFirst == first) {
      return target;
    }
    if (target == first) {
      return relativeFirst;
    }
    final prefix = first.endsWith(relativeFirst)
        ? first.substring(0, first.length - relativeFirst.length)
        : '';
    return prefix.isNotEmpty && target.startsWith(prefix)
        ? target.substring(prefix.length)
        : target;
  }

  /// Waits up to [wait] for a running suite. Returns at once when none runs.
  Future<void> waitForSuite(Duration wait) async {
    if (_suite case final suite? when suite.isRunning) {
      await suite.waitFor(wait);
    }
  }

  /// Automatically start log streaming and optionally launch terminal
  Future<void> _startLogStreamingAndTerminal() async {
    try {
      final logPath = _logPath = await _logStreaming.startLogging(
        flutterProjectPath,
        logFile: logFile,
      );

      if (showTerminal && _platform.isMacOS) {
        if (logPath != _terminalLogPath) {
          final failure = await _openLogWindow(logPath);
          if (failure == null) {
            _terminalLogPath = logPath;
            _terminalWarning = null;
          } else {
            final warning = _terminalWarning =
                'Could not open a Terminal window for the log at $logPath: '
                '$failure';
            _logger.warn(warning);
          }
        }
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

  /// Opens a Terminal window following [logPath], or returns why it could not.
  ///
  /// Terminal runs a `.command` file it is asked to open, which needs no
  /// permission to control Terminal. `tail -F` follows a path every session
  /// reopens.
  Future<String?> _openLogWindow(String logPath) async {
    final dir = await io.Directory.systemTemp.createTemp('patrol_mcp_log');
    // Terminal reads the script after `open` returns, so it stays on disk.
    final script = io.File(p.join(dir.path, 'patrol-log.command'));
    final quoted = "'${logPath.replaceAll("'", r"'\''")}'";
    await script.writeAsString(
      '#!/bin/sh\n'
      'echo "Patrol test logs: "$quoted\n'
      'echo\n'
      'exec tail -F $quoted\n',
    );
    for (final command in [
      ['chmod', '+x', script.path],
      ['open', '-a', 'Terminal', script.path],
    ]) {
      final result = await _processManager.run(command);
      if (result.exitCode != 0) {
        await dir.delete(recursive: true);
        return '${result.stderr}'.trim();
      }
    }
    return null;
  }
}

/// What a running session owns, kept together so a session that ends after a
/// newer one started cleans up only its own resources.
final class _LiveSession {
  _LiveSession({required this.scope, required this.stdin});

  final DisposeScope scope;
  final StreamController<List<int>> stdin;
  late final DevelopService service;
  Future<void>? cleanup;
}
