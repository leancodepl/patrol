import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'log_streaming.dart';

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
  });

  final bool isDevelopRunning;
  final TestState testState;
  final String output;
  final String? currentTestFile;
  final String? warning;

  String get summary => testState.summary;

  Map<String, Object> toMap() => {
    'isDevelopRunning': isDevelopRunning,
    'testState': testState.name,
    if (currentTestFile != null) 'currentTestFile': currentTestFile!,
    if (warning != null) 'warning': warning!,
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

  Process? _process;
  var _isRunning = false;
  String? _currentTestFile;
  final _outputs = <String>[];
  TestState _testState = TestState.idle;
  var _isHotRestartPending = false;

  Completer<void>? _finishCompleter;

  final _logStreaming = LogStreaming.instance;

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

    final testPort = Platform.environment['PATROL_TEST_PORT'];
    final args = [
      'develop',
      if (additionalFlags.isNotEmpty) ...additionalFlags.split(' '),
      if (testPort != null) ...['--test-server-port', testPort],
      '-t',
      testFile,
    ];

    final process = await Process.start(
      'patrol',
      args,
      workingDirectory: resolvedCwd,
      runInShell: true,
      environment: Platform.environment,
    );

    _process = process;
    _isRunning = true;
    _currentTestFile = testFile;
    _testState = TestState.running;
    _outputs.clear();

    _finishCompleter = null;

    process.stdout
        .transform(utf8.decoder)
        .listen(
          (data) => _handleStreamData(data, isStderr: false),
          onError: (Object error) => _pushOutput('STDOUT ERROR: $error'),
        );

    process.stderr
        .transform(utf8.decoder)
        .listen(
          (data) => _handleStreamData(data, isStderr: true),
          onError: (Object error) => _pushOutput('STDERR ERROR: $error'),
        );

    unawaited(
      process.exitCode
          .then((code) {
            _isRunning = false;
            _currentTestFile = null;
            if (_testState != TestState.finishedPassed &&
                _testState != TestState.finishedFailed) {
              _testState = TestState.idle;
            }
            _completeFinish();

            unawaited(_logStreaming.stopLogging());

            logger.fine('Patrol process exited with code $code');
          })
          .catchError((Object error) {
            _isRunning = false;
            _currentTestFile = null;
            _testState = TestState.idle;
            _completeFinish();

            unawaited(_logStreaming.stopLogging());

            logger.warning('Error waiting for patrol process exit: $error');
          }),
    );

    if (_isRunning) {
      return null;
    }
    throw StateError('Failed to start patrol develop session');
  }

  void _handleStreamData(String data, {required bool isStderr}) {
    for (final line in const LineSplitter().convert(data)) {
      final outputLine = isStderr ? 'STDERR: $line' : line;
      _pushOutput(outputLine);
      _analyzeOutput(line);
    }
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

  void _analyzeOutput(String line) {
    final normalized = _normalizeLine(line);

    // Detect code errors during hot restart
    if (_isHotRestartPending) {
      final isErrorLine = RegExp(r':\d+:\d+:\s*Error:').hasMatch(normalized);
      final isStderr =
          _outputs.isNotEmpty && _outputs.last.startsWith('STDERR:');

      if (isErrorLine && isStderr) {
        _testState = TestState.finishedFailed;
        _completeFinish();
        return;
      }
      // Stop looking for errors after test run starts
      if (normalized.contains(
            'Patrol (native): NativeAutomatorClient created, port:',
          ) &&
          _testState != TestState.finishedFailed) {
        _isHotRestartPending = false;
      }
    }

    // Detect test completion - success cases
    if (normalized.contains('All tests were executed') ||
        normalized.contains('All tests passed!')) {
      _testState = TestState.finishedPassed;
      _completeFinish();
      return;
    }

    // Detect test completion - failure cases
    if (normalized.contains('Test failed. See exception logs above.') ||
        normalized.contains('Some tests failed')) {
      _testState = TestState.finishedFailed;
      _completeFinish();
      return;
    }
  }

  String _normalizeLine(String line) {
    return line.replaceAll(RegExp(r'\x1B\[[0-9;?]*[ -/]*[@-~]'), '').trim();
  }

  String sendCommand(PatrolCommand command) {
    final logger = Logger('PatrolSession');
    final proc = _process;
    if (!_isRunning || proc == null) {
      throw StateError('No active patrol session');
    }

    try {
      proc.stdin.writeln(command.value);
    } catch (e) {
      logger.warning('Failed to write command to patrol process: $e');
      throw StateError('Failed to send command to patrol session: $e');
    }
    if (command == PatrolCommand.hotRestart) {
      _isHotRestartPending = true;
      _outputs.clear();
      _testState = TestState.running;
      _completeFinish();
      _finishCompleter = null;
    }
    return "Command '${command.value}' sent to patrol session";
  }

  PatrolStatus getStatus() {
    return PatrolStatus(
      isDevelopRunning: _isRunning,
      testState: _testState,
      output: _formatLogs(_outputs),
      currentTestFile: _currentTestFile,
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
      // Timeout occurred, but don't fail - just return current status with full output
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
      );
    }
    _finishCompleter = null;
    return _waitForFinish(timeout: timeout);
  }

  /// Automatically start log streaming and optionally launch terminal for live logs
  Future<void> _startLogStreamingAndTerminal() async {
    final logger = Logger('PatrolSession');

    try {
      final logPath = await _logStreaming.startLogging(flutterProjectPath);

      // Open Terminal with tail command only on macOS and if showTerminal is enabled
      if (showTerminal && Platform.isMacOS) {
        await Process.run('osascript', [
          '-e',
          'tell application "Terminal"',
          '-e',
          'do script "echo \'Patrol Test Logs - Live Stream\'; echo \'\'; tail -f \'$logPath\'" in front window',
          '-e',
          'end tell',
        ]);
      } else if (!showTerminal) {
        logger.info('Log file created at: $logPath');
      } else {
        logger.info(
          'Log file created at: $logPath (automatic terminal launch is only available on macOS)',
        );
      }
    } catch (e) {
      // Don't fail the entire operation if log streaming fails
      logger.warning('Failed to start log streaming or terminal: $e');
    }
  }
}
