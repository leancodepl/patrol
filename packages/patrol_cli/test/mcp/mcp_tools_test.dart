import 'dart:async';
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
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';
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
  }) {
    final session = PatrolSession(
      developArgs: developArgs,
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
    expect(text(second), contains('already running'));
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
}
