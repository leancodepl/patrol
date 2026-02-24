import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:patrol_cli/develop.dart';

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

enum PatrolCommand {
  hotRestart('R'),
  quit('Q');

  const PatrolCommand(this.value);

  final String value;
}

class PatrolStatus {
  const PatrolStatus({
    required this.isDevelopRunning,
    required this.testState,
    required this.output,
    this.currentTestFile,
    this.warning,
    this.deviceName,
    this.deviceId,
    this.devicePlatform,
  });

  final bool isDevelopRunning;
  final TestState testState;
  final String output;
  final String? currentTestFile;
  final String? warning;
  final String? deviceName;
  final String? deviceId;
  final String? devicePlatform;

  String get summary => testState.summary;

  Map<String, Object> toMap() => {
    'isDevelopRunning': isDevelopRunning,
    'testState': testState.name,
    'currentTestFile': ?currentTestFile,
    'warning': ?warning,
    'deviceName': ?deviceName,
    'deviceId': ?deviceId,
    'devicePlatform': ?devicePlatform,
    'output': output,
    'summary': summary,
  };
}

final class PatrolSession {
  PatrolSession({
    required this.flutterProjectPath,
    this.additionalFlags = '',
    this.showTerminal = false,
  });

  final String flutterProjectPath;
  final String additionalFlags;
  final bool showTerminal;

  static const _maxOutputLines = 200;

  var _isRunning = false;
  String? _currentTestFile;
  final _outputs = <String>[];
  TestState _testState = TestState.idle;

  Completer<void>? _finishCompleter;
  DisposeScope? _disposeScope;
  StreamController<List<int>>? _stdinController;
  DevelopService? _developService;
  int? _testServerPort;

  final _logStreaming = LogStreaming.instance;

  /// The device discovered by the last [startAndWait] call.
  Device? get device => _developService?.device;
  int? get testServerPort => _testServerPort;

  /// Returns null if started successfully, or a warning message if blocked
  Future<String?> _start(String testFile) async {
    if (_isRunning) {
      if (_currentTestFile != testFile) {
        return 'Patrol session is already running "$_currentTestFile". '
            'Cannot start different test "$testFile". '
            'Use patrol-quit first or run the same test file.';
      }
      // Same test file - hot restart
      sendCommand(PatrolCommand.hotRestart);
      return null;
    }

    final logger = Logger('PatrolSession');

    await _startLogStreamingAndTerminal();

    final resolvedCwd = p.canonicalize(flutterProjectPath);

    // Create a DisposeScope for the session lifecycle
    final disposeScope = DisposeScope();
    _disposeScope = disposeScope;

    // Create a StreamController to feed FlutterTool's stdin programmatically
    final stdinController = StreamController<List<int>>.broadcast();
    _stdinController = stdinController;

    // Use DevelopSessionFactory to wire up all CLI components in one call,
    // with a custom onExit that signals a completer instead of exit(0).
    final exitCompleter = Completer<void>();
    final developService = DevelopSessionFactory.create(
      projectRoot: resolvedCwd,
      disposeScope: disposeScope,
      stdin: stdinController.stream,
      onExit: () async {
        if (!exitCompleter.isCompleted) {
          exitCompleter.complete();
        }
      },
      onLogEntry: _handleEntry,
      onTestsCompleted: _handleTestsCompleted,
    );
    _developService = developService;

    // Parse additional flags using the same ArgParser definitions as the CLI.
    final flagParts = (additionalFlags.isNotEmpty
            ? additionalFlags.split(RegExp(r'\s+'))
            : <String>[])
        // Skip compatibility checking in MCP context for speed.
        ..add('--no-check-compatibility');

    final flutterCmd = io.Platform.environment['PATROL_FLUTTER_COMMAND'];

    final options = DevelopOptions.fromArgs(
      flagParts,
      target: testFile,
      flutterCommand: flutterCmd != null && flutterCmd.isNotEmpty
          ? FlutterCommand.parse(flutterCmd)
          : null,
    );
    _testServerPort = options.testServerPort;

    _isRunning = true;
    _cleanupDone = false;
    _currentTestFile = testFile;
    _testState = TestState.running;
    _outputs.clear();
    // Create the completer eagerly so callbacks can signal it even if
    // test completion happens before _waitForFinish is called.
    _finishCompleter = Completer<void>();

    // Run the develop service in the background.
    // Test completion is detected by structured callbacks,
    // NOT by developService.run() returning (the process stays alive for
    // hot restart in develop mode).
    _runDevelopSession(developService, options, exitCompleter, logger);

    return null;
  }

  void _runDevelopSession(
    DevelopService developService,
    DevelopOptions options,
    Completer<void> exitCompleter,
    Logger logger,
  ) {
    // Use a _CapturingStdout so that:
    //  1) mason_logger output goes to stderr (not stdout / the JSON protocol)
    //  2) every line is captured for the patrol.log file and output buffer
    final capturingStdout = _CapturingStdout(io.stderr, _pushOutput);

    // Redirect stdout inside this zone to our capturing wrapper.
    // mason_logger resolves its stdout handle via IOOverrides.
    io.IOOverrides.runZoned(stdout: () => capturingStdout, () {
      // Fire-and-forget: developService.run() blocks for the entire develop
      // session (gradle/xcodebuild + flutter attach stay alive for hot
      // restart). Test completion is detected by callbacks, not by run()
      // returning.
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
              logger.warning('Develop session error: $err\n$st');
              _pushOutput('ERROR: $err');
              if (_testState == TestState.running) {
                _testState = TestState.finishedFailed;
              }
              _completeFinish();
              unawaited(_cleanup());
            }),
      );
    });
  }

  var _cleanupDone = false;

  /// Clean up all resources for the current session.
  /// Safe to call multiple times -- only the first call does actual work.
  Future<void> _cleanup() async {
    if (_cleanupDone) {
      return;
    }
    _cleanupDone = true;

    final logger = Logger('PatrolSession');
    _isRunning = false;
    _currentTestFile = null;
    _testServerPort = null;

    await _logStreaming.stopLogging();

    try {
      final scope = _disposeScope;
      if (scope != null && !scope.disposed) {
        await scope.dispose();
      }
    } catch (e) {
      logger.fine('Error disposing scope: $e');
    }
    await _stdinController?.close();
    logger.fine('Develop session ended');
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
  /// In develop mode, successful runs stay alive for hot restart and don't exit.
  /// So if the backend exits while we're still running, treat it as failure.
  /// (Quit path sets state to idle before this callback can affect it.)
  void _handleTestsCompleted(TestCompletionResult result) {
    if (_testState == TestState.running) {
      _testState = TestState.finishedFailed;
      _completeFinish();
    }
  }

  String _normalizeLine(String line) {
    return line.replaceAll(RegExp(r'\x1B\[[0-9;?]*[ -/]*[@-~]'), '').trim();
  }

  String sendCommand(PatrolCommand command) {
    final logger = Logger('PatrolSession');

    if (command == PatrolCommand.quit) {
      final controller = _stdinController;
      if (!_isRunning || controller == null) {
        throw StateError('No active patrol session');
      }

      controller.add('Q'.codeUnits);
      _testState = TestState.idle;
      _completeFinish();
      unawaited(_cleanup());

      return 'Quit command sent to patrol session';
    }

    if (command == PatrolCommand.hotRestart) {
      final controller = _stdinController;
      if (!_isRunning || controller == null) {
        throw StateError('No active patrol session');
      }

      try {
        controller.add('R'.codeUnits);
      } catch (e) {
        logger.warning('Failed to send hot restart: $e');
        throw StateError('Failed to send hot restart to patrol session: $e');
      }

      _outputs.clear();
      _testState = TestState.running;
      // Complete the old completer so any previous waiters are unblocked, then
      // immediately create a fresh one. This avoids a race where callbacks
      // could fire between null-ing and lazy re-creation in _waitForFinish.
      _completeFinish();
      _finishCompleter = Completer<void>();

      return 'Hot restart sent to patrol session';
    }

    throw StateError('Unknown command: ${command.value}');
  }

  PatrolStatus getStatus() {
    final dev = _developService?.device;
    return PatrolStatus(
      isDevelopRunning: _isRunning,
      testState: _testState,
      output: _formatLogs(_outputs),
      currentTestFile: _currentTestFile,
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
      // Timeout occurred, but don't fail - just return current status
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

  // Start and wait for completion
  Future<PatrolStatus> startAndWait(
    String testFile, {
    Duration? timeout,
  }) async {
    final warning = await _start(testFile);
    if (warning != null) {
      // Return current status with warning (blocked by different test)
      final status = getStatus();
      return PatrolStatus(
        isDevelopRunning: status.isDevelopRunning,
        testState: status.testState,
        output: status.output,
        currentTestFile: status.currentTestFile,
        warning: warning,
        deviceName: status.deviceName,
        deviceId: status.deviceId,
        devicePlatform: status.devicePlatform,
      );
    }
    return _waitForFinish(timeout: timeout);
  }

  /// Automatically start log streaming and optionally launch terminal
  Future<void> _startLogStreamingAndTerminal() async {
    final logger = Logger('PatrolSession');

    try {
      final logPath = await _logStreaming.startLogging(flutterProjectPath);

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
        logger.info('Log file created at: $logPath');
      } else {
        logger.info(
          'Log file created at: $logPath '
          '(automatic terminal launch is only available on macOS)',
        );
      }
    } catch (e) {
      // Don't fail the entire operation if log streaming fails
      logger.warning('Failed to start log streaming or terminal: $e');
    }
  }
}
