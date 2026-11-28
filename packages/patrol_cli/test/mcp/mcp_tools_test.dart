import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart' hide Logger;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/cli_origin.dart';
import 'package:patrol_cli/src/mcp/mcp_analytics.dart';
import 'package:patrol_cli/src/mcp/mcp_tools.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:patrol_cli/src/mcp/suite_run.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';
import '../src/processes.dart';
import 'fake_develop.dart';

void main() {
  late Directory projectRoot;
  late MockDeviceFinder deviceFinder;

  const device = Device(
    name: 'test device',
    id: 'test-device',
    targetPlatform: TargetPlatform.android,
    real: false,
  );

  setUpAll(() {
    registerFallbackValue(
      DevelopOptions.parseArgs(const [], target: 'a_test.dart').$1,
    );
    registerFallbackValue(const FlutterCommand('flutter'));
  });

  setUp(() {
    projectRoot = Directory.systemTemp.createTempSync('patrol_mcp_tools');
    File('${projectRoot.path}/pubspec.yaml').writeAsStringSync('name: app\n');
    deviceFinder = MockDeviceFinder();
    when(
      () => deviceFinder.getAttachedDevices(
        flutterCommand: any(named: 'flutterCommand'),
      ),
    ).thenAnswer((_) async => const [device]);
  });

  tearDown(() => projectRoot.deleteSync(recursive: true));

  /// A server that has been told where to work, or one that has not: the
  /// latter resolves nothing, as a server started outside any package does.
  McpTools toolsWith(
    FakeDevelop fake, {
    bool projectResolvable = true,
    AttachedDevicesReader? listAttachedDevices,
    McpAnalytics? analytics,
    List<String> developArgs = const [],
    List<String> suiteCommand = const ['false'],
  }) {
    final session = PatrolSession(
      developArgs: developArgs,
      suiteCommand: suiteCommand,
      suiteStopGrace: const Duration(seconds: 5),
      listAttachedDevices:
          listAttachedDevices ??
          ({required flutterCommand}) async => const [device],
      resolveProjectRoot: ({testFile, requestedRoot, remember = true}) async {
        if (!projectResolvable) {
          throw ProjectResolutionException(['cwd=/nowhere']);
        }
        return (root: requestedRoot ?? projectRoot.path, testFile: testFile);
      },
      logger: MockLogger(),
      logFile: '${projectRoot.path}/patrol.log',
      developServiceFactory: fake.create,
      enterProjectDirectory: (_) {},
      hotRestartReadyTimeout: const Duration(milliseconds: 50),
    );
    // Runs before tearDown deletes projectRoot: the session keeps its log file
    // there open, and Windows does not delete an open file.
    addTearDown(session.dispose);
    return McpTools(
      session: session,
      deviceFinder: deviceFinder,
      processManager: MockProcessManager(),
      analytics: analytics,
    );
  }

  RequestHandlerExtra extra([AbortController? abort]) => RequestHandlerExtra(
    signal: (abort ?? BasicAbortController()).signal,
    requestId: 1,
    sendNotification: (notification, {relatedTask}) async {},
    sendRequest: <T extends BaseResultData>(request, factory, options) =>
        throw UnsupportedError('no client'),
  );

  String text(CallToolResult result) =>
      (result.content.single as TextContent).text;

  group('a web session', () {
    const chrome = Device(
      name: 'Chrome',
      id: 'chrome',
      targetPlatform: TargetPlatform.web,
      real: false,
    );

    Future<McpTools> webTools() async {
      final tools = toolsWith(
        FakeDevelop(device: chrome, webDebuggerPort: '9222'),
        listAttachedDevices: ({required flutterCommand}) async => const [
          chrome,
        ],
      );
      await tools.run({
        'testFile': 'app_test.dart',
        'device': 'chrome',
        'timeoutMinutes': 0.001,
      }, extra());
      return tools;
    }

    test('native-tree refuses and points at screenshot', () async {
      final result = await (await webTools()).nativeTree();

      expect(result.isError, isTrue);
      expect(text(result), contains('Use screenshot'));
    });

    test('devices lists the browser', () async {
      when(
        () => deviceFinder.getAttachedDevices(
          flutterCommand: any(named: 'flutterCommand'),
        ),
      ).thenAnswer((_) async => const [device, chrome]);

      final result = await toolsWith(FakeDevelop()).devices();

      expect(text(result), allOf(contains('test-device'), contains('chrome')));
    });
  });

  test('the status schema names every field a status can carry', () {
    const status = PatrolStatus(
      isDevelopRunning: true,
      projectRoot: '/project',
      testState: TestState.finishedFailed,
      versionWarning: 'version',
      output: 'output',
      currentTestFile: 'a_test.dart',
      warning: 'warning',
      deviceSelectionNote: 'note',
      deviceName: 'device',
      deviceId: 'id',
      devicePlatform: 'android',
      quietFor: Duration(seconds: 1),
      lastTestEntry: 'a',
      stallNote: 'stall',
      error: 'error',
      cli: CliOrigin(version: '1.0.0', source: CliSource.global),
      cliPinWarning: 'pin',
      logFile: '/project/patrol.log',
      terminalWarning: 'terminal',
    );

    expect(
      sessionStatusSchema.properties!.keys,
      containsAll(status.toMap().keys),
    );
  });

  test('the suite schema names every field a suite status can carry', () async {
    final results = File('${projectRoot.path}/results.jsonl');
    void report(Entry entry) => results.writeAsStringSync(
      '${jsonEncode(entry.toJson())}\n',
      mode: FileMode.append,
    );
    for (var i = 0; i < 11; i++) {
      report(TestEntry(name: 't$i', status: TestEntryStatus.start));
      report(
        TestEntry(name: 't$i', status: TestEntryStatus.failure, error: 'e'),
      );
    }
    report(TestEntry(name: 'current', status: TestEntryStatus.start));

    Future<SuiteRun> start(String resultsFile, Future<int> exitCode) =>
        SuiteRun.start(
          processManager: _ExitingProcessManager(exitCode),
          command: const ['patrol', 'test'],
          projectRoot: projectRoot.path,
          resultsFile: resultsFile,
          targets: const ['a_test.dart'],
          droppedFlags: const ['--open-devtools'],
          deviceSelectionNote: 'note',
          onOutput: (_) {},
        );
    final running = await start(results.path, Completer<int>().future);
    final brokenBuild = await start(
      '${projectRoot.path}/none.jsonl',
      Future.value(1),
    );
    await brokenBuild.done;

    final keys = {...running.toMap().keys, ...brokenBuild.toMap().keys};
    expect(keys, containsAll(['currentTest', 'failuresNotListed', 'warning']));
    expect(suiteStatusSchema.properties!.keys, containsAll(keys));
    expect(
      (suiteStatusSchema.properties![SuiteRun.stateKey]! as JsonString)
          .enumValues,
      SuiteState.values.map((state) => state.name),
    );
  });

  group('analytics', () {
    late MockProcessManager processManager;
    late List<Map<String, Object?>> events;
    late Completer<void> sentEnough;
    late int expected;

    setUp(() {
      processManager = MockProcessManager();
      when(
        () => processManager.start(
          any(),
          workingDirectory: any(named: 'workingDirectory'),
          runInShell: any(named: 'runInShell'),
        ),
      ).thenThrow(const ProcessException('flutter', []));
      events = [];
      sentEnough = Completer<void>();
      expected = 1;
    });

    McpAnalytics analytics() => McpAnalytics(
      send: (_, _, {eventData = const {}}) async {
        events.add(eventData);
        if (events.length == expected) {
          sentEnough.complete();
        }
        return true;
      },
      consented: () => true,
      cliSource: CliSource.project,
      processManager: processManager,
    );

    Future<List<(Object?, Object?)>> sent() async {
      await sentEnough.future.timeout(const Duration(seconds: 5));
      return [for (final e in events) (e['tool'], e['outcome'])];
    }

    test('reports each tool call', () async {
      expected = 2;
      final tools = toolsWith(
        FakeDevelop(),
        projectResolvable: false,
        analytics: analytics(),
      );

      await tools.devices();
      await tools.run({'testFile': 'app_test.dart'}, extra());

      expect(await sent(), [('devices', 'ok'), ('run', 'refused')]);
      expect(events.first['cli_source'], 'project');
    });

    test("asks the Flutter command the run used for its version, in the run's "
        'project', () async {
      final tools = toolsWith(
        FakeDevelop(),
        developArgs: const ['--flutter-command', 'my-flutter'],
        analytics: analytics(),
      );

      await tools.run({
        'testFile': 'app_test.dart',
        'timeoutMinutes': 0.001,
      }, extra());

      expect(await sent(), [('run', 'timed_out')]);
      final command =
          verify(
                () => processManager.start(
                  captureAny(),
                  workingDirectory: projectRoot.path,
                  runInShell: any(named: 'runInShell'),
                ),
              ).captured.single
              as List<Object>;
      expect(command.first, 'my-flutter');
      await tools.quit();
    });

    test('reports a session that failed before any test as a session '
        'error', () async {
      final tools = toolsWith(
        FakeDevelop(runError: Exception('gradle exploded')),
        analytics: analytics(),
      );

      await tools.run({'testFile': 'app_test.dart'}, extra());

      expect(await sent(), [('run', 'session_error')]);
    });

    test(
      'reports the platform of the device a suite runs on',
      () async {
        final tools = toolsWith(
          FakeDevelop(),
          suiteCommand: const ['sh', '-c', 'exit 0', 'patrol'],
          analytics: analytics(),
        );

        await tools.test({'waitMinutes': 1}, extra());

        expect(await sent(), [('test', 'passed')]);
        expect(events.single['platform'], 'android');
      },
      skip: Platform.isWindows ? 'The suite is a POSIX shell script.' : null,
    );

    test(
      'reports no suite platform for tools other than the suite',
      () async {
        expected = 2;
        final tools = toolsWith(
          FakeDevelop(),
          suiteCommand: const ['sh', '-c', 'exit 0', 'patrol'],
          analytics: analytics(),
        );

        await tools.test({'waitMinutes': 1}, extra());
        await tools.devices();

        expect(await sent(), [('test', 'passed'), ('devices', 'ok')]);
        expect(events.first['platform'], 'android');
        expect(events.last['platform'], 'none');
      },
      skip: Platform.isWindows ? 'The suite is a POSIX shell script.' : null,
    );

    test('reports a tool that throws as an error, and still throws', () async {
      final tools = toolsWith(FakeDevelop(), analytics: analytics());

      await expectLater(
        tools.run({'testFile': 42}, extra()),
        throwsA(isA<TypeError>()),
      );

      expect(await sent(), [('run', 'error')]);
    });
  });

  test('devices answers on a server that has no project', () async {
    final result = await toolsWith(
      FakeDevelop(),
      projectResolvable: false,
    ).devices();

    expect(result.isError, isNot(true));
    expect(text(result), contains('test-device'));
  });

  test('status on a server that has no project names what was tried', () async {
    final result = await toolsWith(
      FakeDevelop(),
      projectResolvable: false,
    ).status();

    expect(result.isError, isNot(true));
    expect(text(result), contains('cwd=/nowhere'));
  });

  test('run on a server that has no project is an error', () async {
    final result = await toolsWith(
      FakeDevelop(),
      projectResolvable: false,
    ).run({'testFile': 'app_test.dart'}, extra());

    expect(result.isError, isTrue);
    expect(text(result), contains('cwd=/nowhere'));
  });

  test('quit with nothing running is an error the caller can read', () async {
    final result = await toolsWith(FakeDevelop()).quit();

    expect(result.isError, isTrue);
    expect(text(result), contains('No active patrol session'));
  });

  test('run without a test file is an error', () async {
    final result = await toolsWith(
      FakeDevelop(),
    ).run({'testFile': ' '}, extra());

    expect(result.isError, isTrue);
    expect(text(result), contains('"testFile" argument is required'));
  });

  test('a refused run is an error, not a status of the old run', () async {
    final fake = FakeDevelop();
    final tools = toolsWith(fake);
    final first = await tools.run({
      'testFile': 'app_test.dart',
      'timeoutMinutes': 0.001,
    }, extra());
    expect(first.isError, isNot(true));

    final second = await tools.run({
      'testFile': 'other_test.dart',
      'timeoutMinutes': 0.001,
    }, extra());

    expect(second.isError, isTrue);
    expect(text(second), contains('did not become ready for hot restart'));
    await tools.quit();
  });

  test('a run the client cancels while starting does not come up', () async {
    final fake = FakeDevelop();
    final lookupStarted = Completer<void>();
    final tools = toolsWith(
      fake,
      listAttachedDevices: slowLookup(lookupStarted),
    );
    final abort = BasicAbortController();

    final run = tools.run({'testFile': 'app_test.dart'}, extra(abort));
    await lookupStarted.future;
    abort.abort();

    final result = await run;
    expect(result.isError, isTrue);
    expect(text(result), contains('cancelled'));
    expect(fake.events, isEmpty, reason: 'nothing should have been built');
  });

  group('test', () {
    List<String> suite(String script) => ['sh', '-c', script, 'patrol'];

    test('runs the suite and reports it with its project', () async {
      final result = await toolsWith(
        FakeDevelop(),
        suiteCommand: suite('exit 0'),
      ).test({'waitMinutes': 1}, extra());

      expect(result.isError, isNot(true));
      expect(result.structuredContent!['suiteState'], 'passed');
      expect(result.structuredContent!['projectRoot'], projectRoot.path);
    });

    test('is an error while a develop session runs', () async {
      final tools = toolsWith(FakeDevelop(), suiteCommand: suite('exit 0'));
      await tools.run({
        'testFile': 'app_test.dart',
        'timeoutMinutes': 0.001,
      }, extra());

      final result = await tools.test(const {}, extra());

      expect(result.isError, isTrue);
      expect(text(result), contains('Quit it before running a suite'));
      await tools.quit();
    });

    test('status waits for a running suite when asked', () async {
      final tools = toolsWith(FakeDevelop(), suiteCommand: suite('sleep 0.3'));
      final started = await tools.test({'waitMinutes': 0.0001}, extra());
      expect(started.structuredContent!['suiteState'], 'running');

      final status = await tools.status({'waitMinutes': 1});

      final suiteStatus =
          status.structuredContent!['suite']! as Map<String, Object?>;
      expect(suiteStatus['suiteState'], 'passed');
    });

    test('quit stops a running suite', () async {
      final tools = toolsWith(
        FakeDevelop(),
        suiteCommand: suite('trap "exit 130" INT; sleep 30 & wait'),
      );
      await tools.test({'waitMinutes': 0.0001}, extra());

      final quit = await tools.quit();
      final status = await tools.status();

      expect(text(quit), 'Stopped the suite.');
      expect(
        (status.structuredContent!['suite']! as Map)['suiteState'],
        'cancelled',
      );
    });

    test('status headlines a suite that started after a failed run', () async {
      final fake = FakeDevelop();
      final tools = toolsWith(fake, suiteCommand: suite('exit 0'));
      final run = tools.run({'testFile': 'app_test.dart'}, extra());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      fake.reportTestFailed('app_test taps', details: 'Bad state: tapped');
      await run;
      await tools.quit();

      await tools.test({'waitMinutes': 1}, extra());
      final status = (await tools.status()).structuredContent!;

      expect(status['summary'], SuiteState.passed.summary);
      expect(status['testState'], 'idle');
      expect(status.containsKey('error'), isFalse);
    });

    test('test and status name the log the suite writes to', () async {
      final tools = toolsWith(FakeDevelop(), suiteCommand: suite('exit 0'));

      final result = await tools.test({'waitMinutes': 1}, extra());
      final status = await tools.status();

      expect(result.structuredContent!['logFile'], isA<String>());
      expect(
        (status.structuredContent!['suite']! as Map)['logFile'],
        result.structuredContent!['logFile'],
      );
    });

    test('quit after patrol test exited reports the finished suite', () async {
      final tools = toolsWith(
        FakeDevelop(),
        // The background sleep keeps the pipes open past the exit.
        suiteCommand: suite('(sleep 2) & exit 0'),
      );
      await tools.test({'waitMinutes': 0.0001}, extra());
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final quit = await tools.quit();

      expect(
        text(quit),
        'The suite had already finished: ${SuiteState.passed.summary}',
      );
      final status = await tools.status();
      expect(
        (status.structuredContent!['suite']! as Map)['suiteState'],
        'passed',
      );
    });

    test('a suite the client stops waiting for keeps running', () async {
      final ready = File('${projectRoot.path}/ready');
      final go = File('${projectRoot.path}/go');
      final tools = toolsWith(
        FakeDevelop(),
        suiteCommand: suite(
          ': > "${ready.path}"; while [ ! -e "${go.path}" ]; do sleep 0.05; done',
        ),
      );
      final abort = BasicAbortController();

      final call = tools.test({'waitMinutes': 1}, extra(abort));
      await waitUntil(ready.existsSync, 'the suite to start');
      abort.abort();
      final result = await call.timeout(const Duration(seconds: 10));

      expect(result.structuredContent!['suiteState'], 'running');
      go.createSync();
      final status = await tools.status({'waitMinutes': 1});
      expect(
        (status.structuredContent!['suite']! as Map)['suiteState'],
        'passed',
      );
    });
  }, skip: Platform.isWindows ? 'The suites are POSIX shell scripts.' : null);
}

final class _ExitingProcessManager extends Fake implements ProcessManager {
  _ExitingProcessManager(this._exitCode);

  final Future<int> _exitCode;

  @override
  Future<Process> start(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async => _FakeProcess(_exitCode);
}

final class _FakeProcess extends Fake implements Process {
  _FakeProcess(this.exitCode);

  @override
  final Future<int> exitCode;

  @override
  Stream<List<int>> get stdout => const Stream.empty();

  @override
  Stream<List<int>> get stderr => const Stream.empty();

  @override
  IOSink get stdin => _ClosedSink();
}

final class _ClosedSink extends Fake implements IOSink {
  @override
  Future<void> close() async {}
}
