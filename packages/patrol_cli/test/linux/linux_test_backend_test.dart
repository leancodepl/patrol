import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/memory.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mason_logger/mason_logger.dart' as mason;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart' show StdinModes;
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/linux/linux_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

import '../src/fakes.dart';
import '../src/mocks.dart';

const _binaryPath = '/project/build/linux/x64/debug/bundle/example_app';

const _linuxDevice = Device(
  name: 'Linux',
  id: 'linux',
  targetPlatform: TargetPlatform.linux,
  real: true,
);

/// `listDartTests` response: two tests and one skipped test, nested the way
/// the test bundler nests them (one top-level group per test file).
final _manifestJson = jsonEncode({
  'group': {
    'name': '',
    'type': 'group',
    'skip': false,
    'tags': <String>[],
    'entries': [
      {
        'name': 'example_test',
        'type': 'group',
        'skip': false,
        'tags': <String>[],
        'entries': [
          for (final (name, skip) in [
            ('taps', false),
            ('is skipped', true),
            ('scrolls', false),
          ])
            {
              'name': name,
              'type': 'test',
              'skip': skip,
              'tags': <String>[],
              'entries': <Object>[],
            },
        ],
      },
    ],
  },
});

String _patrolLog(Entry entry) => 'PATROL_LOG ${jsonEncode(entry.toJson())}';

LinuxAppOptions _options({int appServerPort = 8082, String? flavor}) =>
    LinuxAppOptions(
      flutter: FlutterAppOptions(
        command: const FlutterCommand('flutter'),
        target: 'patrol_test/test_bundle.dart',
        flavor: flavor,
        buildMode: BuildMode.debug,
        dartDefines: const {},
        dartDefineFromFilePaths: const [],
        buildName: null,
        buildNumber: null,
      ),
      appServerPort: appServerPort,
      testServerPort: 8081,
    );

class _RecordingLogger extends Logger {
  _RecordingLogger() : super(level: mason.Level.verbose);

  final lines = <String>[];
  final errors = <String>[];

  @override
  void info(String? message, {mason.LogStyle? style}) => lines.add('$message');

  @override
  void detail(String? message, {mason.LogStyle? style}) {}

  @override
  void err(String? message, {mason.LogStyle? style}) => errors.add('$message');

  @override
  void success(String? message, {mason.LogStyle? style}) =>
      lines.add('$message');

  @override
  mason.Progress task(String message) => _SilentProgress();
}

class _SilentProgress implements mason.Progress {
  @override
  void complete([String? update]) {}

  @override
  void fail([String? update]) {}

  @override
  void cancel() {}

  @override
  void update(String update) {}
}

void main() {
  setUpAll(() => registerFallbackValue(<Object>[]));

  late MemoryFileSystem fs;
  late MockProcessManager processManager;
  late _RecordingLogger logger;
  late DisposeScope disposeScope;

  /// App processes in launch order, and the environment each one got.
  late List<FakeProcess> launched;
  late List<Map<String, String>?> environments;

  /// Creates the process for the next launch. Defaults to a well-behaved app.
  late FakeProcess Function() nextProcess;

  /// Names passed to `runDartTest`, in order.
  late List<String> requestedTests;

  /// Runs after the app process with this index started, before `start`
  /// returns it.
  late Future<void> Function(int index)? onStarted;

  setUp(() {
    fs = MemoryFileSystem.test();
    fs.file('/project/linux/CMakeLists.txt')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)
set(BINARY_NAME "example_app")
set(APPLICATION_ID "pl.leancode.example_app")
''');
    fs.file(_binaryPath).createSync(recursive: true);

    processManager = MockProcessManager();
    logger = _RecordingLogger();
    disposeScope = DisposeScope();
    launched = [];
    environments = [];
    requestedTests = [];
    nextProcess = FakeProcess.new;
    onStarted = null;

    when(
      () => processManager.start([
        _binaryPath,
      ], environment: any(named: 'environment')),
    ).thenAnswer((invocation) async {
      final process = nextProcess();
      launched.add(process);
      environments.add(
        invocation.namedArguments[#environment] as Map<String, String>?,
      );
      await onStarted?.call(launched.length - 1);
      return process;
    });
  });

  tearDown(() async {
    if (!disposeScope.disposed) {
      await disposeScope.dispose();
    }
  });

  /// With [resolvePorts], the real free port lookup runs. Otherwise the
  /// requested app server port is used as is.
  LinuxTestBackend createBackend(
    http.Client client, {
    bool resolvePorts = false,
    Duration readyTimeout = const Duration(milliseconds: 300),
  }) {
    return LinuxTestBackend(
      processManager: processManager,
      platform: FakePlatform(
        environment: {'DISPLAY': ':99', 'HOME': '/home/runner'},
      ),
      rootDirectory: fs.directory('/project'),
      parentDisposeScope: disposeScope,
      logger: logger,
      httpClient: client,
      resolveAppServerPort: resolvePorts
          ? null
          : (preferredPort) async => preferredPort,
      pollInterval: const Duration(milliseconds: 5),
      readyTimeout: readyTimeout,
      killTimeout: const Duration(milliseconds: 200),
    );
  }

  /// An app server that is ready at once. [onRun] decides the answer to
  /// `runDartTest`; by default the test passes and the app logs it.
  MockClientHandler appHandler({
    Future<http.Response> Function(String name, FakeProcess app)? onRun,
  }) {
    return (request) async {
      switch (request.url.path) {
        case '/listDartTests':
          return http.Response(_manifestJson, 200);
        case '/runDartTest':
          final name =
              (jsonDecode(request.body) as Map<String, dynamic>)['name']
                  as String;
          requestedTests.add(name);
          final app = launched.last;
          if (onRun != null) {
            return onRun(name, app);
          }
          app
            ..writeStdout(
              _patrolLog(TestEntry(name: name, status: TestEntryStatus.start)),
            )
            ..writeStderr('some engine warning on stderr')
            ..writeStdout(
              _patrolLog(
                TestEntry(name: name, status: TestEntryStatus.success),
              ),
            );
          return http.Response(jsonEncode({'result': 'success'}), 200);
      }
      return http.Response('not found', 404);
    };
  }

  MockClient appServer({
    Future<http.Response> Function(String name, FakeProcess app)? onRun,
  }) => MockClient(appHandler(onRun: onRun));

  test('runs every non-skipped test in its own app process with the '
      'inherited environment and the ports', () async {
    final backend = createBackend(appServer());

    await backend.execute(_options(appServerPort: 9000), _linuxDevice);

    // Launch #0 lists the tests, then one launch per non-skipped test.
    expect(launched, hasLength(3));
    expect(requestedTests, ['example_test taps', 'example_test scrolls']);
    for (final app in launched) {
      expect(app.signals, [io.ProcessSignal.sigterm]);
    }
    for (final environment in environments) {
      expect(environment, {
        'DISPLAY': ':99',
        'HOME': '/home/runner',
        'PATROL_TEST_SERVER_PORT': '8081',
        'PATROL_APP_SERVER_PORT': '9000',
      });
    }

    final summary = logger.lines.singleWhere(
      (line) => line.contains('Test summary'),
    );
    expect(summary, contains('Total: 2'));
    expect(summary, contains('Successful: 2'));
    expect(summary, contains('Failed: 0'));
    expect(summary, isNot(contains('Report:')));
    expect(logger.errors, isEmpty);
  });

  test('uses a free app server port when the requested one is busy', () async {
    final busySocket = await io.ServerSocket.bind(
      io.InternetAddress.loopbackIPv4,
      0,
    );
    addTearDown(busySocket.close);
    final requestedPorts = <int>{};
    final handler = appHandler();
    final client = MockClient((request) {
      requestedPorts.add(request.url.port);
      return handler(request);
    });

    final backend = createBackend(client, resolvePorts: true);

    await backend.execute(
      _options(appServerPort: busySocket.port),
      _linuxDevice,
    );

    final usedPort = int.parse(environments.first!['PATROL_APP_SERVER_PORT']!);
    expect(usedPort, isNot(busySocket.port));
    expect(requestedPorts, {usedPort});
    expect(
      logger.lines,
      contains(
        'App server port ${busySocket.port} is in use, '
        'using port $usedPort instead',
      ),
    );
  });

  test('does not use a port that is busy on ::1 only', () async {
    final io.ServerSocket busySocket;
    try {
      busySocket = await io.ServerSocket.bind(
        io.InternetAddress.loopbackIPv6,
        0,
        v6Only: true,
      );
    } on io.SocketException {
      markTestSkipped('IPv6 is not available');
      return;
    }
    addTearDown(busySocket.close);

    final backend = createBackend(appServer(), resolvePorts: true);

    await backend.execute(
      _options(appServerPort: busySocket.port),
      _linuxDevice,
    );

    final usedPort = int.parse(environments.first!['PATROL_APP_SERVER_PORT']!);
    expect(usedPort, isNot(busySocket.port));
  });

  test('fails at once when the app answers listDartTests with invalid '
      'JSON', () async {
    final backend = createBackend(
      MockClient((request) async => http.Response('<html>proxy</html>', 200)),
      readyTimeout: const Duration(seconds: 30),
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(
        isA<ToolExit>().having(
          (e) => e.message,
          'message',
          contains('listDartTests returned an invalid response'),
        ),
      ),
    );
    expect(launched, hasLength(1));
  }, timeout: const Timeout(Duration(seconds: 5)));

  test('stops waiting for the app at the ready deadline when a request '
      'hangs', () async {
    const readyTimeout = Duration(seconds: 1);
    final stopwatch = Stopwatch()..start();
    final backend = createBackend(
      MockClient((request) {
        // The server is not up at first, then it accepts the connection but
        // never answers.
        if (stopwatch.elapsed < const Duration(milliseconds: 700)) {
          return Future.error(
            http.ClientException('Connection refused', request.url),
          );
        }
        return Completer<http.Response>().future;
      }),
      readyTimeout: readyTimeout,
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(
        isA<ToolExit>().having(
          (e) => e.message,
          'message',
          contains('did not respond within 1s'),
        ),
      ),
    );
    // A request that starts at 700 ms must not get a full second of its own.
    expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 1400)));
  });

  test('fails at once when the app server answers with an error', () async {
    final backend = createBackend(
      MockClient((request) async => http.Response('boom', 500)),
      readyTimeout: const Duration(seconds: 30),
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(
        isA<ToolExit>().having(
          (e) => e.message,
          'message',
          allOf(contains('listDartTests returned 500'), contains('boom')),
        ),
      ),
    );
    expect(launched, hasLength(1));
  }, timeout: const Timeout(Duration(seconds: 5)));

  test('stops and reports an interruption when Ctrl+C comes during a '
      'test', () async {
    final backend = createBackend(
      appServer(
        onRun: (name, app) {
          // Ctrl+C: the CLI disposes its scope, which kills the app.
          unawaited(disposeScope.dispose());
          return Completer<http.Response>().future;
        },
      ),
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(
        isA<ToolInterrupted>().having(
          (e) => e.details,
          'details',
          'test "example_test taps" was interrupted',
        ),
      ),
    );
    expect(requestedTests, ['example_test taps']);
    expect(launched, hasLength(2));
    expect(launched[1].signals, contains(io.ProcessSignal.sigkill));
    expect(logger.errors.join('\n'), isNot(contains('crashed')));
  });

  test('kills an app that started after Ctrl+C', () async {
    onStarted = (index) async {
      if (index == 1) {
        await disposeScope.dispose();
      }
    };
    final backend = createBackend(appServer());

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(isA<ToolInterrupted>()),
    );
    expect(launched, hasLength(2));
    expect(launched[1].signals, [io.ProcessSignal.sigkill]);
    expect(requestedTests, isEmpty);
  });

  test('fails when the app never answers during discovery', () async {
    final backend = createBackend(
      MockClient(
        (request) => Future.error(
          http.ClientException('Connection refused', request.url),
        ),
      ),
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(
        isA<ToolExit>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('Could not list the tests of the app'),
            contains('did not respond'),
          ),
        ),
      ),
    );
    expect(launched, hasLength(1));
    expect(launched.single.signals, [io.ProcessSignal.sigterm]);
  });

  test('counts an app that exits during a test as a crash and continues with '
      'the next test', () async {
    final backend = createBackend(
      appServer(
        onRun: (name, app) {
          app.writeStdout(
            _patrolLog(TestEntry(name: name, status: TestEntryStatus.start)),
          );
          if (name == 'example_test taps') {
            // The app crashes: no response ever comes.
            app.exit(139);
            return Completer<http.Response>().future;
          }
          app.writeStdout(
            _patrolLog(TestEntry(name: name, status: TestEntryStatus.success)),
          );
          return Future.value(
            http.Response(jsonEncode({'result': 'success'}), 200),
          );
        },
      ),
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(
        isA<ToolExit>().having(
          (e) => e.message,
          'message',
          'Some tests failed.',
        ),
      ),
    );

    expect(requestedTests, ['example_test taps', 'example_test scrolls']);
    expect(launched, hasLength(3));
    // The crashed app is not killed again.
    expect(launched[1].signals, isEmpty);
    expect(
      logger.errors,
      contains('  - example_test taps (app crashed (exit 139))'),
    );
    expect(logger.errors.join('\n'), isNot(contains('scrolls')));
    // The app could not report the crash, so the summary counts it.
    final summary = logger.lines.singleWhere(
      (line) => line.contains('Test summary'),
    );
    expect(summary, contains('Total: 2'));
    expect(summary, contains('Successful: 1'));
    expect(summary, contains('Failed: 1\n  - taps '));
  });

  test('counts a test whose app does not become ready as failed in the '
      'summary', () async {
    final handler = appHandler();
    final backend = createBackend(
      MockClient((request) async {
        // Launch #1 runs "example_test taps": its server answers with an
        // error.
        if (launched.length == 2 && request.url.path == '/listDartTests') {
          return http.Response('boom', 500);
        }
        return handler(request);
      }),
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(isA<ToolExit>()),
    );

    expect(requestedTests, ['example_test scrolls']);
    final summary = logger.lines.singleWhere(
      (line) => line.contains('Test summary'),
    );
    expect(summary, contains('Total: 2'));
    expect(summary, contains('Successful: 1'));
    expect(summary, contains('Failed: 1\n  - taps '));
  });

  test('fails the test when the app reports a failure', () async {
    final backend = createBackend(
      appServer(
        onRun: (name, app) async {
          final failed = name.endsWith('scrolls');
          app
            ..writeStdout(
              _patrolLog(TestEntry(name: name, status: TestEntryStatus.start)),
            )
            ..writeStdout(
              _patrolLog(
                TestEntry(
                  name: name,
                  status: failed
                      ? TestEntryStatus.failure
                      : TestEntryStatus.success,
                ),
              ),
            );
          return http.Response(
            jsonEncode({
              'result': failed ? 'failure' : 'success',
              'details': 'Expected: true',
            }),
            200,
          );
        },
      ),
    );

    await expectLater(
      backend.execute(_options(), _linuxDevice),
      throwsA(isA<ToolExit>()),
    );
    expect(logger.errors, [
      'Failed tests:',
      '  - example_test scrolls (failed)',
    ]);
    // The app reported the failure itself, so it is counted once.
    final summary = logger.lines.singleWhere(
      (line) => line.contains('Test summary'),
    );
    expect(summary, contains('Total: 2'));
    expect(summary, contains('Failed: 1\n'));
  });

  test('kills an app with SIGKILL when it ignores SIGTERM', () async {
    nextProcess = () => FakeProcess(exitOnSigterm: false);
    final backend = createBackend(appServer());

    await backend.execute(_options(), _linuxDevice);

    for (final app in launched) {
      expect(app.signals, [io.ProcessSignal.sigterm, io.ProcessSignal.sigkill]);
    }
  });

  group('develop', () {
    // `develop` switches the terminal to interactive mode when the test
    // process's stdin is a terminal (or /dev/null).
    MockFlutterTool flutterTool() {
      final tool = MockFlutterTool();
      when(
        tool.enableInteractiveMode,
      ).thenReturn(StdinModes(echoMode: true, lineMode: true));
      return tool;
    }

    test('runs flutter run, reports test entries and forwards the hot restart '
        'and quit keys', () async {
      final flutterRun = FakeProcess(exitOnSigterm: false);
      List<Object>? command;
      when(() => processManager.start(any())).thenAnswer((invocation) async {
        command = invocation.positionalArguments.first as List<Object>;
        return flutterRun;
      });
      final stdin = StreamController<List<int>>();
      final entries = <Entry>[];

      final develop = createBackend(appServer()).develop(
        flutterTool(),
        _options(),
        _linuxDevice,
        stdin: stdin.stream,
        onLogEntry: entries.add,
      );

      await pumpEventQueue();
      flutterRun.writeStdout(
        'flutter: ${_patrolLog(TestEntry(name: 'example_test taps', status: TestEntryStatus.start))}',
      );
      stdin.add('r'.codeUnits);
      await pumpEventQueue();
      expect(flutterRun.stdinText, 'R');

      stdin.add('q'.codeUnits);
      await pumpEventQueue();
      // flutter run stops the app on SIGTERM; here it exits like it was
      // killed.
      expect(flutterRun.signals, [io.ProcessSignal.sigterm]);
      flutterRun.exit(-15);

      // Quitting is not an error.
      await develop;
      expect(command, [
        'flutter',
        'run',
        '--no-version-check',
        '--suppress-analytics',
        ...['-d', 'linux'],
        '--debug',
        ...['--target', 'patrol_test/test_bundle.dart'],
      ]);
      expect(entries.whereType<TestEntry>().map((e) => (e.name, e.status)), [
        ('example_test taps', TestEntryStatus.start),
      ]);
      await stdin.close();
    });

    test('fails when flutter run exits on its own with an error', () async {
      final flutterRun = FakeProcess();
      when(() => processManager.start(any())).thenAnswer((_) async {
        Timer(const Duration(milliseconds: 10), () => flutterRun.exit(1));
        return flutterRun;
      });

      await expectLater(
        createBackend(appServer()).develop(
          flutterTool(),
          _options(),
          _linuxDevice,
          stdin: const Stream.empty(),
        ),
        throwsA(isA<ToolExit>()),
      );
    });
  });

  group('resolveBinaryPath', () {
    test('finds the flavored bundle', () async {
      fs
          .file('/project/build/linux/arm64/staging/debug/bundle/example_app')
          .createSync(recursive: true);

      final path = await createBackend(
        appServer(),
      ).resolveBinaryPath(_options(flavor: 'staging'));

      expect(
        path,
        '/project/build/linux/arm64/staging/debug/bundle/example_app',
      );
    });

    test('fails when bundles for two architectures exist', () async {
      fs
          .file('/project/build/linux/arm64/debug/bundle/example_app')
          .createSync(recursive: true);

      await expectLater(
        createBackend(appServer()).resolveBinaryPath(_options()),
        throwsA(
          isA<ToolExit>().having(
            (e) => e.message,
            'message',
            contains('Found 2 app binaries'),
          ),
        ),
      );
    });
  });
}
