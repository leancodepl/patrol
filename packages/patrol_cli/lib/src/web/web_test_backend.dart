import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:process/process.dart';

class WebTestBackend {
  WebTestBackend({
    required ProcessManager processManager,
    required Logger logger,
  })  : _processManager = processManager,
        _logger = logger;

  final ProcessManager _processManager;
  final Logger _logger;

  Future<void> build(WebAppOptions options) async {
    _logger.detail('Building web app for testing...');

    // Warn if flavor is specified for web (not supported)
    if (options.flutter.flavor != null) {
      _logger.warn(
        'Flavor "${options.flutter.flavor}" is not supported for web platform and will be ignored.',
      );
    }

    final result = await _processManager.run([
      options.flutter.command.executable,
      'build',
      'web',
      '--target=${options.flutter.target}',
      '--${options.flutter.buildMode.name}',
      // Note: --flavor is not supported for web, so we don't include it
      ...options.flutter.dartDefines.entries
          .map((e) => '--dart-define=${e.key}=${e.value}'),
      ...options.flutter.dartDefineFromFilePaths
          .map((e) => '--dart-define-from-file=$e'),
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

  Future<void> execute(
    WebAppOptions options,
    Device device, {
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
  }) async {
    _logger.detail('Starting web test execution...');

    // Start Flutter web server
    final flutterProcess = await _startFlutterWebServer(options);

    try {
      // Wait for server to be ready and get the URL
      final baseUrl = await _waitForWebServer(flutterProcess);

      // Run Playwright tests
      await _runPlaywrightTests(baseUrl, options);
    } finally {
      // Clean up Flutter process gracefully
      _logger.detail('Stopping Flutter web server...');

      // Try graceful shutdown first
      flutterProcess.kill();

      // Wait a bit for graceful shutdown
      try {
        await flutterProcess.exitCode.timeout(
          const Duration(seconds: 5),
        );
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

  Future<Process> _startFlutterWebServer(WebAppOptions options) async {
    _logger.detail('Starting Flutter web server...');

    // Warn if flavor is specified for web (not supported)
    if (options.flutter.flavor != null) {
      _logger.warn(
        'Flavor "${options.flutter.flavor}" is not supported for web platform and will be ignored.',
      );
    }

    final process = await _processManager.start([
      options.flutter.command.executable,
      'run',
      '-d',
      'web-server',
      '--target=${options.flutter.target}',
      '--${options.flutter.buildMode.name}',
      // Note: --flavor is not supported for web, so we don't include it
      ...options.flutter.dartDefines.entries
          .map((e) => '--dart-define=${e.key}=${e.value}'),
      ...options.flutter.dartDefineFromFilePaths
          .map((e) => '--dart-define-from-file=$e'),
    ]);

    return process;
  }

  Future<String> _waitForWebServer(Process flutterProcess) async {
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
      if (urlMatch != null && !completer.isCompleted) {
        final url = urlMatch.group(0)!;
        _logger.info('Web server started at: $url');

        // Verify server is actually responding before completing
        _verifyServerReady(url).then((isReady) {
          if (!completer.isCompleted && isReady) {
            stdoutSubscription.cancel();
            stderrSubscription.cancel();
            completer.complete(url);
          }
        }).catchError((Object error) {
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
          completer.completeError('Flutter web server failed to start: $line');
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
    Timer(
      const Duration(minutes: 2),
      () {
        if (!completer.isCompleted) {
          stdoutSubscription.cancel();
          stderrSubscription.cancel();
          completer.completeError('Timeout waiting for web server to start');
        }
      },
    );

    return completer.future;
  }

  Future<void> _runPlaywrightTests(
    String baseUrl,
    WebAppOptions options,
  ) async {
    _logger.info('Running Playwright tests against: $baseUrl');

    // Ensure web_runner directory exists and is properly set up
    await _ensureWebRunnerExists();

    final webRunnerPath = _getWebRunnerPath();

    // Install Node.js dependencies if needed
    await _ensureNodeDependencies(webRunnerPath);

    final result = await _processManager.run(
      ['npx', 'playwright', 'test'],
      workingDirectory: webRunnerPath,
      environment: {
        'BASE_URL': baseUrl,
        ...Platform.environment,
      },
      runInShell: true,
    );

    if (result.exitCode != 0) {
      _logger.err('Playwright test execution failed:');
      final stdout = result.stdout.toString();
      final stderr = result.stderr.toString();

      if (stdout.isNotEmpty) {
        _logger.err('STDOUT: $stdout');
      }
      if (stderr.isNotEmpty) {
        _logger.err('STDERR: $stderr');
      }

      throw ProcessException(
        'playwright',
        ['test'],
        'Playwright tests failed with exit code ${result.exitCode}',
        result.exitCode,
      );
    }
  }

  String _getWebRunnerPath() {
    // Use web_runner from patrol_cli package instead of project root
    // Get the path to patrol_cli package
    final packageConfigPath =
        '${Directory.current.path}/.dart_tool/package_config.json';
    final packageConfigFile = File(packageConfigPath);

    if (!packageConfigFile.existsSync()) {
      throw Exception(
        'Package configuration file not found at: $packageConfigPath\n'
        'Please run "dart pub get" to generate the package configuration.',
      );
    }

    try {
      final packageConfigContent = packageConfigFile.readAsStringSync();
      final packageConfig =
          jsonDecode(packageConfigContent) as Map<String, dynamic>;
      final packages = packageConfig['packages'] as List<dynamic>;

      // Find patrol_cli package
      for (final package in packages) {
        final packageMap = package as Map<String, dynamic>;
        if (packageMap['name'] == 'patrol_cli') {
          final packageUri = packageMap['rootUri'] as String;
          // Convert relative URI to absolute path
          String packagePath;
          if (packageUri.startsWith('../')) {
            // Relative path from .dart_tool/package_config.json
            packagePath =
                Directory('${Directory.current.path}/.dart_tool/$packageUri')
                    .resolveSymbolicLinksSync();
          } else if (packageUri.startsWith('file://')) {
            packagePath = Uri.parse(packageUri).toFilePath();
          } else {
            packagePath = packageUri;
          }
          return '$packagePath/web_runner';
        }
      }
    } catch (e) {
      throw Exception(
        'Failed to parse package_config.json: $e\n'
        'Please ensure your project dependencies are properly resolved by running "dart pub get".',
      );
    }

    throw Exception(
      'patrol_cli package not found in package configuration.\n'
      'Please ensure patrol_cli is added as a dependency and run "dart pub get".',
    );
  }

  Future<void> _ensureWebRunnerExists() async {
    final webRunnerPath = _getWebRunnerPath();
    final webRunnerDir = Directory(webRunnerPath);

    if (!webRunnerDir.existsSync()) {
      throw Exception('web_runner directory not found at: $webRunnerPath\n'
          'This should be automatically resolved from the patrol_cli package.\n'
          'Please ensure patrol_cli is properly installed and try running "dart pub get".');
    }

    // Verify required files exist
    final requiredFiles = [
      'package.json',
      'playwright.config.ts',
      'tests/patrol.spec.ts',
    ];

    for (final file in requiredFiles) {
      if (!File('$webRunnerPath/$file').existsSync()) {
        throw Exception('Missing required file: $webRunnerPath/$file\n'
            'This file should be present in the patrol_cli package.\n'
            'Please ensure patrol_cli is properly installed.');
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
    final needsInstall = !nodeModulesDir.existsSync() ||
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
  }
}
