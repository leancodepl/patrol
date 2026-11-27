import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/coverage/bind_unused_port.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/crossplatform/flutter_version_at_least.dart';
import 'package:patrol_cli/src/crossplatform/stop_flutter_run.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/linux/develop_keys.dart';
import 'package:patrol_cli/src/linux/patrol_app_service_client.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

/// Returns the app server port to use: [preferredPort] if it's free, otherwise
/// another free port.
typedef AppServerPortResolver = Future<int> Function(int preferredPort);

/// Builds, runs and develops Patrol tests on Linux desktop.
///
/// Linux has no native test runner (like XCTest or Android instrumentation),
/// so `patrol test` drives the app itself: it launches the built binary once
/// per test and asks the app's `PatrolAppService` HTTP server to run that test.
class LinuxTestBackend {
  LinuxTestBackend({
    required this._processManager,
    required this._platform,
    required this._rootDirectory,
    required DisposeScope parentDisposeScope,
    required this._logger,
    this._httpClient,
    @visibleForTesting AppServerPortResolver? resolveAppServerPort,
    @visibleForTesting this._pollInterval = const Duration(milliseconds: 500),
    @visibleForTesting this._readyTimeout = const Duration(seconds: 60),
    @visibleForTesting this._killTimeout = const Duration(seconds: 5),
    @visibleForTesting
    this._flutterRunStopTimeout = const Duration(seconds: 10),
    @visibleForTesting String Function(FlutterCommand)? flutterVersionOf,
  }) : _flutterVersionOf =
           flutterVersionOf ??
           ((command) => FlutterVersion.fromCLI(command).version),
       _disposeScope = DisposeScope(),
       _resolveAppServerPort = resolveAppServerPort ?? _freeAppServerPort {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final NativePlatform _platform;
  final Directory _rootDirectory;
  final DisposeScope _disposeScope;
  final Logger _logger;
  final http.Client? _httpClient;
  final AppServerPortResolver _resolveAppServerPort;
  final Duration _pollInterval;
  final Duration _readyTimeout;
  final Duration _killTimeout;
  final Duration _flutterRunStopTimeout;
  final String Function(FlutterCommand) _flutterVersionOf;

  /// The first Flutter whose `flutter build linux` and `flutter run -d linux`
  /// accept `--flavor`.
  static const minFlavorFlutterVersion = '3.47.0';

  /// Runs `flutter build linux` for [options].
  Future<void> build(LinuxAppOptions options) async {
    _assertFlavorSupported(options);
    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task(
        'Building $subject (${options.flutter.buildMode.name})',
      );

      var flutterBuildKilled = false;
      final process = await _processManager.start(
        options.toFlutterBuildInvocation(options.flutter.buildMode),
        runInShell: true,
      );
      scope.addDispose(() {
        process.kill();
        flutterBuildKilled = true; // `flutter build` has exit code 0 on SIGINT
      });
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      final exitCode = await process.exitCode;
      final flutterCommand = options.flutter.command;
      if (exitCode != 0) {
        final cause =
            '`$flutterCommand build linux` exited with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throwToolExit(cause);
      } else if (flutterBuildKilled) {
        final cause = '`$flutterCommand build linux` was interrupted';
        task.fail('Failed to build $subject ($cause)');
        throwToolInterrupted(cause);
      }
      task.complete('Completed building $subject');
    });
  }

  /// Runs the develop bundle with `flutter run -d <device>` and forwards the
  /// hot restart keys from [stdin] to it.
  ///
  /// `flutter attach` can't find the Dart VM service of a desktop app that the
  /// Flutter tool didn't start itself, so the web model is used instead of
  /// the attach model of Android and iOS.
  Future<void> develop(
    FlutterTool flutterTool,
    LinuxAppOptions options,
    Device device, {
    required Stream<List<int>> stdin,
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
    void Function(Entry entry)? onLogEntry,
  }) async {
    _assertFlavorSupported(options);
    _warnIfNoDisplay();
    await _disposeScope.run((scope) async {
      // Not in a shell, so the SIGKILL fallback of [stopFlutterRun] reaches
      // `flutter run` itself.
      final process = await _processManager.start(
        options.toFlutterRunInvocation(deviceId: device.id),
      );
      var exited = false;
      unawaited(process.exitCode.then((_) => exited = true));

      // Quit (`q`) and dispose (Ctrl+C) both stop `flutter run` the way web
      // develop does: `q`, so it stops the app, then SIGKILL if it hangs.
      var quitRequested = false;
      Future<void>? stopping;
      Future<void> stop() {
        quitRequested = true;
        if (exited) {
          return Future.value();
        }
        return stopping ??= stopFlutterRun(
          process,
          logger: _logger,
          timeout: _flutterRunStopTimeout,
        );
      }

      scope.addDispose(stop);

      // `process.stdout` takes a single listener, so fan it out to the
      // detail log and the log reader.
      final output = StreamController<String>.broadcast();
      scope.addDispose(output.close);
      output.stream.listen((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdOut(output.add).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      PatrolLogReader(
          listenStdOut: output.stream.listen,
          scope: scope,
          log: _logger.info,
          reportPath: '',
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          clearTestSteps: clearTestSteps,
          onLogEntry: onLogEntry,
        )
        ..listen()
        ..startTimer();

      StdinModes? previousStdinModes;
      if (io.stdin.hasTerminal) {
        previousStdinModes = flutterTool.enableInteractiveMode();
      }
      void revertInteractiveMode() {
        if (previousStdinModes case final modes?) {
          previousStdinModes = null;
          flutterTool.revertInteractiveMode(modes);
        }
      }

      final keysSubscription = forwardDevelopKeys(
        flutterProcess: process,
        stdin: stdin,
        logger: _logger,
        revertInteractiveMode: revertInteractiveMode,
        // Stopping `flutter run` ends this method, so the develop session
        // cleans up and returns instead of exiting the CLI here.
        onQuit: stop,
      );

      try {
        final exitCode = await process.exitCode;
        if (exitCode != 0 && !quitRequested) {
          throwToolExit(
            '`${options.flutter.command} run` exited with code $exitCode',
          );
        }
      } finally {
        await keysSubscription.cancel();
        revertInteractiveMode();
      }
    });
  }

  /// Runs every non-skipped test of the built app in its own app process.
  ///
  /// The sequence is:
  ///
  /// 1. Launch the app once and ask it for its tests (`listDartTests`).
  /// 2. For each test, in declaration order: launch the app, wait until its
  ///    server answers, request the test (`runDartTest`) and stop the app.
  ///
  /// A test fails if the app reports a failure, does not become ready, or
  /// exits before it answers. The run continues with the next test. Throws a
  /// [ToolExit] at the end if any test failed.
  ///
  /// [build] must be called before this method.
  Future<void> execute(
    LinuxAppOptions options,
    Device device, {
    bool showFlutterLogs = false,
    bool hideTestSteps = false,
    bool clearTestSteps = false,
    void Function(Entry entry)? onLogEntry,
  }) async {
    _warnIfNoDisplay();
    await _disposeScope.run((scope) async {
      final subject = '${options.description} on ${device.description}';
      final binaryPath = await resolveBinaryPath(options);
      _logger.detail('Using app binary $binaryPath');

      final appServerPort = await _resolveAppServerPort(options.appServerPort);
      if (appServerPort != options.appServerPort) {
        _logger.info(
          'App server port ${options.appServerPort} is in use, '
          'using port $appServerPort instead',
        );
      }

      final environment = {
        ..._platform.environment,
        'PATROL_APP_SERVER_PORT': appServerPort.toString(),
      };

      // The output of every app process goes to one stream, so a single
      // reader counts the tests of the whole run.
      final appOutput = StreamController<String>.broadcast();
      scope.addDispose(appOutput.close);
      appOutput.stream
          .listen((line) {
            // PatrolLogReader prints lines that contain `flutter:` itself when
            // showFlutterLogs is set. A Linux app prints without that prefix,
            // so print the remaining lines here.
            if (showFlutterLogs &&
                !line.contains('PATROL_LOG') &&
                !line.contains('flutter:')) {
              _logger.info(line);
            } else {
              _logger.detail('\t$line');
            }
          })
          .disposedBy(scope);

      // Names of the tests that the app reported as started and as finished.
      final startedByApp = <String>{};
      final finishedByApp = <String>{};
      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: appOutput.stream.listen,
              scope: scope,
              log: _logger.info,
              reportPath: '',
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps,
              clearTestSteps: clearTestSteps,
              onLogEntry: (entry) {
                if (entry is TestEntry) {
                  if (entry.status == TestEntryStatus.start) {
                    startedByApp.add(entry.name);
                  } else if (entry.isFinished) {
                    finishedByApp.add(entry.name);
                  }
                }
                onLogEntry?.call(entry);
              },
            )
            ..listen()
            ..startTimer();

      // Gives the log reader the failure of a test that the app could not
      // report (for example, because it crashed), so that the summary counts
      // it. A result that the app reported is already counted.
      Future<void> reportFailureToLogReader(String name, String reason) async {
        // Let the log reader process the remaining output of the app.
        await Future<void>.delayed(Duration.zero);
        if (startedByApp.contains(name) && finishedByApp.contains(name)) {
          return;
        }
        if (!startedByApp.contains(name)) {
          patrolLogReader.parse(
            _patrolLogLine(
              TestEntry(name: name, status: TestEntryStatus.start),
            ),
          );
        }
        patrolLogReader.parse(
          _patrolLogLine(
            TestEntry(
              name: name,
              status: TestEntryStatus.failure,
              error: reason,
            ),
          ),
        );
      }

      // A client that this run creates is closed with it, so pooled
      // connections to app processes that are gone don't outlive the run.
      final httpClient = _httpClient ?? http.Client();
      if (_httpClient == null) {
        scope.addDispose(httpClient.close);
      }
      final client = PatrolAppServiceClient(
        httpClient: httpClient,
        port: appServerPort,
      );

      Future<_AppProcess> launch() => _launch(
        binaryPath,
        environment: environment,
        onLine: appOutput.add,
        scope: scope,
      );

      // 1. Discovery.

      _throwIfInterrupted('test discovery');
      final discoveryTask = _logger.task('Discovering tests of $subject');
      late final TestManifest manifest;
      _AppNotReady? notReady;
      final discoveryApp = await launch();
      try {
        manifest = await _waitUntilReady(client, discoveryApp);
      } on _AppNotReady catch (err) {
        notReady = err;
      } finally {
        await _terminate(discoveryApp);
      }
      if (notReady != null) {
        discoveryTask.fail('Failed to discover tests of $subject');
        _throwIfInterrupted('test discovery');
        _printRecentOutput(discoveryApp);
        throwToolExit(
          'Could not list the tests of the app: ${notReady.reason}',
        );
      }

      final toRun = manifest.tests.where((test) => !test.skip).toList();
      discoveryTask.complete(
        'Discovered ${manifest.tests.length} test(s), '
        '${manifest.tests.length - toRun.length} skipped',
      );

      // 2. One app process per test.

      final failures = <String, String>{};
      for (final test in manifest.tests) {
        if (test.skip) {
          _logger.detail('Skipping test "${test.dartName}"');
          continue;
        }

        _throwIfInterrupted('test "${test.dartName}"');
        final failure = await _runTest(client, test.dartName, launch);
        // On Ctrl+C the dispose scope kills the app, so the test looks like
        // a crash. Report it as an interruption instead.
        _throwIfInterrupted('test "${test.dartName}"');
        if (failure != null) {
          failures[test.dartName] = failure;
          await reportFailureToLogReader(test.dartName, failure);
        }
      }

      // Let the log reader process the last entries before the summary.
      await Future<void>.delayed(Duration.zero);
      patrolLogReader.stopTimer();
      // There is no report file on Linux, so drop the empty "Report:" line.
      _logger.info(
        patrolLogReader.summary
            .split('\n')
            .where((line) => !line.endsWith('Report: '))
            .join('\n'),
      );

      if (failures.isNotEmpty || patrolLogReader.failedTestsCount > 0) {
        if (failures.isNotEmpty) {
          _logger.err('Failed tests:');
          for (final MapEntry(key: name, value: reason) in failures.entries) {
            _logger.err('  - $name ($reason)');
          }
        }
        throwToolExit('Some tests failed.');
      }
    });
  }

  /// Stops the run if it was interrupted (for example, with Ctrl+C), which
  /// disposes [_disposeScope] and kills the app.
  void _throwIfInterrupted(String what) {
    if (_disposeScope.disposed) {
      throwToolInterrupted('$what was interrupted');
    }
  }

  /// Runs a single test in a new app process. Returns the reason of the
  /// failure, or `null` if the test passed.
  Future<String?> _runTest(
    PatrolAppServiceClient client,
    String name,
    Future<_AppProcess> Function() launch,
  ) async {
    final app = await launch();
    final String? failure;
    try {
      failure = await _runTestIn(client, name, app);
    } finally {
      await _terminate(app);
    }
    // A failed Dart test is reported by the app itself. Any other failure
    // (a crash, no answer, a lost connection) is explained only by what the
    // app printed, which is otherwise visible only with --verbose.
    if (failure != null && failure != _testFailed && !_disposeScope.disposed) {
      _printRecentOutput(app);
    }
    return failure;
  }

  static const _testFailed = 'failed';

  Future<String?> _runTestIn(
    PatrolAppServiceClient client,
    String name,
    _AppProcess app,
  ) async {
    try {
      await _waitUntilReady(client, app);
    } on _AppNotReady catch (err) {
      return err.reason;
    }

    final outcome = await Future.any<Object>([
      client
          .runDartTest(name)
          .then<Object>((result) => result, onError: (Object err) => err),
      app.exitCode,
    ]);

    switch (outcome) {
      case RunDartTestResult(failed: true, :final details):
        _logger.detail('Test "$name" failed: $details');
        return _testFailed;
      case RunDartTestResult():
        return null;
      case final int exitCode:
        return 'app crashed (exit $exitCode)';
      default:
        // The connection broke, most likely because the app is going down.
        // Give it a moment to exit, so the exit code can be reported.
        _logger.detail('runDartTest for "$name" failed: $outcome');
        final exitCode = await app.exitCode
            .then<int?>((code) => code)
            .timeout(_killTimeout, onTimeout: () => null);
        return exitCode != null
            ? 'app crashed (exit $exitCode)'
            : 'lost connection to the app: $outcome';
    }
  }

  void _printRecentOutput(_AppProcess app) {
    final lines = app.recentOutput;
    if (lines.isEmpty) {
      _logger.err('The app printed nothing before it stopped.');
      return;
    }
    _logger.err('Last ${lines.length} line(s) of the app output:');
    for (final line in lines) {
      _logger.err('  $line');
    }
  }

  /// Fails before the build when [options] has a flavor that the Flutter SDK
  /// can't build for Linux. Older SDKs reject `--flavor` with a usage error
  /// that doesn't say why.
  void _assertFlavorSupported(LinuxAppOptions options) {
    if (options.flutter.flavor == null) {
      return;
    }
    final String version;
    try {
      version = _flutterVersionOf(options.flutter.command);
    } on Object catch (err) {
      _logger.detail('Could not read the Flutter version: $err');
      return;
    }
    if (!flutterVersionAtLeast(version, minFlavorFlutterVersion)) {
      throwToolExit(
        '--flavor on Linux requires Flutter $minFlavorFlutterVersion or newer, '
        'but found $version.\n'
        'Upgrade Flutter, or point patrol at a newer SDK with '
        '--flutter-command, e.g. --flutter-command "fvm flutter".',
      );
    }
  }

  /// GTK can't open a window without a display, so the app exits at once.
  /// Says so before the run, because then every test fails as a crash.
  void _warnIfNoDisplay() {
    bool isSet(String name) => _platform.environment[name]?.isNotEmpty ?? false;
    if (isSet('DISPLAY') || isSet('WAYLAND_DISPLAY')) {
      return;
    }
    _logger.warn(
      'Neither DISPLAY nor WAYLAND_DISPLAY is set, so the app has no display '
      'to open its window on and will most likely exit at once. On a machine '
      'without a display, such as CI, run Patrol under a virtual display, for '
      'example: xvfb-run -a patrol test -d linux',
    );
  }

  /// Polls `listDartTests` until the app answers, the app exits, or
  /// [_readyTimeout] passes.
  Future<TestManifest> _waitUntilReady(
    PatrolAppServiceClient client,
    _AppProcess app,
  ) async {
    final stopwatch = Stopwatch()..start();
    Object? lastError;
    while (true) {
      if (app.exited case final exitCode?) {
        throw _AppNotReady('app crashed (exit $exitCode)');
      }

      // Each request gets only the time that remains until the deadline.
      final remaining = _readyTimeout - stopwatch.elapsed;
      if (remaining <= Duration.zero) {
        throw _AppNotReady(
          'the app did not respond within ${_readyTimeout.inSeconds}s '
          '(last error: $lastError)',
        );
      }

      try {
        return await client.listDartTests(timeout: remaining);
      } on PatrolAppServiceException catch (err) {
        // The server is up but answered with an error. Retrying won't help.
        throw _AppNotReady(
          'listDartTests returned ${err.statusCode}: ${err.body}',
        );
      } on FormatException catch (err) {
        // The server is up but the answer is not a test list. Retrying won't
        // help.
        throw _AppNotReady(
          'listDartTests returned an invalid response: ${err.message}',
        );
      } on Exception catch (err) {
        // Most likely the server is not up yet.
        lastError = err;
      }

      final untilDeadline = _readyTimeout - stopwatch.elapsed;
      await Future.any<void>([
        Future<void>.delayed(
          untilDeadline < _pollInterval ? untilDeadline : _pollInterval,
        ),
        app.exitCode,
      ]);
    }
  }

  Future<_AppProcess> _launch(
    String binaryPath, {
    required Map<String, String> environment,
    required void Function(String) onLine,
    required DisposeScope scope,
  }) async {
    final process = await _processManager.start([
      binaryPath,
    ], environment: environment);
    if (scope.disposed) {
      // Interrupted while the app was starting. The scope can't kill it
      // anymore.
      process.kill(io.ProcessSignal.sigkill);
      throwToolInterrupted('launching the app was interrupted');
    }
    final app = _AppProcess(process);
    scope.addDispose(() => process.kill(io.ProcessSignal.sigkill));

    // Flutter's desktop log reader also listens to both streams.
    final stdoutDone = Completer<void>();
    final stderrDone = Completer<void>();
    void record(String line) {
      app.addOutput(line);
      onLine(line);
    }

    process.listenStdOut(record, onDone: stdoutDone.complete).disposedBy(scope);
    process.listenStdErr(record, onDone: stderrDone.complete).disposedBy(scope);
    app.outputDone = Future.wait([stdoutDone.future, stderrDone.future]);

    return app;
  }

  /// Stops [app] with SIGTERM, and with SIGKILL if it doesn't exit within
  /// [_killTimeout].
  Future<void> _terminate(_AppProcess app) async {
    if (app.exited == null) {
      app.process.kill();
      try {
        await app.exitCode.timeout(_killTimeout);
      } on TimeoutException {
        _logger.detail(
          'App did not exit within ${_killTimeout.inSeconds}s, killing it',
        );
        app.process.kill(io.ProcessSignal.sigkill);
        await app.exitCode;
      }
    }

    // Let the remaining output reach the log reader before the next test.
    await app.outputDone.timeout(_killTimeout, onTimeout: () => []);
  }

  /// Returns the absolute path of the app binary built for [options].
  ///
  /// The binary name is `BINARY_NAME` from `linux/CMakeLists.txt`. Flutter puts
  /// it in `build/linux/<arch>/[<flavor>/]<mode>/bundle/`.
  Future<String> resolveBinaryPath(LinuxAppOptions options) async {
    final cmakeFile = _rootDirectory
        .childDirectory('linux')
        .childFile('CMakeLists.txt');
    if (!cmakeFile.existsSync()) {
      throwToolExit(
        '${cmakeFile.path} not found. Add Linux support to the app with '
        '`flutter create --platforms=linux .`',
      );
    }

    final binaryName = RegExp(
      r'set\s*\(\s*BINARY_NAME\s+"([^"]+)"\s*\)',
    ).firstMatch(cmakeFile.readAsStringSync())?.group(1);
    if (binaryName == null) {
      throwToolExit('Could not find BINARY_NAME in ${cmakeFile.path}');
    }

    final flavor = options.flutter.flavor;
    final pathInArchDir = [
      ?flavor,
      options.flutter.buildMode.name,
      'bundle',
      binaryName,
    ].join('/');
    final pattern = 'build/linux/<arch>/$pathInArchDir';

    // One directory per architecture (x64, arm64). Listed by hand, because a
    // glob fails as soon as one architecture lacks the flavor or mode directory.
    final linuxBuildDir = _rootDirectory
        .childDirectory('build')
        .childDirectory('linux');
    final binaries = [
      if (linuxBuildDir.existsSync())
        for (final archDir in linuxBuildDir.listSync().whereType<Directory>())
          archDir.childFile(pathInArchDir),
    ].where((file) => file.existsSync()).toList();

    final root = _rootDirectory.absolute.path;
    if (binaries.isEmpty) {
      throwToolExit(
        'No app binary $pattern was found at $root. Build the app with '
        '`patrol build linux` first.',
      );
    } else if (binaries.length > 1) {
      throwToolExit(
        'Found ${binaries.length} app binaries matching $pattern at $root, '
        'expected exactly one:\n'
        '${binaries.map((f) => '  ${f.path}').join('\n')}\n'
        'Remove the stale build directories, for example with '
        '`flutter clean`.',
      );
    }

    return binaries.single.absolute.path;
  }
}

/// Returns [preferredPort] if nothing listens on it, otherwise a free port.
///
/// The app binds its server with `HttpMultiServer.loopback`, so a port is
/// free only if it is free on both `127.0.0.1` and `::1`.
Future<int> _freeAppServerPort(int preferredPort) async {
  if (await _isFreeOnLoopback(preferredPort)) {
    return preferredPort;
  }
  return bindUnusedPort<int>(
    (port) async => await _isFreeOnLoopback(port) ? port : null,
  );
}

Future<bool> _isFreeOnLoopback(int port) async {
  if (!await _canBind(io.InternetAddress.loopbackIPv4, port)) {
    return false;
  }
  if (await _canBind(io.InternetAddress.loopbackIPv6, port)) {
    return true;
  }
  // The port is in use on ::1, unless IPv6 is not available at all.
  return !await _canBind(io.InternetAddress.loopbackIPv6, 0);
}

Future<bool> _canBind(io.InternetAddress address, int port) async {
  try {
    final socket = await io.ServerSocket.bind(
      address,
      port,
      v6Only: address.type == io.InternetAddressType.IPv6,
    );
    await socket.close();
    return true;
  } on io.SocketException {
    return false;
  }
}

String _patrolLogLine(Entry entry) =>
    'PATROL_LOG ${jsonEncode(entry.toJson())}';

class _AppProcess {
  _AppProcess(this.process) {
    exitCode = process.exitCode.then((code) => exited = code);
  }

  /// How many of the last output lines [recentOutput] keeps.
  static const recentOutputLines = 20;

  final io.Process process;
  late final Future<int> exitCode;
  late Future<void> outputDone;

  /// The exit code, once the process exited.
  int? exited;

  final _recentOutput = Queue<String>();

  /// The last [recentOutputLines] lines that the app printed to stdout and
  /// stderr.
  List<String> get recentOutput => List.unmodifiable(_recentOutput);

  void addOutput(String line) {
    // Empty lines explain nothing and would take the place of lines that do.
    if (line.trim().isEmpty) {
      return;
    }
    _recentOutput.addLast(line);
    if (_recentOutput.length > recentOutputLines) {
      _recentOutput.removeFirst();
    }
  }
}

class _AppNotReady implements Exception {
  const _AppNotReady(this.reason);

  final String reason;
}
