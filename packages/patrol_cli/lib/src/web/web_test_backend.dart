import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/coverage/bind_unused_port.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';
import 'package:process/process.dart';

const _kDefaultWebServerTimeoutSeconds = 120;

/// Strips the `[  +12 ms]` prefix that `flutter run --verbose` puts on every
/// line. Harmless on non-verbose output.
final _flutterLogPrefix = RegExp(r'^\[[\s\d+ms]*\]\s?');

const _developKeyCommands =
    'Patrol develop key commands:\n'
    'r Hot restart\n'
    'h Print this help message\n'
    'q Quit (terminate the process and application on the device)';

class WebTestBackend {
  WebTestBackend({
    required ProcessManager processManager,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  }) : _processManager = processManager,
       _logger = logger,
       _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final Logger _logger;
  final DisposeScope _disposeScope;

  /// The Chrome debugger port discovered during [develop].
  String? get debuggerPort => _debuggerPort;
  String? _debuggerPort;

  /// The resident `flutter run` process that owns the develop session. Kept for
  /// the whole session — hot restart goes through its stdin.
  Process? _flutterProcess;

  /// The Playwright develop process, kept alive for the whole develop session.
  Process? _playwrightDevelopProcess;

  /// True once `flutter run` reported that it is accepting key commands, i.e.
  /// once it is safe to ask it for a hot restart.
  bool _hotRestartActive = false;

  /// True between asking `flutter run` for a hot restart and it reporting the
  /// outcome. `flutter run` silently ignores key commands while it is busy, so
  /// without this the user would press "r" and see nothing happen.
  bool _restartInFlight = false;

  /// Set when the user presses 'q' so that subprocess kills are not surfaced
  /// as unexpected exits.
  bool _quitting = false;

  /// Set for the duration of [develop] so the stdout handler can act on the
  /// DevTools URL `flutter run` prints.
  FlutterTool? _flutterTool;
  bool _openDevtools = false;

  Future<void> build(WebAppOptions options) async {
    _logger.detail('Building web app for testing...');

    final result = await _processManager.run(
      options.toFlutterBuildInvocation(),
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

  Future<void> execute(
    WebAppOptions options,
    Device device, {
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
  }) async {
    _logger
      ..detail('Starting web test execution...')
      ..info('Building Flutter web app...');

    // Start Flutter web server
    final flutterProcess = await _startFlutterWebServer(
      options,
      develop: false,
    );

    try {
      // Wait for server to be ready and get the URL
      final baseUrl = await _waitForWebServer(
        flutterProcess,
        serverTimeout: options.serverTimeout,
      );

      // Run Playwright tests
      await _runPlaywrightTests(
        baseUrl,
        options,
        showFlutterLogs: showFlutterLogs,
        hideTestSteps: hideTestSteps,
        clearTestSteps: clearTestSteps,
      );
    } finally {
      // Clean up Flutter process gracefully
      _logger.detail('Stopping Flutter web server...');

      // Try graceful shutdown first
      flutterProcess.kill();

      // Wait a bit for graceful shutdown
      try {
        await flutterProcess.exitCode.timeout(const Duration(seconds: 5));
      } on TimeoutException {
        // Timeout occurred, force kill
        _logger.detail(
          'Graceful shutdown timed out, force killing Flutter process...',
        );
        flutterProcess.kill(ProcessSignal.sigkill);
        await flutterProcess.exitCode;
      }
    }
  }

  /// Runs a develop session on web.
  ///
  /// A single `flutter run -d chrome` and a single Playwright driver stay alive
  /// for the whole session, and "r" performs a real Flutter hot restart instead
  /// of relaunching them. A web hot restart re-runs `main()` in the same page
  /// without navigating, so `window.__patrol__*` and the bindings Playwright
  /// exposed on the browser context survive it — see `initAppService()` in
  /// package:patrol, which short-circuits when Playwright has already
  /// initialised the page.
  ///
  /// Requires the fix from https://github.com/flutter/flutter/pull/183838,
  /// without which hot restart silently serves stale code for entrypoints
  /// outside `lib/` (the develop test bundle is one).
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

    _flutterTool = flutterTool;
    _openDevtools = openDevtools;

    StdinModes? previousStdinModes;
    if (io.stdin.hasTerminal) {
      previousStdinModes = flutterTool.enableInteractiveMode();
    }

    // Pick the Chrome debugging port up front instead of scraping it out of
    // `flutter run --verbose` output. It's then known before Chrome even
    // launches, so consumers (e.g. MCP screenshots) can use it right away.
    final debuggerPort = await bindUnusedPort<int>((port) => port);
    _debuggerPort = '$debuggerPort';

    final flutterProcess = await _startFlutterWebServer(
      options,
      develop: true,
      browserDebugPort: debuggerPort,
    );
    _flutterProcess = flutterProcess;

    final exited = Completer<void>();

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
        _playwrightDevelopProcess?.kill();
        await _stopFlutterProcess();
      }
    });

    try {
      await _watchFlutterRun(flutterProcess, exited);

      await _waitForWebDebugger(
        flutterProcess,
        debuggerPort,
        serverTimeout: options.serverTimeout,
      );

      await _runPlaywrightDevelop(
        '$debuggerPort',
        options,
        showFlutterLogs: showFlutterLogs,
        hideTestSteps: hideTestSteps,
        clearTestSteps: clearTestSteps,
        onLogEntry: onLogEntry,
      );

      // The session lives as long as `flutter run` does. Quitting completes it
      // through _stopFlutterProcess, a crash through the exitCode handler.
      await exited.future;
    } finally {
      await stdinSubscription.cancel();
      _playwrightDevelopProcess?.kill();
      await _stopFlutterProcess();
      final modes = previousStdinModes;
      if (modes != null) {
        flutterTool.revertInteractiveMode(modes);
      }
    }
  }

  /// Asks the resident `flutter run` for a hot restart.
  ///
  /// The `flush()` matters: without it the byte sits in the pipe buffer and
  /// `flutter run` never sees the key command.
  Future<void> _requestHotRestart(String target) async {
    final process = _flutterProcess;
    if (process == null) {
      return;
    }
    if (!_hotRestartActive) {
      _logger.warn('Hot Restart: not attached to the app yet!');
      return;
    }
    if (_restartInFlight) {
      _logger.warn('Hot Restart: a restart is already in progress');
      return;
    }

    _restartInFlight = true;
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
      // Ask flutter to quit so it closes Chrome itself. A hard kill (SIGTERM)
      // leaves the Chrome child process orphaned on macOS.
      process.stdin.add('q'.codeUnits);
      await process.stdin.flush();
    } on Object catch (err) {
      _logger.detail('Failed to send quit to Flutter: $err');
    }

    try {
      await process.exitCode.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Graceful shutdown didn't work — force kill.
      _logger.detail(
        'Graceful shutdown timed out, force killing Flutter process...',
      );
      process.kill(ProcessSignal.sigkill);
      await process.exitCode;
    }
  }

  /// Attaches the session-long listeners to the resident `flutter run`.
  ///
  /// This owns the only subscription to flutter's stdout, so the readiness
  /// signal and the restart outcome are read from the same stream instead of
  /// competing subscriptions.
  Future<void> _watchFlutterRun(Process process, Completer<void> exited) async {
    final debugServiceReady = Completer<void>();
    _debugServiceReady = debugServiceReady;

    process.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen(_onFlutterLine)
        .disposedBy(_disposeScope);

    process.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) => _logger.detail('Flutter stderr: $line'))
        .disposedBy(_disposeScope);

    process.exitCode.then((exitCode) {
      _hotRestartActive = false;
      _restartInFlight = false;
      if (!debugServiceReady.isCompleted) {
        debugServiceReady.completeError(
          'Flutter process exited unexpectedly with code $exitCode',
        );
      }
      if (exited.isCompleted) {
        return;
      }
      if (exitCode != 0 && !_quitting) {
        exited.completeError(
          'Flutter process exited unexpectedly with code $exitCode',
        );
      } else {
        exited.complete();
      }
    }).ignore();
  }

  Completer<void>? _debugServiceReady;

  void _onFlutterLine(String rawLine) {
    final line = rawLine.replaceFirst(_flutterLogPrefix, '');

    // PATROL_LOG entries reach us twice: flutter forwards the app's `print`,
    // and the Playwright driver re-emits them from the browser console. The
    // Playwright stream is the one wired into PatrolLogReader, so drop these.
    if (line.contains('PATROL_LOG')) {
      return;
    }

    if (line == 'Flutter run key commands.') {
      if (!_hotRestartActive) {
        _hotRestartActive = true;
        _logger.success(
          'Hot Restart: attached to the app\n$_developKeyCommands',
        );
      }
      return;
    }

    if (line.startsWith('The Flutter DevTools debugger and profiler')) {
      final url = getDevtoolsUrl(line);
      _logger.success('Patrol DevTools extension is available at $url');
      if (_openDevtools) {
        _flutterTool?.openDevtoolsPage(url).ignore();
      }
      return;
    }

    if (line.startsWith('Debug service listening on')) {
      final completer = _debugServiceReady;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
      _logger.detail('Flutter: $line');
      return;
    }

    if (line.startsWith('Restarted application in')) {
      _restartInFlight = false;
      _logger.success(line);
      return;
    }

    if (line == 'Try again after fixing the above error(s).' ||
        line.contains('Failed to recompile application.')) {
      _restartInFlight = false;
      _logger.err('Hot restart failed. Fix the errors above and press "r".');
      return;
    }

    // Surface Dart test failures, which reach us over flutter's stdout.
    if (line.contains('EXCEPTION CAUGHT') ||
        line.contains('TestFailure') ||
        line.startsWith('Expected:') ||
        line.startsWith('  Actual:') ||
        line.startsWith('   Which:') ||
        line.contains('Test failed.') ||
        line.contains('Some tests failed.')) {
      _logger.err(line);
      return;
    }

    _logger.detail('Flutter: $line');
  }

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
          final urlMatch = RegExp(r'http://[^/]+:\d+').firstMatch(line);

          // [CHROME]: DevTools listening on ws://127.0.0.1:38861/devtools/browser/431953d3-ef67-428f-9321-9317256022d0
          if (urlMatch != null && !completer.isCompleted) {
            final url = urlMatch.group(0)!;
            _logger.info('Web server started at: $url');

            // Verify server is actually responding before completing
            _verifyServerReady(url)
                .then((isReady) {
                  if (!completer.isCompleted && isReady) {
                    // IMPORTANT: Do NOT cancel subscriptions here!
                    // Cancelling stdout/stderr subscriptions causes Flutter's
                    // web server to terminate unexpectedly. Keep them active
                    // so Flutter continues serving the app.
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

    // Listen to stderr for errors
    stderrSubscription = flutterProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _logger.detail('Flutter stderr: $line');

          // Check for critical errors that would prevent server startup
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

    // Check if process exits unexpectedly
    flutterProcess.exitCode.then((exitCode) {
      if (!completer.isCompleted && exitCode != 0) {
        stdoutSubscription.cancel();
        stderrSubscription.cancel();
        completer.completeError(
          'Flutter process exited unexpectedly with code $exitCode',
        );
      }
    }).ignore();

    // Timeout after configured duration (default: 2 minutes)
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

  /// Whether [url] answers with HTTP 200. Unlike [_verifyServerReady] this is
  /// silent, so it can be used as a poll without flooding verbose logs.
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

  /// Waits until Chrome's CDP endpoint answers on [debuggerPort] and the
  /// Flutter debug service has attached to the page.
  ///
  /// The CDP poll replaces scraping `DevTools listening on ws://…` out of
  /// `flutter run --verbose`, which is why develop no longer needs `--verbose`.
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

    // Chrome answering CDP doesn't mean the app page is running yet. The debug
    // service line is printed right before Flutter calls the app's main().
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
  }

  Future<void> _runPlaywrightTests(
    String baseUrl,
    WebAppOptions options, {
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
  }) async {
    _logger.info('Running Playwright tests against: $baseUrl');
    final completer = Completer<void>();

    await _disposeScope.run((scope) async {
      // Ensure web_runner directory exists and is properly set up
      await _ensureWebRunnerExists();

      final webRunnerPath = await _getWebRunnerPath();

      // Install Node.js dependencies if needed
      await _ensureNodeDependencies(webRunnerPath);

      final testResultsDir =
          options.resultsDir ?? '${Directory.current.path}/test-results';
      final testReportDir =
          options.reportDir ?? '${Directory.current.path}/playwright-report';

      _logger
        ..detail('Test results will be saved to: $testResultsDir')
        ..detail('Test report will be saved to: $testReportDir');

      final playwrightProcess =
          await _processManager.start(
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
            )
            ..disposedBy(scope);

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
            )
            ..listen()
            ..startTimer();

      // Listen to stderr for errors
      final stderrSubscription =
          playwrightProcess.stderr
              .transform(const SystemEncoding().decoder)
              .transform(const LineSplitter())
              .listen((line) {
                _logger.detail('Playwright stderr: $line');
              })
            ..disposedBy(scope);

      // Check if process exits unexpectedly
      playwrightProcess.exitCode.then((exitCode) {
        if (!completer.isCompleted) {
          stderrSubscription.cancel();
          patrolLogReader.stopTimer();
          // TODO: Don't print the summary in develop
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

    await _ensureWebRunnerExists();
    final webRunnerPath = await _getWebRunnerPath();
    await _ensureNodeDependencies(webRunnerPath);

    final testResultsDir =
        options.resultsDir ?? '${Directory.current.path}/test-results';
    final testReportDir =
        options.reportDir ?? '${Directory.current.path}/playwright-report';

    _logger
      ..detail('Test results will be saved to: $testResultsDir')
      ..detail('Test report will be saved to: $testReportDir');

    // The driver attaches to the browser Flutter launched and then idles for
    // the whole session — it survives hot restarts, so unlike the test path
    // this doesn't wait for it to exit.
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

    playwrightProcess.exitCode.then((exitCode) {
      _playwrightDevelopProcess = null;
      if (exitCode != 0 && !_quitting) {
        _logger.err(
          'The Playwright driver exited unexpectedly with code $exitCode. '
          'Platform actions will no longer work; quit and start again.',
        );
      }
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

  Future<void> _ensureWebRunnerExists() async {
    final webRunnerPath = await _getWebRunnerPath();
    final webRunnerDir = Directory(webRunnerPath);

    if (!webRunnerDir.existsSync()) {
      throw Exception(
        'web_runner directory not found at: $webRunnerPath\n'
        'This should be automatically resolved from the patrol package.\n'
        'Please ensure patrol is properly installed and try running "dart pub get".',
      );
    }

    // Verify required files exist
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

  Future<bool> _verifyServerReady(String url) async {
    try {
      _logger.detail('Verifying server is ready at: $url');

      // Try to make a simple HTTP request to verify server is responding
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(Uri.parse(url));
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

  static const _kDependencyTimeoutSeconds = 120;

  Future<void> _ensureNodeDependencies(String webRunnerPath) async {
    _logger.info('Installing Node.js dependencies...');

    final nodeResult = await _runInstallWithTimeout(
      ['npm', 'install'],
      workingDirectory: webRunnerPath,
      timeoutMessage:
          'npm install timed out after $_kDependencyTimeoutSeconds seconds',
    );

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
    final result = await _runInstallWithTimeout(
      ['npx', 'playwright', 'install', 'chromium'],
      workingDirectory: webRunnerPath,
      timeoutMessage:
          'npx playwright install timed out after '
          '$_kDependencyTimeoutSeconds seconds',
    );

    if (result.exitCode != 0) {
      throw ProcessException(
        'npx',
        ['playwright', 'install', 'chromium'],
        'Failed to install Playwright dependencies:\n'
            'STDOUT: ${result.stdout}\n'
            'STDERR: ${result.stderr}',
        result.exitCode,
      );
    }
  }

  /// Runs [command] with a hard timeout, killing the process if it exceeds it.
  ///
  /// Unlike `_processManager.run().timeout()`, timing out here actually
  /// terminates the spawned process (and drains its output) instead of leaving
  /// it running in the background holding lockfiles or other resources.
  Future<ProcessResult> _runInstallWithTimeout(
    List<String> command, {
    required String workingDirectory,
    required String timeoutMessage,
  }) async {
    final process = await _processManager.start(
      command,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    // Drain stdout/stderr concurrently so a full pipe buffer can't stall the
    // process, and capture them for error reporting.
    final stdoutFuture = process.stdout
        .transform(const SystemEncoding().decoder)
        .join();
    final stderrFuture = process.stderr
        .transform(const SystemEncoding().decoder)
        .join();

    final int exitCode;
    try {
      exitCode = await process.exitCode.timeout(
        const Duration(seconds: _kDependencyTimeoutSeconds),
      );
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      // Let the drains complete so we don't leak stream subscriptions.
      await Future.wait([stdoutFuture, stderrFuture]);
      throw TimeoutException(timeoutMessage);
    }

    return ProcessResult(
      process.pid,
      exitCode,
      await stdoutFuture,
      await stderrFuture,
    );
  }
}
