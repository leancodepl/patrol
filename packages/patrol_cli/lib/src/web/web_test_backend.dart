import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:package_config/package_config.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:process/process.dart';

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

  Future<void> build(WebAppOptions options) async {
    _logger.detail('Building web app for testing...');

    final result = await _processManager.run([
      options.flutter.command.executable,
      'build',
      'web',
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
      final baseUrl = await _waitForWebServer(flutterProcess);

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

  Future<void> develop(
    FlutterTool flutterTool,
    WebAppOptions options,
    Device device, {
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
    required Stream<List<int>> stdin,
  }) async {
    _logger.detail('Starting web develop execution...');

    // Start Flutter web server
    final flutterProcess = await _startFlutterWebServer(options, develop: true);

    StdinModes? previousStdinModes;
    if (io.stdin.hasTerminal) {
      previousStdinModes = flutterTool.enableInteractiveMode();
    }

    try {
      // Wait for server to be ready and get the URL
      final port = await _waitForWebDebugger(flutterProcess);

      _attachForHotRestart(flutterProcess, switch (previousStdinModes) {
        final stdinModes? => () => flutterTool.revertInteractiveMode(
          stdinModes,
        ),
        _ => null,
      }, stdin: stdin);

      // Run Playwright tests
      await _runPlaywrightDevelop(port, options);
    } finally {
      if (previousStdinModes != null) {
        flutterTool.revertInteractiveMode(previousStdinModes);
      }

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

  Future<Process> _startFlutterWebServer(
    WebAppOptions options, {
    required bool develop,
  }) async {
    _logger.detail('Starting Flutter web server...');

    final process = await _processManager.start([
      options.flutter.command.executable,
      'run',
      '-d',
      if (develop) 'chrome' else 'web-server',
      ...develop ? ['--verbose'] : [],
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

  Future<String> _waitForWebServer(Process flutterProcess) {
    _logger.detail('Waiting for web server to start...');

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
                    stdoutSubscription.cancel();
                    stderrSubscription.cancel();
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

    // Timeout after 2 minutes
    Timer(const Duration(minutes: 2), () {
      if (!completer.isCompleted) {
        stdoutSubscription.cancel();
        stderrSubscription.cancel();
        completer.completeError('Timeout waiting for web server to start');
      }
    });

    return completer.future;
  }

  Future<String> _waitForWebDebugger(Process flutterProcess) {
    _logger.detail('Waiting for debugger to start...');

    final completer = Completer<String>();
    late StreamSubscription<String> stdoutSubscription;
    late StreamSubscription<String> stderrSubscription;

    stdoutSubscription = flutterProcess.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _logger.detail('Flutter: $line');

          // [CHROME]: DevTools listening on ws://127.0.0.1:38861/devtools/browser/431953d3-ef67-428f-9321-9317256022d0
          final urlMatch = RegExp(
            r'DevTools listening on ws://[^/]+:(\d+)',
          ).firstMatch(line);

          if (urlMatch != null && !completer.isCompleted) {
            final port = urlMatch.group(1)!;
            _logger.info('Debugger started at port: $port');
            completer.complete(port);
          }
        });

    // Listen to stderr for errors
    stderrSubscription = flutterProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _logger.detail('Flutter stderr: $line');
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

    // Timeout after 2 minutes
    Timer(const Duration(minutes: 2), () {
      if (!completer.isCompleted) {
        stdoutSubscription.cancel();
        stderrSubscription.cancel();
        completer.completeError('Timeout waiting for web server to start');
      }
    });

    return completer.future;
  }

  void _attachForHotRestart(
    Process flutterProcess,
    void Function()? revertInteractiveMode, {
    required Stream<List<int>> stdin,
  }) {
    final streamSubscription = stdin.listen((event) {
      final char = String.fromCharCode(event.first);

      _logger.detail('Flutter stdin: $char');

      if (char == 'r' || char == 'R') {
        // if (!_hotRestartActive) {
        //   _logger.warn('Hot Restart: not attached to the app yet!');
        //   return;
        // }

        // _logger.success(
        //   'Hot Restart for entrypoint ${basename(target)}...',
        // );
        flutterProcess.stdin.add('R'.codeUnits);
      } else if (char == 'h' || char == 'H') {
        final helpText = StringBuffer(
          'Patrol develop key commands:\n'
          'r Hot restart\n'
          'h Print this help message\n'
          'q Quit (terminate the process and application on the device)',
        );

        // if (_devtoolsUrl.isNotEmpty) {
        //   helpText.writeln('\nDevTools: $_devtoolsUrl');
        // } else {
        //   helpText.writeln('\nDevTools: not available yet');
        // }

        _logger.success(helpText.toString());
      } else if (char == 'q' || char == 'Q') {
        revertInteractiveMode?.call();

        _logger.success('Quitting process...');
        flutterProcess.kill();

        // Call the uninstall function if provided
        // if (onQuit != null) {
        //   try {
        //     await onQuit();
        //   } catch (err) {
        //     _logger.err('Failed to clean up app: $err');
        //   }
        // }

        exit(0);
      }
    });

    Timer(const Duration(minutes: 2), streamSubscription.cancel);
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
                'BASE_URL': baseUrl,
                'PATROL_TEST_RESULTS_DIR': testResultsDir,
                'PATROL_TEST_REPORT_DIR': testReportDir,
                if (options.retries != null)
                  'PATROL_WEB_RETRIES': options.retries.toString(),
                if (options.video != null)
                  'PATROL_WEB_VIDEO': options.video.toString(),
                if (options.timeout != null)
                  'PATROL_WEB_TIMEOUT': options.timeout.toString(),
                if (options.workers != null)
                  'PATROL_WEB_WORKERS': options.workers.toString(),
                if (options.reporter != null)
                  'PATROL_WEB_REPORTER': options.reporter.toString(),
                if (options.locale != null)
                  'PATROL_WEB_LOCALE': options.locale.toString(),
                if (options.timezone != null)
                  'PATROL_WEB_TIMEZONE': options.timezone.toString(),
                if (options.colorScheme != null)
                  'PATROL_WEB_COLOR_SCHEME': options.colorScheme.toString(),
                if (options.geolocation != null)
                  'PATROL_WEB_GEOLOCATION': options.geolocation.toString(),
                if (options.permissions != null)
                  'PATROL_WEB_PERMISSIONS': options.permissions.toString(),
                if (options.userAgent != null)
                  'PATROL_WEB_USER_AGENT': options.userAgent.toString(),
                if (options.viewport != null)
                  'PATROL_WEB_VIEWPORT': options.viewport.toString(),
                if (options.globalTimeout != null)
                  'PATROL_WEB_GLOBAL_TIMEOUT': options.globalTimeout.toString(),
                if (options.shard != null)
                  'PATROL_WEB_SHARD': options.shard.toString(),
                if (options.fullyParallel != null)
                  'PATROL_WEB_FULLY_PARALLEL': options.fullyParallel.toString(),
                if (options.headless != null)
                  'PATROL_WEB_HEADLESS': options.headless.toString(),
                ...Platform.environment,
              },
              runInShell: true,
            )
            ..disposedBy(scope);

      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: playwrightProcess.listenStdOut,
              scope: scope,
              log: _logger.info,
              reportPath: testReportDir,
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps,
              clearTestSteps: clearTestSteps,
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
          if (exitCode != 0) {
            completer.completeError(
              'Playwright process exited unexpectedly with code $exitCode',
            );
          } else {
            patrolLogReader.stopTimer();

            // TODO: Don't print the summary in develop
            _logger.info(patrolLogReader.summary);

            completer.complete();
          }
        }
      }).ignore();
    });

    return completer.future;
  }

  Future<void> _runPlaywrightDevelop(String port, WebAppOptions options) async {
    _logger.info('Running Playwright tests using debugger on port: $port');

    // Ensure web_runner directory exists and is properly set up
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

    final completer = Completer<void>();
    late StreamSubscription<String> stdoutSubscription;
    late StreamSubscription<String> stderrSubscription;

    stdoutSubscription = playwrightProcess.stdout
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _logger.detail('Playwright: $line');
        });

    // Listen to stderr for errors
    stderrSubscription = playwrightProcess.stderr
        .transform(const SystemEncoding().decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _logger.detail('Playwright stderr: $line');
        });

    // Check if process exits unexpectedly
    playwrightProcess.exitCode.then((exitCode) {
      if (!completer.isCompleted) {
        stdoutSubscription.cancel();
        stderrSubscription.cancel();
        if (exitCode != 0) {
          completer.completeError(
            'Playwright process exited unexpectedly with code $exitCode',
          );
        } else {
          completer.complete();
        }
      }
    }).ignore();

    return completer.future;
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
    } catch (e) {
      throw Exception(
        'Failed to locate patrol package: $e\n'
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
    } catch (e) {
      _logger.detail('Server verification failed: $e');
      return false;
    }
  }

  Future<void> _ensureNodeDependencies(String webRunnerPath) async {
    _logger.detail('Checking Node.js dependencies in web_runner...');

    final nodeModulesDir = Directory('$webRunnerPath/node_modules');
    final packageLockFile = File('$webRunnerPath/package-lock.json');

    // Check if node_modules exists and has content
    final needsInstall =
        !nodeModulesDir.existsSync() ||
        nodeModulesDir.listSync().isEmpty ||
        !packageLockFile.existsSync();

    if (needsInstall) {
      _logger.info('Installing Node.js dependencies...');

      final result = await _processManager.run(
        ['npm', 'install'],
        workingDirectory: webRunnerPath,
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw ProcessException(
          'npm',
          ['install'],
          'Failed to install Node.js dependencies:\n'
              'STDOUT: ${result.stdout}\n'
              'STDERR: ${result.stderr}',
          result.exitCode,
        );
      }

      _logger.info('Node.js dependencies installed successfully.');
    } else {
      _logger.detail('Node.js dependencies are already installed.');
    }

    _logger.info('Installing Playwright dependencies...');
    final result = await _processManager.run(
      ['npx', 'playwright', 'install'],
      workingDirectory: webRunnerPath,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw ProcessException(
        'npx',
        ['playwright', 'install'],
        'Failed to install Playwright dependencies:\n'
            'STDOUT: ${result.stdout}\n'
            'STDERR: ${result.stderr}',
        result.exitCode,
      );
    }
  }
}
