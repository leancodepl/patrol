import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart' hide ProcessDisposed;
import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/coverage/bind_unused_port.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/web/chrome_pages.dart';
import 'package:patrol_cli/src/web/restart_teardown_window.dart';
import 'package:patrol_cli/src/web/web_devtools_server.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';
import 'package:process/process.dart';

const _kDefaultWebServerTimeoutSeconds = 120;

/// How long a hot restart counts as in flight before another "r" resends it.
const _kRestartOutcomeWindow = Duration(seconds: 5);

/// Strips the `[  +12 ms]` prefix `flutter run --verbose` adds to each line.
final _flutterLogPrefix = RegExp(r'^\[[\s\d+ms]*\]\s?');

const _developKeyCommands =
    'Patrol develop key commands:\n'
    'r Hot restart\n'
    'h Print this help message\n'
    'q Quit (terminate the process and application on the device)';

class WebTestBackend {
  WebTestBackend({
    required this._processManager,
    required DisposeScope parentDisposeScope,
    required this._logger,
  }) : _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final Logger _logger;
  final DisposeScope _disposeScope;

  String? get debuggerPort => _debuggerPort;
  String? _debuggerPort;

  /// The DevTools Protocol id of the tab the app runs in. Tests can open more
  /// tabs, so screenshots look for this one.
  String? get appPageId => _appPageId;
  String? _appPageId;

  /// The resident `flutter run`; hot restart goes through its stdin.
  Process? _flutterProcess;

  Process? _playwrightDevelopProcess;

  /// True once the app is up and Playwright is attached; a restart before that
  /// kills the session (flutter/flutter#182377).
  bool _hotRestartActive = false;

  final _hotRestartReady = Completer<void>();

  /// Completes once the session first accepts a hot restart: the app is
  /// served, its debug service is live and the Playwright driver is up.
  Future<void> get hotRestartReady => _hotRestartReady.future;

  /// An "r" pressed before the session was attached, replayed once it is.
  String? _pendingHotRestartTarget;

  /// True while a hot restart is in flight, when `flutter run` ignores keys.
  bool _restartInFlight = false;

  DateTime? _restartRequestedAt;

  @visibleForTesting
  final restartTeardown = RestartTeardownWindow();

  /// Set once the resident `flutter run` is gone.
  int? _flutterExitCode;

  /// Set on quit so subprocess kills aren't surfaced as unexpected exits.
  bool _quitting = false;

  /// Why the Playwright driver ended the session, so it fails instead of
  /// reading as a quit.
  String? _driverFailure;

  /// The `npm`/`npx` install running before the driver starts, if any.
  Process? _installProcess;

  FlutterTool? _flutterTool;
  bool _openDevtools = false;

  String? _debugServiceUri;

  Future<void> build(WebAppOptions options, {String? output}) async {
    _logger.detail('Building web app for testing...');

    final result = await _processManager.run(
      options.toFlutterBuildInvocation(output: output),
    );

    if (result.exitCode != 0) {
      throw ProcessException(
        options.flutter.command.executable,
        ['build', 'web'],
        'Failed to build web app: ${result.stderr}',
        result.exitCode,
      );
    }
  }

  Future<void> buildForDevelop(WebAppOptions options) async {
    // this is just noop, because `flutter run` already builds the web app
  }

  /// Runs an already-built app served at [baseUrl]; needs Node, not Flutter.
  Future<void> executePrebuilt(
    WebAppOptions options, {
    required String baseUrl,
    required String runnerPath,
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
  }) {
    return _runPlaywrightTests(
      baseUrl,
      options,
      runnerPath: runnerPath,
      showFlutterLogs: showFlutterLogs,
      hideTestSteps: hideTestSteps,
      clearTestSteps: clearTestSteps,
    );
  }

  /// The `web_runner` directory inside the resolved patrol package.
  Future<String> resolveWebRunnerPath() => _getWebRunnerPath();

  Future<void> execute(
    WebAppOptions options,
    Device device, {
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
    void Function(Entry entry)? onLogEntry,
  }) async {
    _logger
      ..detail('Starting web test execution...')
      ..info('Building Flutter web app...');

    _throwIfInterrupted();
    final flutterProcess = await _startFlutterWebServer(
      options,
      develop: false,
    );

    try {
      if (_disposeScope.disposed) {
        await _killLateStart(flutterProcess);
      }
      flutterProcess.disposedByTree(_disposeScope);

      final baseUrl = await _waitForWebServer(
        flutterProcess,
        serverTimeout: options.serverTimeout,
      );

      await _runPlaywrightTests(
        baseUrl,
        options,
        showFlutterLogs: showFlutterLogs,
        hideTestSteps: hideTestSteps,
        clearTestSteps: clearTestSteps,
        onLogEntry: onLogEntry,
      );
    } catch (_) {
      _throwIfInterrupted();
      rethrow;
    } finally {
      _logger.detail('Stopping Flutter web server...');

      await flutterProcess.killTree();

      try {
        await flutterProcess.exitCode.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        _logger.detail(
          'Graceful shutdown timed out, force killing Flutter process...',
        );
        flutterProcess.kill(ProcessSignal.sigkill);
        await flutterProcess.exitCode;
      }
    }
  }

  /// Throws when [_disposeScope] is disposed, which happens mid-run only on an
  /// interrupt.
  void _throwIfInterrupted() {
    if (_disposeScope.disposed) {
      throwToolInterrupted(_interruptedDetails);
    }
  }

  /// Kills [process], which finished starting after an interrupt, together
  /// with its descendants, and reports the interrupt.
  Future<Never> _killLateStart(Process process) async {
    await process.killTree();
    throwToolInterrupted(_interruptedDetails);
  }

  static const _interruptedDetails = 'the web run was interrupted';

  /// Runs a develop session on web, where "r" hot restarts the resident
  /// `flutter run`. Requires Flutter 3.47 (flutter/flutter#183838).
  Future<void> develop(
    FlutterTool flutterTool,
    WebAppOptions options,
    Device device, {
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
    required Stream<List<int>> stdin,
    void Function(Entry entry)? onLogEntry,
    bool openDevtools = false,
  }) async {
    _logger.detail('Starting web develop execution...');
    _throwIfInterrupted();

    _flutterTool = flutterTool;
    _openDevtools = openDevtools;

    StdinModes? previousStdinModes;
    if (io.stdin.hasTerminal) {
      previousStdinModes = flutterTool.enableInteractiveMode();
    }

    // Chosen up front so MCP screenshots can use it before Chrome launches.
    final debuggerPort = await bindUnusedPort<int>((port) => port);
    _debuggerPort = '$debuggerPort';
    _appPageId = null;

    final exited = Completer<void>();
    // Without this, a crash during startup is unhandled and skips `finally`.
    unawaited(exited.future.then((_) {}, onError: (Object _) {}));

    // Ctrl+C reaches the driver too; on Windows it may not exit with 0.
    final sigintSubscription = ProcessSignal.sigint.watch().listen((_) {
      _quitting = true;
    });

    final stdinSubscription = stdin.listen((event) async {
      if (event.isEmpty) {
        return;
      }
      final char = String.fromCharCode(event.first);
      _logger.detail('Flutter stdin: $char');

      if (char == 'r' || char == 'R') {
        await _requestHotRestart(options.flutter.target);
      } else if (char == 'h' || char == 'H') {
        _logger.success(_developKeyCommands);
      } else if (char == 'q' || char == 'Q') {
        _quitting = true;
        final modes = previousStdinModes;
        if (modes != null) {
          flutterTool.revertInteractiveMode(modes);
          previousStdinModes = null;
        }
        _logger.success('Quitting process...');
        await _killInstall();
        await _playwrightDevelopProcess?.killTree();
        await _stopFlutterProcess();
      }
    });

    try {
      final flutterProcess = await _startFlutterWebServer(
        options,
        develop: true,
        browserDebugPort: debuggerPort,
      );
      _flutterProcess = flutterProcess;
      await _killTreeOnDispose(flutterProcess);

      await _watchFlutterRun(flutterProcess, exited);

      try {
        await _waitForWebDebugger(
          flutterProcess,
          debuggerPort,
          serverTimeout: options.serverTimeout,
        );
      } on Object {
        _throwIfInterrupted();
        if (_quitting) {
          return;
        }
        rethrow;
      }
      _throwIfInterrupted();
      if (_quitting) {
        return;
      }

      await _runPlaywrightDevelop(
        '$debuggerPort',
        options,
        showFlutterLogs: showFlutterLogs,
        hideTestSteps: hideTestSteps,
        clearTestSteps: clearTestSteps,
        onLogEntry: onLogEntry,
      );
      _throwIfInterrupted();
      if (_quitting) {
        return;
      }

      _markAttached();

      if (openDevtools) {
        await _serveDevtools(options);
      }

      // Lives as long as `flutter run`; ended by quit or its exit handler.
      await exited.future;
    } on Object {
      _throwIfInterrupted();
      rethrow;
    } finally {
      await stdinSubscription.cancel();
      await sigintSubscription.cancel();
      _quitting = true;
      await _playwrightDevelopProcess?.killTree();
      await _stopFlutterProcess();
      final modes = previousStdinModes;
      if (modes != null) {
        flutterTool.revertInteractiveMode(modes);
      }
    }
  }

  /// Kills [process] and its descendants once [_disposeScope] is disposed,
  /// also when that happened while [process] was starting.
  Future<void> _killTreeOnDispose(Process process) async {
    if (_disposeScope.disposed) {
      _quitting = true;
      await _killLateStart(process);
    }
    // Marked as a quit before the kill, so the exit handlers do not report it
    // as a crash.
    process.disposedByTree(_disposeScope, onKill: () => _quitting = true);
  }

  /// Serves DevTools with the Patrol extension, which the one `flutter run`
  /// serves can't find for a web app.
  Future<void> _serveDevtools(WebAppOptions options) async {
    final debugServiceUri = _debugServiceUri;
    if (debugServiceUri == null) {
      _logger.detail('No VM service URI yet; skipping the DevTools server');
      return;
    }

    final base =
        await WebDevtoolsServer(
          processManager: _processManager,
          logger: _logger,
          disposeScope: _disposeScope,
        ).serve(
          flutterCommand: options.flutter.command,
          projectRoot: Directory.current.path,
        );

    if (base == null) {
      if (_disposeScope.disposed) {
        return;
      }
      _logger.warn(
        'Could not serve the Patrol DevTools extension. Open DevTools from your '
        'IDE instead -- on web the extension is only discoverable when the '
        'project is registered as a workspace root.',
      );
      return;
    }

    final url = '$base/patrol_ext?uri=$debugServiceUri';
    _logger.success('Patrol DevTools extension is available at $url');
    if (_openDevtools) {
      _flutterTool?.openDevtoolsPage(url).ignore();
    }
  }

  /// Opens the session to hot restarts and replays one queued while it booted.
  void _markAttached() {
    if (_hotRestartActive) {
      return;
    }
    _hotRestartActive = true;
    if (!_hotRestartReady.isCompleted) {
      _hotRestartReady.complete();
    }
    _logger.success('Hot Restart: attached to the app\n$_developKeyCommands');

    final pending = _pendingHotRestartTarget;
    if (pending != null) {
      _pendingHotRestartTarget = null;
      _logger.success('Hot Restart: sending the queued restart');
      unawaited(_requestHotRestart(pending));
    }
  }

  /// Asks the resident `flutter run` for a hot restart.
  Future<void> _requestHotRestart(String target) async {
    final process = _flutterProcess;
    if (process == null) {
      return;
    }
    if (!_hotRestartActive) {
      _pendingHotRestartTarget = target;
      _logger.warn(
        'Hot Restart: not attached to the app yet, will restart once attached',
      );
      return;
    }
    if (_restartInFlight) {
      final requestedAt = _restartRequestedAt;
      if (requestedAt != null &&
          DateTime.now().difference(requestedAt) < _kRestartOutcomeWindow) {
        _logger.warn('Hot Restart: a restart is already in progress');
        return;
      }
      _logger.detail('No outcome for the previous hot restart; resending.');
      _restartInFlight = false;
    }

    _restartInFlight = true;
    _restartRequestedAt = DateTime.now();
    restartTeardown.restartRequested();
    _logger.success('Hot Restart for entrypoint ${basename(target)}...');
    process.stdin.add('R'.codeUnits);
    await process.stdin.flush();
  }

  Future<void> _stopFlutterProcess() async {
    final process = _flutterProcess;
    _flutterProcess = null;
    if (process == null) {
      return;
    }

    _logger.detail('Stopping Flutter web server...');

    try {
      // Quit via flutter so it closes Chrome; a hard kill orphans it on macOS.
      process.stdin.add('q'.codeUnits);
      await process.stdin.flush();
    } on Object catch (err) {
      _logger.detail('Failed to send quit to Flutter: $err');
    }

    try {
      await process.exitCode.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      _logger.detail(
        'Graceful shutdown timed out, force killing Flutter process...',
      );
      process.kill(ProcessSignal.sigkill);
      await process.exitCode;
    }
  }

  /// Attaches the only listeners to the resident `flutter run`'s output.
  Future<void> _watchFlutterRun(Process process, Completer<void> exited) async {
    final debugServiceReady = Completer<void>();
    _debugServiceReady = debugServiceReady;
    unawaited(debugServiceReady.future.then((_) {}, onError: (Object _) {}));

    process.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(onFlutterLine)
        .disposedBy(_disposeScope);

    process.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) => _logger.detail('Flutter stderr: $line'))
        .disposedBy(_disposeScope);

    process.exitCode.then((exitCode) {
      _flutterExitCode = exitCode;
      _hotRestartActive = false;
      _restartInFlight = false;
      restartTeardown.close();
      if (!debugServiceReady.isCompleted) {
        debugServiceReady.completeError(
          'Flutter process exited unexpectedly with code $exitCode',
        );
      }
      if (exited.isCompleted) {
        return;
      }
      final driverFailure = _driverFailure;
      if (driverFailure != null) {
        exited.completeError(driverFailure);
      } else if (exitCode != 0 && !_quitting) {
        exited.completeError(
          'Flutter process exited unexpectedly with code $exitCode',
        );
      } else {
        exited.complete();
      }
    }).ignore();
  }

  Completer<void>? _debugServiceReady;

  @visibleForTesting
  void onFlutterLine(String rawLine) {
    final line = rawLine.replaceFirst(_flutterLogPrefix, '');

    // Playwright re-emits these and its copy is the one PatrolLogReader reads.
    if (line.contains('PATROL_LOG')) {
      if (restartTeardown.isOpen &&
          RestartTeardownWindow.isReplacementRunMarker(line)) {
        restartTeardown.close();
        _logger.detail('Hot Restart: the replacement run started');
      }
      return;
    }

    if (line == 'Flutter run key commands.') {
      return;
    }

    if (line.startsWith('Debug service listening on')) {
      final match = RegExp(r'ws://\S+').firstMatch(line);
      if (match != null) {
        _debugServiceUri = match.group(0);
      }
      final completer = _debugServiceReady;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
      _logger.detail('Flutter: $line');
      return;
    }

    if (line.startsWith('Restarted application in')) {
      _restartInFlight = false;
      restartTeardown.restartCompleted();
      _logger.success(line);
      return;
    }

    if (line == 'Try again after fixing the above error(s).' ||
        line.contains('Failed to recompile application.')) {
      _restartInFlight = false;
      restartTeardown.close();
      _logger.err('Hot restart failed. Fix the errors above and press "r".');
      return;
    }

    // flutter_test's reporter prints a failure as `... [E]` and the error on
    // the next, indented line; that is the only place a setUpAll error shows.
    final plain = line.replaceAll(_ansiEscape, '');
    final isReporterError = _afterReporterError && plain.startsWith('  ');
    _afterReporterError = plain.endsWith('[E]');

    if (_isFailureLine(line) || _afterReporterError || isReporterError) {
      // Failures from the run a restart replaces are noise; later ones are real.
      if (restartTeardown.isOpen) {
        _logger.detail('Flutter (restart teardown): $line');
      } else {
        _logger.err(line);
      }
      return;
    }

    _logger.detail('Flutter: $line');
  }

  bool _afterReporterError = false;

  static final _ansiEscape = RegExp(r'\x1b\[[0-9;]*m');

  static bool _isFailureLine(String line) =>
      line.contains('EXCEPTION CAUGHT') ||
      line.contains('RethrownDartError') ||
      line.contains('TestFailure') ||
      line.startsWith('Expected:') ||
      line.startsWith('  Actual:') ||
      line.startsWith('   Which:') ||
      line.contains('Test failed.') ||
      line.contains('Some tests failed.');

  Future<Process> _startFlutterWebServer(
    WebAppOptions options, {
    required bool develop,
    int? browserDebugPort,
  }) async {
    _logger.detail('Starting Flutter web server...');

    final process = await _processManager.start([
      options.flutter.command.executable,
      ...options.flutter.command.arguments,
      'run',
      '-d',
      if (develop) 'chrome' else 'web-server',
      if (browserDebugPort != null)
        '--web-browser-debug-port=$browserDebugPort',
      if (options.webPort != null) '--web-port=${options.webPort}',
      // Only --verbose shows which dwds step a hung restart stopped at.
      if (_logger.level == Level.verbose) '--verbose',
      '--target=${options.flutter.target}',
      '--${options.flutter.buildMode.name}',
      // Note: --flavor is not supported for web, so we don't include it
      ...options.flutter.dartDefines.entries.map(
        (e) => '--dart-define=${e.key}=${e.value}',
      ),
      ...options.flutter.dartDefineFromFilePaths.map(
        (e) => '--dart-define-from-file=$e',
      ),
    ]);

    return process;
  }

  Future<String> _waitForWebServer(
    Process flutterProcess, {
    int? serverTimeout,
  }) {
    final timeoutDuration = Duration(
      seconds: serverTimeout ?? _kDefaultWebServerTimeoutSeconds,
    );
    _logger.detail(
      'Waiting for web server to start (timeout: ${timeoutDuration.inSeconds}s)...',
    );

    final completer = Completer<String>();
    late StreamSubscription<String> stdoutSubscription;
    late StreamSubscription<String> stderrSubscription;

    stdoutSubscription = flutterProcess.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _logger.detail('Flutter: $line');

          // Look for the server URL in Flutter output
          final url = extractWebServerUrl(line);

          // [CHROME]: DevTools listening on ws://127.0.0.1:38861/devtools/browser/431953d3-ef67-428f-9321-9317256022d0
          if (url != null && !completer.isCompleted) {
            _logger.info('Web server started at: $url');

            // Verify server is actually responding before completing
            verifyServerReady(url)
                .then((isReady) {
                  if (!completer.isCompleted && isReady) {
                    // Do NOT cancel the stdout/stderr subscriptions here:
                    // doing so kills Flutter's web server.
                    completer.complete(url);
                  }
                })
                .catchError((Object error) {
                  _logger.detail('Server verification failed: $error');
                  // Still complete with URL, let Playwright handle retries
                  if (!completer.isCompleted) {
                    stdoutSubscription.cancel();
                    stderrSubscription.cancel();
                    completer.complete(url);
                  }
                });
          }
        });

    stderrSubscription = flutterProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _logger.detail('Flutter stderr: $line');

          if (line.contains('FATAL') ||
              line.contains('Failed to bind') ||
              line.contains('Address already in use')) {
            if (!completer.isCompleted) {
              stdoutSubscription.cancel();
              stderrSubscription.cancel();
              completer.completeError(
                'Flutter web server failed to start: $line',
              );
            }
          }
        });

    // `flutter` can exit with code 0 on SIGINT.
    flutterProcess.exitCode.then((exitCode) {
      if (!completer.isCompleted) {
        stdoutSubscription.cancel();
        stderrSubscription.cancel();
        completer.completeError(
          'Flutter process exited unexpectedly with code $exitCode',
        );
      }
    }).ignore();

    Timer(timeoutDuration, () {
      if (!completer.isCompleted) {
        stdoutSubscription.cancel();
        stderrSubscription.cancel();
        completer.completeError(
          'Timeout waiting for web server to start '
          '(after ${timeoutDuration.inSeconds}s). '
          'Consider increasing the timeout with --web-server-timeout.',
        );
      }
    });

    return completer.future;
  }

  /// Whether [url] answers with HTTP 200, without logging, for polling.
  Future<bool> _httpOk(Uri url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
    try {
      final response = await (await client.getUrl(url)).close();
      await response.drain<void>();
      return response.statusCode == 200;
    } on Object {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  /// Waits for Chrome's CDP endpoint on [debuggerPort] and the Flutter debug
  /// service attaching to the page.
  Future<void> _waitForWebDebugger(
    Process flutterProcess,
    int debuggerPort, {
    int? serverTimeout,
  }) async {
    final timeoutDuration = Duration(
      seconds: serverTimeout ?? _kDefaultWebServerTimeoutSeconds,
    );
    _logger.detail(
      'Waiting for debugger on port $debuggerPort '
      '(timeout: ${timeoutDuration.inSeconds}s)...',
    );

    final deadline = DateTime.now().add(timeoutDuration);
    final endpoint = Uri.parse('http://127.0.0.1:$debuggerPort/json/version');

    while (!await _httpOk(endpoint)) {
      _throwIfInterrupted();
      final exitCode = _flutterExitCode;
      if (exitCode != null) {
        throw StateError(
          'Flutter exited with code $exitCode before Chrome was ready',
        );
      }
      if (_flutterProcess == null) {
        throw StateError('Flutter process stopped before Chrome was ready');
      }
      if (DateTime.now().isAfter(deadline)) {
        throw StateError(
          'Timeout waiting for the Chrome debugger on port $debuggerPort '
          '(after ${timeoutDuration.inSeconds}s). '
          'Consider increasing the timeout with --web-server-timeout.',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    _logger.info('Debugger started at port: $debuggerPort');

    // CDP answers before the app runs; this line comes right before main().
    final ready = _debugServiceReady;
    if (ready != null && !ready.isCompleted) {
      await ready.future.timeout(
        deadline.difference(DateTime.now()),
        onTimeout: () => throw StateError(
          'Timeout waiting for the Flutter debug service '
          '(after ${timeoutDuration.inSeconds}s). '
          'Consider increasing the timeout with --web-server-timeout.',
        ),
      );
    }

    // The app's tab is the only one until a test opens another.
    _appPageId = await _firstPageId(debuggerPort);
  }

  Future<String?> _firstPageId(int debuggerPort) async {
    const step = Duration(seconds: 2);
    final client = HttpClient()..connectionTimeout = step;
    try {
      final request = await client.getUrl(
        Uri.parse('http://127.0.0.1:$debuggerPort/json'),
      );
      final response = await request.close().timeout(step);
      final body = await response.transform(utf8.decoder).join().timeout(step);
      return pickChromePage(jsonDecode(body) as List<Object?>)?['id']
          as String?;
    } on Object catch (err) {
      _logger.detail('Could not read the app tab from Chrome: $err');
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _runPlaywrightTests(
    String baseUrl,
    WebAppOptions options, {
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    String? runnerPath,
    void Function(Entry entry)? onLogEntry,
  }) async {
    _throwIfInterrupted();

    _logger.info('Running Playwright tests against: $baseUrl');
    final completer = Completer<void>();

    await _disposeScope.run((scope) async {
      final webRunnerPath = runnerPath ?? await _getWebRunnerPath();
      _ensureWebRunnerExists(webRunnerPath);

      await _ensureNodeDependencies(webRunnerPath);

      final testResultsDir =
          options.resultsDir ?? '${Directory.current.path}/test-results';
      final testReportDir =
          options.reportDir ?? '${Directory.current.path}/playwright-report';

      _logger
        ..detail('Test results will be saved to: $testResultsDir')
        ..detail('Test report will be saved to: $testReportDir');

      _throwIfInterrupted();
      final playwrightProcess = await _processManager.start(
        ['npx', 'playwright', 'test', 'tests/test.spec.ts'],
        workingDirectory: webRunnerPath,
        environment: {
          ...Platform.environment,
          'BASE_URL': baseUrl,
          'PATROL_TEST_RESULTS_DIR': testResultsDir,
          'PATROL_TEST_REPORT_DIR': testReportDir,
          ...options.toEnvironmentVariables(),
        },
        runInShell: true,
      );
      if (scope.disposed || _disposeScope.disposed) {
        await _killLateStart(playwrightProcess);
      }
      playwrightProcess.disposedByTree(scope);

      final isShardedRun = (options.workers ?? 0) > 1;
      if (isShardedRun) {
        _logger.warn(
          'Web sharding is enabled (workers: ${options.workers}). '
          'Patrol hides per-test and step logs to avoid interleaved output. '
          'Use the final summary/report for results.',
        );
      }

      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: playwrightProcess.listenStdOut,
              scope: scope,
              log: _logger.info,
              reportPath: testReportDir,
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps || isShardedRun,
              clearTestSteps: clearTestSteps,
              hideTestLifecycle: isShardedRun,
              onLogEntry: onLogEntry,
            )
            ..listen()
            ..startTimer();

      final stderrSubscription =
          playwrightProcess.stderr
              .transform(const SystemEncoding().decoder)
              .transform(const LineSplitter())
              .listen((line) {
                _logger.detail('Playwright stderr: $line');
              })
            ..disposedBy(scope);

      playwrightProcess.exitCode.then((exitCode) {
        if (!completer.isCompleted) {
          stderrSubscription.cancel();
          patrolLogReader.stopTimer();
          _logger.info(patrolLogReader.summary);

          if (patrolLogReader.failedTestsCount > 0) {
            completer.completeError('Some tests failed.');
          } else if (exitCode != 0) {
            completer.completeError(
              'Playwright process exited unexpectedly with code $exitCode',
            );
          } else {
            completer.complete();
          }
        }
      }).ignore();
    });

    return completer.future;
  }

  Future<void> _runPlaywrightDevelop(
    String port,
    WebAppOptions options, {
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    void Function(Entry entry)? onLogEntry,
  }) async {
    _logger.info('Running Playwright tests using debugger on port: $port');

    final webRunnerPath = await _getWebRunnerPath();
    _ensureWebRunnerExists(webRunnerPath);
    try {
      await _ensureNodeDependencies(webRunnerPath);
    } on Object {
      if (_quitting) {
        return;
      }
      rethrow;
    }
    if (_quitting) {
      return;
    }

    final testResultsDir =
        options.resultsDir ?? '${Directory.current.path}/test-results';
    final testReportDir =
        options.reportDir ?? '${Directory.current.path}/playwright-report';

    _logger
      ..detail('Test results will be saved to: $testResultsDir')
      ..detail('Test report will be saved to: $testReportDir');

    _throwIfInterrupted();
    // The driver survives hot restarts and idles for the whole session.
    final playwrightProcess = await _processManager.start(
      ['npx', 'ts-node', 'tests/develop.ts'],
      workingDirectory: webRunnerPath,
      environment: {
        'DEBUGGER_PORT': port,
        'PATROL_TEST_RESULTS_DIR': testResultsDir,
        'PATROL_TEST_REPORT_DIR': testReportDir,
        'PATROL_WEB_JSON_OUTPUT_NAME': 'results.json',
        'PATROL_WEB_JSON_OUTPUT_DIR': testReportDir,
        ...Platform.environment,
      },
      runInShell: true,
    );
    _playwrightDevelopProcess = playwrightProcess;
    await _killTreeOnDispose(playwrightProcess);

    PatrolLogReader(
        listenStdOut: playwrightProcess.listenStdOut,
        scope: _disposeScope,
        log: _logger.info,
        reportPath: testReportDir,
        showFlutterLogs: showFlutterLogs,
        hideTestSteps: hideTestSteps,
        clearTestSteps: clearTestSteps,
        onLogEntry: onLogEntry,
      )
      ..listen()
      ..startTimer();

    playwrightProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) => _logger.detail('Playwright stderr: $line'))
        .disposedBy(_disposeScope);

    playwrightProcess.exitCode.then((exitCode) async {
      _playwrightDevelopProcess = null;
      if (_quitting) {
        return;
      }
      _quitting = true;
      if (exitCode == 0) {
        // Also fires when Chrome crashes, so don't claim the user closed it.
        _logger.info(
          'The browser was closed or disconnected. Quitting the develop '
          'session.',
        );
      } else {
        _logger.err(
          'The Playwright driver exited unexpectedly with code $exitCode. '
          'Quitting the develop session.',
        );
        _driverFailure = 'The Playwright driver exited with code $exitCode';
      }
      await _stopFlutterProcess();
    }).ignore();
  }

  Future<String> _getWebRunnerPath() async {
    try {
      final packageConfig = await findPackageConfig(Directory.current);

      if (packageConfig == null) {
        throw Exception(
          'Package configuration not found.\n'
          'Please run "dart pub get" to generate the package configuration.',
        );
      }

      final patrolPackage = packageConfig['patrol'];
      if (patrolPackage == null) {
        throw Exception(
          'patrol package not found in package configuration.\n'
          'Please ensure patrol is added as a dependency and run "dart pub get".',
        );
      }

      final packagePath = patrolPackage.root.toFilePath();
      return '$packagePath/web_runner';
    } catch (err) {
      throw Exception(
        'Failed to locate patrol package: $err\n'
        'Please ensure your project dependencies are properly resolved by running "dart pub get".',
      );
    }
  }

  void _ensureWebRunnerExists(String webRunnerPath) {
    final webRunnerDir = Directory(webRunnerPath);

    if (!webRunnerDir.existsSync()) {
      throw Exception(
        'web_runner directory not found at: $webRunnerPath\n'
        'This should be automatically resolved from the patrol package.\n'
        'Please ensure patrol is properly installed and try running "dart pub get".',
      );
    }

    final requiredFiles = [
      'package.json',
      'playwright.config.ts',
      'tests/test.spec.ts',
      'tests/develop.ts',
    ];

    for (final file in requiredFiles) {
      if (!File('$webRunnerPath/$file').existsSync()) {
        throw Exception(
          'Missing required file: $webRunnerPath/$file\n'
          'This file should be present in the patrol package.\n'
          'Please ensure patrol is properly installed.',
        );
      }
    }
  }

  /// Extracts the web server URL from a `flutter run` output line, e.g.
  /// "lib/main.dart is being served at https://localhost:8080". Returns null
  /// unless [line] contains an http or https URL with a port.
  @visibleForTesting
  static String? extractWebServerUrl(String line) =>
      RegExp(r'https?://[^/\s]+:\d+').firstMatch(line)?.group(0);

  /// Returns what to do when `npx playwright install chromium` failed because
  /// the bundled Playwright has no Chromium build for this OS, or null when
  /// [output] shows a different failure.
  @visibleForTesting
  static String? playwrightUnsupportedPlatformHint(String output) {
    final platform = RegExp(
      r'does not support chromium on (\S+)',
    ).firstMatch(output)?.group(1);
    if (platform == null) {
      return null;
    }

    final ubuntu = RegExp(
      r'^ubuntu(\d+)\.\d+-(x64|arm64)$',
    ).firstMatch(platform);
    final major = int.tryParse(ubuntu?.group(1) ?? '');
    if (major != null && major < 20) {
      return 'Playwright has no Chromium build for $platform because this '
          'Ubuntu version is too old. Run web tests on Ubuntu 20.04 or newer.';
    }

    final override = ubuntu == null
        ? ''
        : ', or set PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-${ubuntu.group(2)} '
              'to use a supported Chromium build';
    return 'The Playwright version bundled with the patrol package cannot '
        'install Chromium on $platform. Update the patrol package to the '
        'latest version$override.';
  }

  @visibleForTesting
  Future<bool> verifyServerReady(String url) async {
    try {
      _logger.detail('Verifying server is ready at: $url');

      // Try to make a simple HTTP request to verify server is responding.
      // Accepts a self-signed certificate only from this server; whether the
      // browser trusts it is up to --web-ignore-https-errors.
      final uri = Uri.parse(url);
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5)
        ..badCertificateCallback = (cert, host, port) =>
            host == uri.host && port == uri.port;

      final request = await client.getUrl(uri);
      final response = await request.close();

      client.close();

      final isReady = response.statusCode == 200;
      _logger.detail(
        'Server verification: ${isReady ? 'SUCCESS' : 'FAILED'} (status: ${response.statusCode})',
      );

      return isReady;
    } catch (err) {
      _logger.detail('Server verification failed: $err');
      return false;
    }
  }

  Future<void> _ensureNodeDependencies(String webRunnerPath) async {
    _logger.info('Installing Node.js dependencies...');

    final nodeResult = await _runInstall([
      'npm',
      'install',
    ], workingDirectory: webRunnerPath);

    if (nodeResult.exitCode != 0) {
      throw ProcessException(
        'npm',
        ['install'],
        'Failed to install Node.js dependencies:\n'
            'STDOUT: ${nodeResult.stdout}\n'
            'STDERR: ${nodeResult.stderr}',
        nodeResult.exitCode,
      );
    }

    _logger
      ..info('Node.js dependencies installed successfully.')
      ..info('Installing Playwright dependencies...');
    final result = await _runInstall([
      'npx',
      'playwright',
      'install',
      'chromium',
    ], workingDirectory: webRunnerPath);

    if (result.exitCode != 0) {
      final hint = playwrightUnsupportedPlatformHint(
        '${result.stdout}\n${result.stderr}',
      );
      throw ProcessException(
        'npx',
        ['playwright', 'install', 'chromium'],
        '${hint == null ? '' : '$hint\n'}'
            'Failed to install Playwright dependencies:\n'
            'STDOUT: ${result.stdout}\n'
            'STDERR: ${result.stderr}',
        result.exitCode,
      );
    }
  }

  /// Runs [command], kept in [_installProcess] so a quit can kill it.
  Future<ProcessResult> _runInstall(
    List<String> command, {
    required String workingDirectory,
  }) async {
    final process = await _processManager.start(
      command,
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    _installProcess = process;

    try {
      await _killTreeOnDispose(process);

      // Drain both pipes so a full buffer can't stall the process.
      final stdoutFuture = process.stdout
          .transform(const SystemEncoding().decoder)
          .join();
      final stderrFuture = process.stderr
          .transform(const SystemEncoding().decoder)
          .join();

      return ProcessResult(
        process.pid,
        await process.exitCode,
        await stdoutFuture,
        await stderrFuture,
      );
    } finally {
      _installProcess = null;
    }
  }

  /// Kills a running dependency install and everything it spawned.
  Future<void> _killInstall() async {
    final install = _installProcess;
    if (install == null) {
      return;
    }
    await _killProcessTree(install.pid);
    install.kill(ProcessSignal.sigkill);
  }

  /// Kills every descendant of [pid]; `npm` children outlive the shell.
  Future<void> _killProcessTree(int pid) async {
    try {
      if (Platform.isWindows) {
        await _processManager.run(['taskkill', '/T', '/F', '/PID', '$pid']);
        return;
      }
      final children = await _processManager.run(['pgrep', '-P', '$pid']);
      final childPids = LineSplitter.split(
        children.stdout as String,
      ).map(int.tryParse).nonNulls;
      for (final childPid in childPids) {
        await _killProcessTree(childPid);
        _processManager.killPid(childPid, ProcessSignal.sigkill);
      }
    } catch (err) {
      _logger.detail('Could not kill the process tree of $pid: $err');
    }
  }
}
