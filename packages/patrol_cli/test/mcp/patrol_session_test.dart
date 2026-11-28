import 'dart:async';
import 'dart:io';

import 'package:mcp_dart/mcp_dart.dart' hide Logger;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/cli_origin.dart';
import 'package:patrol_cli/src/mcp/flutter_command_resolver.dart';
import 'package:patrol_cli/src/mcp/mcp_tools.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_cli/src/mcp/project_resolver.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:platform/testing.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';
import '../src/processes.dart';
import 'fake_develop.dart';

void main() {
  late Directory projectRoot;

  setUp(() {
    projectRoot = Directory.systemTemp.createTempSync('patrol_session_test');
    File('${projectRoot.path}/pubspec.yaml').writeAsStringSync('name: app\n');
    registerFallbackValue(
      DevelopOptions.parseArgs(const [], target: 'a_test.dart').$1,
    );
  });

  tearDown(() => projectRoot.deleteSync(recursive: true));

  /// The session is disposed before [projectRoot] is deleted: it keeps its log
  /// file there open, and Windows does not delete an open file.
  PatrolSession sessionWith(
    FakeDevelop fake, {
    List<String> developArgs = const [],
    Duration readyTimeout = const Duration(milliseconds: 50),
    ProjectRootResolver? resolveProjectRoot,
    AttachedDevicesReader? listAttachedDevices,
    DateTime Function()? now,
    Duration teardownTimeout = const Duration(seconds: 30),
    bool showTerminal = false,
    String? logFile,
    ProcessManager? processManager,
    NativePlatform? platform,
    Logger? logger,
    CliOrigin cliOrigin = const CliOrigin(
      version: '4.9.0',
      source: CliSource.global,
    ),
    List<String> suiteCommand = const ['false'],
  }) {
    final session = PatrolSession(
      suiteCommand: suiteCommand,
      suiteStopGrace: const Duration(seconds: 5),
      cliOrigin: cliOrigin,
      now: now,
      showTerminal: showTerminal,
      processManager: processManager ?? const LocalProcessManager(),
      platform: platform ?? NativePlatform.current!,
      teardownTimeout: teardownTimeout,
      listAttachedDevices:
          listAttachedDevices ??
          ({required flutterCommand}) async => const [
            Device(
              name: 'test device',
              id: 'test-device',
              targetPlatform: TargetPlatform.android,
              real: false,
            ),
          ],
      resolveProjectRoot:
          resolveProjectRoot ??
          ({testFile, requestedRoot, remember = true}) async =>
              (root: requestedRoot ?? projectRoot.path, testFile: testFile),
      logger: logger ?? MockLogger(),
      developArgs: developArgs,
      logFile: logFile ?? '${projectRoot.path}/patrol.log',
      developServiceFactory: fake.create,
      // The temp project is deleted in tearDown, and every later test in this
      // isolate would then fail reading a working directory that is gone.
      enterProjectDirectory: (_) {},
      hotRestartReadyTimeout: readyTimeout,
    );
    addTearDown(session.dispose);
    return session;
  }

  /// Starts a session and returns once it is live: run() never completes on its
  /// own, so the first call comes back on its timeout.
  Future<void> startSession(PatrolSession session, String testFile) async {
    final result = await session.startAndWait(
      testFile,
      device: 'test-device',
      timeout: const Duration(milliseconds: 50),
    );
    expect(result.started, isTrue, reason: 'session should have started');
    expect(result.status.isDevelopRunning, isTrue);
  }

  /// A lockfile pinning a `patrol` this CLI cannot drive.
  String incompatibleLock() {
    final patrol = const ['4.6.1', '4.6.0', '4.5.0', '4.4.0', '4.2.0']
        .firstWhere(
          (v) => patrolIncompatibility(v) != null,
          orElse: () =>
              throw StateError('No sample patrol version is incompatible'),
        );
    return '''
packages:
  patrol:
    dependency: "direct dev"
    source: hosted
    version: "$patrol"
''';
  }

  void writeIncompatibleLock() => File(
    '${projectRoot.path}/pubspec.lock',
  ).writeAsStringSync(incompatibleLock());

  test('refuses to run against a patrol this CLI cannot drive', () async {
    writeIncompatibleLock();
    final fake = FakeDevelop();

    final result = await sessionWith(
      fake,
    ).startAndWait('app_test.dart', device: 'test-device');

    expect(result.started, isFalse);
    expect(result.status.warning, contains('compatibility-table'));
    expect(result.status.versionWarning, isNotNull);
    expect(fake.events, isEmpty, reason: 'nothing should have been built');
  });

  test('runs anyway when the develop args opt out of the check', () async {
    writeIncompatibleLock();
    final fake = FakeDevelop();

    final result =
        await sessionWith(
          fake,
          developArgs: ['--no-check-compatibility'],
        ).startAndWait(
          'app_test.dart',
          device: 'test-device',
          timeout: const Duration(milliseconds: 50),
        );

    expect(result.started, isTrue);
    expect(result.status.versionWarning, isNotNull);
  });

  test('runs in the project the request names', () async {
    final other = Directory.systemTemp.createTempSync('patrol_other_project');
    addTearDown(() => other.deleteSync(recursive: true));
    final fake = FakeDevelop();
    final session = sessionWith(fake);

    final result = await session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      projectRoot: other.path,
      timeout: const Duration(milliseconds: 50),
    );

    expect(result.started, isTrue);
    expect(result.status.projectRoot, other.path);
  });

  test('refuses another project while a session is running', () async {
    final other = Directory.systemTemp.createTempSync('patrol_other_project');
    addTearDown(() => other.deleteSync(recursive: true));
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    final result = await session.startAndWait(
      'app_test.dart',
      projectRoot: other.path,
    );

    expect(result.started, isFalse);
    expect(result.status.warning, contains('Quit that session'));
    expect(result.status.projectRoot, projectRoot.path);
    expect(fake.events, ['create']);
  });

  test(
    'starts cold in another project when the session ends meanwhile',
    () async {
      final other = Directory.systemTemp.createTempSync('patrol_other_project');
      addTearDown(() => other.deleteSync(recursive: true));
      final fake = FakeDevelop();
      late PatrolSession session;
      session = sessionWith(
        fake,
        resolveProjectRoot: ({testFile, requestedRoot, remember = true}) async {
          if (!remember) {
            // The app stops while the request is being resolved.
            fake.endRun(0);
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          return (root: requestedRoot ?? projectRoot.path, testFile: testFile);
        },
      );
      await startSession(session, 'app_test.dart');

      final result = await session.startAndWait(
        'app_test.dart',
        projectRoot: other.path,
        timeout: const Duration(seconds: 5),
      );

      expect(result.status.warning ?? '', isNot(contains('Quit that session')));
      expect(fake.events.where((e) => e == 'create'), hasLength(2));
      expect(fake.options.last, isNotNull);
      await session.dispose();
    },
  );

  test('runs the test file as the project sees it', () async {
    final fake = FakeDevelop();
    final session = sessionWith(
      fake,
      // What the resolver answers for a file named against a workspace root
      // above the project.
      resolveProjectRoot: ({testFile, requestedRoot, remember = true}) async =>
          (root: projectRoot.path, testFile: 'patrol_test/login_test.dart'),
    );

    await startSession(session, 'app/patrol_test/login_test.dart');

    expect(fake.options.single.target, 'patrol_test/login_test.dart');
  });

  test('the compatibility answer follows the project', () async {
    final other = Directory.systemTemp.createTempSync('patrol_other_project');
    addTearDown(() => other.deleteSync(recursive: true));
    File('${other.path}/pubspec.yaml').writeAsStringSync('name: other\n');
    File('${other.path}/pubspec.lock').writeAsStringSync(incompatibleLock());
    final fake = FakeDevelop();
    final session = sessionWith(fake);

    // The project resolved first is one this CLI can drive.
    await session.ensureProjectResolved();
    expect(session.getStatus().versionWarning, isNull);

    final result = await session.startAndWait(
      'app_test.dart',
      projectRoot: other.path,
    );

    expect(result.started, isFalse);
    expect(result.status.versionWarning, isNotNull);
    expect(fake.events, isEmpty, reason: 'nothing should have been built');
  });

  test('a run after a quit reports its own session, not the old one', () async {
    final other = Directory.systemTemp.createTempSync('patrol_other_project');
    addTearDown(() => other.deleteSync(recursive: true));
    File('${other.path}/pubspec.yaml').writeAsStringSync('name: other\n');
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');
    await session.quit();

    final second = session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      projectRoot: other.path,
      timeout: const Duration(seconds: 5),
    );
    // The second session reports completion the way the first one did.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    fake.reportTestsPassed();

    final result = await second;
    expect(result.started, isTrue);
    expect(result.status.projectRoot, other.path);
    expect(result.status.testState, TestState.finishedPassed);
    expect(result.status.warning, isNull);
  });

  test('the previous session cannot report on the current one', () async {
    final other = Directory.systemTemp.createTempSync('patrol_other_project');
    addTearDown(() => other.deleteSync(recursive: true));
    File('${other.path}/pubspec.yaml').writeAsStringSync('name: other\n');
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');
    await session.quit();

    final second = session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      projectRoot: other.path,
      timeout: const Duration(seconds: 5),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    // The first session's backend reports its exit late, while the second is
    // building.
    fake.completions.first?.call(
      const TestCompletionResult(success: false, error: 'backend exited'),
    );
    fake.reportTestsPassed();

    final result = await second;
    expect(result.status.testState, TestState.finishedPassed);
    expect(result.status.warning, isNull);
    expect(result.status.output, isNot(contains('backend exited')));
  });

  group('a tool without a project', () {
    ProjectRootResolver unresolvable() =>
        ({testFile, requestedRoot, remember = true}) async =>
            throw ProjectResolutionException(['cwd=/nowhere']);

    McpTools toolsFor(PatrolSession session) => McpTools(
      session: session,
      deviceFinder: MockDeviceFinder(),
      processManager: MockProcessManager(),
    );

    test('status answers and says why there is no project', () async {
      final session = sessionWith(
        FakeDevelop(),
        resolveProjectRoot: unresolvable(),
      );

      final result = await toolsFor(session).status();

      expect(result.isError, isNot(true));
      expect(session.getStatus().warning, contains('cwd=/nowhere'));
    });

    test('run fails with the signals that were tried', () async {
      final session = sessionWith(
        FakeDevelop(),
        resolveProjectRoot: unresolvable(),
      );

      final result = await toolsFor(session).withProject(
        () async => fail('a run must not start without a project'),
        testFile: 'app_test.dart',
      );

      expect(result.isError, isTrue);
      expect(
        (result.content.single as TextContent).text,
        contains('cwd=/nowhere'),
      );
    });
  });

  test('quit cancels a run that is still starting', () async {
    final fake = FakeDevelop();
    final lookupStarted = Completer<void>();
    final session = sessionWith(
      fake,
      listAttachedDevices: slowLookup(lookupStarted),
    );

    final run = session.startAndWait('app_test.dart');
    await lookupStarted.future;
    expect(session.isRunning, isTrue, reason: 'a starting run is quittable');
    final answer = await session.quit();

    final result = await run;
    expect(answer, contains('Cancelled'));
    expect(result.started, isFalse);
    expect(result.status.warning, contains('cancelled'));
    expect(fake.events, isEmpty, reason: 'nothing should have been built');
  });

  test('dispose cancels a run that is still starting', () async {
    // The MCP client's own cancellation and the server's shutdown both end in
    // dispose, so a build they abandon must not come up behind them.
    final fake = FakeDevelop();
    final lookupStarted = Completer<void>();
    final session = sessionWith(
      fake,
      listAttachedDevices: slowLookup(lookupStarted),
    );

    final run = session.startAndWait('app_test.dart');
    await lookupStarted.future;
    await session.dispose();

    final result = await run;
    expect(result.started, isFalse);
    expect(session.isRunning, isFalse);
    expect(fake.events, isEmpty, reason: 'nothing should have been built');
  });

  test('a second run while one is starting is refused', () async {
    final fake = FakeDevelop();
    final lookupStarted = Completer<void>();
    final session = sessionWith(
      fake,
      listAttachedDevices: slowLookup(lookupStarted),
    );

    final first = session.startAndWait(
      'app_test.dart',
      timeout: const Duration(milliseconds: 50),
    );
    await lookupStarted.future;
    final second = await session.startAndWait(
      'other_test.dart',
      timeout: const Duration(milliseconds: 50),
    );

    expect(second.started, isFalse);
    expect(second.status.warning, contains('still starting'));
    expect((await first).started, isTrue);
    // One session, one service: the refused call created nothing.
    expect(fake.events.where((e) => e == 'create'), hasLength(1));
    await session.dispose();
  });

  test('a new session waits for the previous run to return', () async {
    // The previous run uninstalls the app and deletes the entrypoint it
    // generated after its backend has exited; the new session writes the same
    // entrypoint.
    final fake = FakeDevelop(runOutlivesExit: true);
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    final quitting = session.quit();
    final second = session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      timeout: const Duration(milliseconds: 50),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(fake.events, ['create', 'dispose']);

    fake.endRun(0);
    await quitting;
    expect((await second).started, isTrue);
    expect(fake.events, ['create', 'dispose', 'create']);
    fake.endRun(1);
    await session.dispose();
  });

  test('refuses to start while the previous run is still returning', () async {
    final fake = FakeDevelop(runOutlivesExit: true);
    final session = sessionWith(
      fake,
      teardownTimeout: const Duration(milliseconds: 20),
    );
    await startSession(session, 'app_test.dart');
    await session.quit();

    final refused = await session.startAndWait(
      'app_test.dart',
      device: 'test-device',
    );

    expect(refused.started, isFalse);
    expect(refused.status.warning, contains('still shutting down'));
    expect(fake.events, ['create', 'dispose']);

    fake.endRun(0);
    await startSession(session, 'app_test.dart');
    expect(fake.events, ['create', 'dispose', 'create']);
    await session.dispose();
  });

  test(
    'a previous session reporting late does not touch the new one',
    () async {
      final fake = FakeDevelop();
      final session = sessionWith(fake);
      await startSession(session, 'app_test.dart');
      await session.quit();
      await startSession(session, 'app_test.dart');

      fake.completions[0]?.call(
        const TestCompletionResult(success: false, error: 'old app crashed'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(session.isRunning, isTrue);
      expect(session.getStatus().testState, TestState.running);
      expect(fake.events, ['create', 'dispose', 'create']);
      await session.dispose();
    },
  );

  group('--show-terminal', () {
    late MockProcessManager processManager;
    late List<List<String>> commands;

    List<List<String>> opened() =>
        commands.where((command) => command.first == 'open').toList();

    setUp(() {
      processManager = MockProcessManager();
      commands = [];
      when(() => processManager.run(any())).thenAnswer((invocation) async {
        commands.add(
          (invocation.positionalArguments.first as List).cast<String>(),
        );
        return ProcessResult(0, 0, '', '');
      });
      addTearDown(() {
        for (final open in opened()) {
          final dir = File(open.last).parent;
          if (dir.existsSync()) {
            dir.deleteSync(recursive: true);
          }
        }
      });
    });

    PatrolSession terminalSession(FakeDevelop fake, {Logger? logger}) =>
        sessionWith(
          fake,
          showTerminal: true,
          processManager: processManager,
          platform: TestNativePlatform(operatingSystem: 'macos'),
          logger: logger,
        );

    test('opens one window for the log, not one per run', () async {
      final fake = FakeDevelop();
      final session = terminalSession(fake);

      await startSession(session, 'app_test.dart');
      await session.quit();
      await startSession(session, 'app_test.dart');
      await session.dispose();

      expect(opened(), hasLength(1));
    });

    test('opens Terminal on a script that follows the log by name', () async {
      final session = terminalSession(FakeDevelop());

      await startSession(session, 'app_test.dart');
      await session.dispose();

      final open = opened().single;
      expect(open.take(3), ['open', '-a', 'Terminal']);
      expect(commands, contains(equals(['chmod', '+x', open.last])));
      expect(commands.any((command) => command.first == 'osascript'), isFalse);
      final script = File(open.last).readAsStringSync();
      expect(script, startsWith('#!/bin/sh\n'));
      expect(script, contains("exec tail -F '${projectRoot.path}/patrol.log'"));
    });

    test('quotes a log path that holds a quote', () async {
      final session = sessionWith(
        FakeDevelop(),
        showTerminal: true,
        processManager: processManager,
        platform: TestNativePlatform(operatingSystem: 'macos'),
        logFile: "${projectRoot.path}/it's.log",
      );

      await startSession(session, 'app_test.dart');
      await session.dispose();

      final script = File(opened().single.last).readAsStringSync();
      expect(
        script,
        contains("exec tail -F '${projectRoot.path}/it'\\''s.log'"),
      );
    });

    test(
      'reports in the status why the window did not open, and retries',
      () async {
        when(() => processManager.run(any())).thenAnswer((invocation) async {
          final command = (invocation.positionalArguments.first as List)
              .cast<String>();
          commands.add(command);
          return command.first == 'open'
              ? ProcessResult(
                  0,
                  1,
                  '',
                  'Unable to find application named '
                      "'Terminal'\n",
                )
              : ProcessResult(0, 0, '', '');
        });
        final logger = MockLogger();
        final session = terminalSession(FakeDevelop(), logger: logger);

        await startSession(session, 'app_test.dart');
        const warning = "Unable to find application named 'Terminal'";
        expect(session.getStatus().terminalWarning, endsWith(warning));
        expect(
          session.getStatus().toMap()['terminalWarning'],
          'Could not open a Terminal window for the log at '
          '${projectRoot.path}/patrol.log: $warning',
        );
        await session.quit();
        await startSession(session, 'app_test.dart');
        await session.dispose();

        verify(
          () => logger.warn(
            'Could not open a Terminal window for the log at '
            '${projectRoot.path}/patrol.log: $warning',
          ),
        ).called(2);
        expect(opened(), hasLength(2));
        for (final open in opened()) {
          expect(File(open.last).parent.existsSync(), isFalse);
        }
      },
    );
  });

  test('names the Flutter command its run started with', () async {
    final session = sessionWith(
      FakeDevelop(),
      developArgs: const ['--flutter-command', 'my-flutter --verbose'],
    );
    await session.ensureProjectResolved();
    final resolved = FlutterCommandResolver()
        .resolve(projectRoot: projectRoot.path)
        .command;
    expect(
      session.flutterCommand.executable,
      resolved?.executable ?? 'flutter',
    );

    await startSession(session, 'app_test.dart');

    expect(session.flutterCommand.executable, 'my-flutter');
    expect(session.flutterCommand.arguments, ['--verbose']);
    await session.dispose();
  });

  test('names the log file in the status once a run has started', () async {
    final session = sessionWith(FakeDevelop());
    expect(session.getStatus().toMap(), isNot(contains('logFile')));

    await startSession(session, 'app_test.dart');

    expect(
      session.getStatus().toMap()['logFile'],
      '${projectRoot.path}/patrol.log',
    );
    await session.dispose();
  });

  test('captures what is written to stderr, as a failed build does', () async {
    final session = sessionWith(FakeDevelop());
    await startSession(session, 'app_test.dart');

    session.capturingStderr.writeln(
      'Error: unable to find directory entry in pubspec.yaml: assets/.env',
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      session.getStatus().output,
      contains('unable to find directory entry in pubspec.yaml: assets/.env'),
    );
    await session.dispose();
    expect(
      File('${projectRoot.path}/patrol.log').readAsStringSync(),
      contains('assets/.env'),
    );
  });

  group('error', () {
    Future<({PatrolStatus status, bool started})> runOnce(
      PatrolSession session,
    ) => session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      timeout: const Duration(seconds: 5),
    );

    test('carries the failing test and the lines logged before it', () async {
      final fake = FakeDevelop();
      final session = sessionWith(fake);
      final run = runOnce(session);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      fake.reportTestFailed(
        'logs in',
        details:
            'Expected: true\n'
            '  Actual: <false>\n'
            '#0 main (login_test.dart:12)',
      );

      final result = await run;
      expect(result.status.testState, TestState.finishedFailed);
      expect(
        result.status.error,
        'Test "logs in" failed.\n'
        'Expected: true\n'
        '  Actual: <false>\n'
        '#0 main (login_test.dart:12)',
      );
      expect(result.status.toMap()['error'], result.status.error);
      await session.dispose();
    });

    test('carries the error a failure entry names', () async {
      final fake = FakeDevelop();
      final session = sessionWith(fake);
      final run = runOnce(session);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      fake.onLogEntry?.call(
        TestEntry(
          name: 'taps',
          status: TestEntryStatus.failure,
          error: 'Bad state: tapped twice',
        ),
      );

      final result = await run;
      expect(
        result.status.error,
        'Test "taps" failed.\n'
        'Bad state: tapped twice',
      );
      await session.dispose();
    });

    test('holds only the first failing test of a file', () async {
      final fake = FakeDevelop();
      final session = sessionWith(fake);
      final run = runOnce(session);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      fake
        ..reportTestFailed('A', details: 'Expected: <1>\n  Actual: <2>')
        ..reportTestFailed('B', details: 'Expected: <3>\n  Actual: <4>')
        ..onLogEntry?.call(
          TestEntry(name: 'C', status: TestEntryStatus.success),
        )
        ..reportTestsPassed();

      final result = await run;
      expect(result.status.testState, TestState.finishedFailed);
      expect(
        result.status.error,
        'Test "A" failed.\n'
        'Expected: <1>\n'
        '  Actual: <2>',
      );
      expect(session.getStatus().error, result.status.error);
      await session.dispose();
    });

    test('is absent when the run passes', () async {
      final fake = FakeDevelop();
      final session = sessionWith(fake);
      final run = runOnce(session);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      fake.reportTestsPassed();

      final result = await run;
      expect(result.status.error, isNull);
      expect(result.status.toMap(), isNot(contains('error')));
      await session.dispose();
    });

    test(
      'a hot restart clears it, and the old failure does not end the new run',
      () async {
        final fake = FakeDevelop(hotRestartReady: Future<void>.value());
        final session = sessionWith(fake);
        await startSession(session, 'app_test.dart');
        fake.reportTestFailed('logs in', details: 'Expected: true');

        final restarted = session.startAndWait(
          'app_test.dart',
          timeout: const Duration(seconds: 5),
        );
        var answered = false;
        unawaited(restarted.then((_) => answered = true));
        await Future<void>.delayed(const Duration(milliseconds: 250));
        expect(
          answered,
          isFalse,
          reason: 'the old failure answered the restart',
        );
        expect(session.getStatus().error, isNull);

        fake.reportTestsPassed();
        final result = await restarted;
        expect(result.status.testState, TestState.finishedPassed);
        expect(result.status.error, isNull);
        await session.dispose();
      },
    );
  });

  group('the serving patrol_cli', () {
    void pinCli(String version) =>
        File('${projectRoot.path}/pubspec.lock').writeAsStringSync('''
packages:
  patrol_cli:
    dependency: "direct dev"
    source: hosted
    version: "$version"
''');

    test('every status names it', () async {
      final session = sessionWith(FakeDevelop());
      await session.ensureProjectResolved();

      expect(session.getStatus().toMap()['cli'], {
        'version': '4.9.0',
        'source': 'global',
      });
    });

    test(
      'a project pinning another version gets a warning with the fix',
      () async {
        pinCli('4.8.0');
        final session = sessionWith(FakeDevelop());
        await session.ensureProjectResolved();

        final warning = session.getStatus().cliPinWarning;
        expect(
          warning,
          allOf(
            contains('pins patrol_cli 4.8.0'),
            contains('global patrol_cli 4.9.0'),
            contains("your editor's MCP config"),
            contains('"args": ["run", "patrol_cli:main", "mcp"]'),
            contains('patrol-mcp#cli-as-a-project-dev-dependency'),
            isNot(contains('.mcp.json')),
          ),
        );
      },
    );

    test('a project pinning the same version gets none', () async {
      pinCli('4.9.0');
      final session = sessionWith(FakeDevelop());
      await session.ensureProjectResolved();

      expect(session.getStatus().cliPinWarning, isNull);
    });

    test('goes away once the lockfile pins the serving version', () async {
      pinCli('4.8.0');
      final session = sessionWith(FakeDevelop());
      await session.ensureProjectResolved();
      expect(session.getStatus().cliPinWarning, isNotNull);

      pinCli('4.9.0');

      expect(session.getStatus().cliPinWarning, isNull);
    });

    test('its own project gets none', () async {
      pinCli('4.8.0');
      final session = sessionWith(
        FakeDevelop(),
        cliOrigin: CliOrigin(
          version: '4.9.0',
          source: CliSource.project,
          projectRoot: projectRoot.path,
        ),
      );
      await session.ensureProjectResolved();

      expect(session.getStatus().cliPinWarning, isNull);
    });

    test("a dev dependency refuses another project's run", () async {
      final fake = FakeDevelop();
      final session = sessionWith(
        fake,
        cliOrigin: const CliOrigin(
          version: '4.9.0',
          source: CliSource.project,
          projectRoot: '/elsewhere/app',
        ),
      );

      final result = await session.startAndWait(
        'app_test.dart',
        device: 'test-device',
        projectRoot: projectRoot.path,
      );

      expect(result.started, isFalse);
      expect(
        result.status.warning,
        allOf(
          contains('dev dependencies of /elsewhere/app'),
          contains(projectRoot.path),
        ),
      );
      expect(fake.events, isEmpty);
    });

    test('a dev dependency runs a project below its own root', () async {
      final session = sessionWith(
        FakeDevelop(),
        cliOrigin: CliOrigin(
          version: '4.9.0',
          source: CliSource.project,
          projectRoot: projectRoot.parent.path,
        ),
      );

      await startSession(session, 'app_test.dart');
      await session.dispose();
    });
  });

  test('quit with nothing running answers instead of throwing', () async {
    final session = sessionWith(FakeDevelop());

    expect(await session.quit(), contains('No patrol session is running'));
  });

  test('quit answers once the session has released its resources', () async {
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    await session.quit();

    expect(fake.events, ['create', 'dispose']);
    expect(session.getStatus().isDevelopRunning, isFalse);
  });

  test('a new session waits for the previous one to let go', () async {
    // The old session removes the `adb forward` the new one needs, so starting
    // before it is gone leaves the automator unreachable.
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');
    session.sendCommand(SessionCommand.quit);

    await startSession(session, 'app_test.dart');

    expect(fake.events, ['create', 'dispose', 'create']);
  });

  test('status names the project the server is anchored to', () async {
    final session = sessionWith(FakeDevelop());
    await session.ensureProjectResolved();

    final status = session.getStatus();

    expect(status.projectRoot, projectRoot.path);
    expect(status.toMap()['projectRoot'], projectRoot.path);
  });

  test(
    'refuses a different test file instead of answering for the loaded one',
    () async {
      final fake = FakeDevelop();
      final session = sessionWith(fake);
      await startSession(session, 'first_test.dart');
      fake.reportTestsPassed();

      final result = await session.startAndWait('second_test.dart');

      expect(result.started, isFalse);
      expect(
        result.status.warning,
        allOf(contains('first_test.dart'), contains('second_test.dart')),
      );
      // The session is untouched: no second develop service, no restart sent.
      expect(fake.events, ['create']);
      expect(fake.stdinChars, isNot(contains('R')));
    },
  );

  test('refuses a hot restart while attach cannot act on it', () async {
    // hotRestartReady never completes: `flutter attach` would discard the 'R'.
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    // The timeout keeps this failing fast: without the readiness guard the
    // restart is sent and the wait would hang to the test timeout instead.
    final result = await session.startAndWait(
      'app_test.dart',
      timeout: const Duration(milliseconds: 400),
    );

    expect(result.started, isFalse);
    expect(
      result.status.warning,
      contains('did not become ready for hot restart'),
    );
    expect(fake.stdinChars, isNot(contains('R')));
  });

  test('refuses a hot restart at once, with why attach died', () async {
    // Created before anything awaits it, as the service's own failure is.
    final attachDied = Future<void>.error(
      const ToolExit(
        'Hot Restart is not available: `flutter attach` exited with code '
        '64:\n\tCould not find an option named "--flavor".',
      ),
    )..ignore();
    final fake = FakeDevelop(hotRestartReady: attachDied);
    final session = sessionWith(fake, readyTimeout: const Duration(minutes: 1));
    await startSession(session, 'app_test.dart');

    final watch = Stopwatch()..start();
    final result = await session.startAndWait(
      'app_test.dart',
      timeout: const Duration(minutes: 1),
    );

    expect(result.started, isFalse);
    expect(result.status.warning, contains('exited with code 64'));
    expect(result.status.warning, contains('--flavor'));
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
    expect(fake.stdinChars, isNot(contains('R')));
    await session.quit();
  });

  test('sends the hot restart once attach is ready', () async {
    final fake = FakeDevelop(hotRestartReady: Future<void>.value());
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    final result = await session.startAndWait(
      'app_test.dart',
      timeout: const Duration(milliseconds: 50),
    );

    expect(result.started, isTrue);
    expect(fake.stdinChars, contains('R'));
    expect(fake.events, ['create'], reason: 'a restart must reuse the session');
  });

  test(
    'reports an unusable develop flag instead of throwing at the caller',
    () async {
      final session = sessionWith(
        FakeDevelop(),
        developArgs: ['--not-a-real-flag'],
      );

      final result = await session.startAndWait(
        'app_test.dart',
        device: 'test-device',
      );

      expect(result.started, isFalse);
      expect(result.status.warning, contains('--not-a-real-flag'));
    },
  );

  test('a refused run leaves no log file open', () async {
    final session = sessionWith(
      FakeDevelop(),
      developArgs: ['--not-a-real-flag'],
    );

    final result = await session.startAndWait(
      'app_test.dart',
      device: 'test-device',
    );

    expect(result.started, isFalse);
    expect(File('${projectRoot.path}/patrol.log').existsSync(), isFalse);
  });

  test('forgets the device once the session is gone', () async {
    final fake = FakeDevelop(
      device: const Device(
        name: 'Pixel',
        id: 'test-device',
        targetPlatform: TargetPlatform.android,
        real: false,
      ),
    );
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');
    expect(session.device?.id, 'test-device');

    await session.dispose();

    // Otherwise screenshot and native-tree would keep acting on a dead session's
    // device instead of reporting that there is no session.
    expect(session.device, isNull);
    expect(session.getStatus().deviceName, isNull);
    expect(fake.stdinChars, contains('Q'));
  });

  test('lets the develop args turn the compatibility check back on', () async {
    final fake = FakeDevelop();
    final session = sessionWith(fake, developArgs: ['--check-compatibility']);
    await startSession(session, 'app_test.dart');

    expect(fake.options.single.checkCompatibility, isTrue);
    await session.dispose();
  });

  test('turns the compatibility check off by default', () async {
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    expect(fake.options.single.checkCompatibility, isFalse);
    await session.dispose();
  });

  test('runs once the project upgrades patrol, without a restart', () async {
    writeIncompatibleLock();
    final fake = FakeDevelop();
    final session = sessionWith(fake);

    final refused = await session.startAndWait(
      'app_test.dart',
      device: 'test-device',
    );
    expect(refused.started, isFalse);

    File('${projectRoot.path}/pubspec.lock').deleteSync();
    await startSession(session, 'app_test.dart');
    await session.dispose();
  });

  test('a status without a project still fits the schema', () {
    expect(sessionStatusSchema.required, isNot(contains('projectRoot')));
  });

  test('the status schema lists every key a status can carry', () {
    const status = PatrolStatus(
      isDevelopRunning: true,
      projectRoot: '/app',
      testState: TestState.running,
      versionWarning: 'w',
      output: 'o',
      currentTestFile: 'a_test.dart',
      warning: 'w',
      deviceSelectionNote: 'n',
      error: 'e',
      deviceName: 'd',
      deviceId: 'i',
      devicePlatform: 'p',
      quietFor: Duration(seconds: 1),
      lastTestEntry: 't',
      stallNote: 's',
      terminalWarning: 'tw',
      cli: CliOrigin(version: '5.0.0', source: CliSource.global),
      cliPinWarning: 'c',
      logFile: 'l',
    );

    expect(
      sessionStatusSchema.properties!.keys.toSet(),
      // The status tools add the suite's own status next to the session's.
      {...status.toMap().keys, 'suite'},
    );
  });

  test('reports how long a run has been quiet', () async {
    final fake = FakeDevelop();
    var clock = DateTime(2026, 8, 18, 12);
    final session = sessionWith(fake, now: () => clock);
    await startSession(session, 'app_test.dart');

    fake.onLogEntry?.call(
      TestEntry(name: 'app_test login', status: TestEntryStatus.start),
    );
    expect(session.getStatus().stallNote, isNull);

    clock = clock.add(const Duration(minutes: 4, seconds: 5));
    final status = session.getStatus();

    expect(status.quietFor, const Duration(minutes: 4, seconds: 5));
    expect(status.lastTestEntry, 'app_test login');
    expect(status.stallNote, contains('nothing for 4m05s'));
    expect(status.stallNote, contains('"app_test login", 4m05s ago'));

    await session.dispose();
  });

  test('does not call a silent build stalled', () async {
    // The app never comes up: hotRestartReady stays pending.
    final fake = FakeDevelop();
    var clock = DateTime(2026, 8, 18, 12);
    final session = sessionWith(fake, now: () => clock);
    await startSession(session, 'app_test.dart');

    clock = clock.add(const Duration(minutes: 6));

    final status = session.getStatus();
    expect(status.stallNote, isNull);
    expect(status.quietFor, isNull);

    await session.dispose();
  });

  test('says a quiet run has reported no test at all', () async {
    final fake = FakeDevelop(hotRestartReady: Future<void>.value());
    var clock = DateTime(2026, 8, 18, 12);
    final session = sessionWith(fake, now: () => clock);
    await startSession(session, 'app_test.dart');

    clock = clock.add(const Duration(minutes: 6));

    // The signature of an app that comes up but never reports a step.
    expect(
      session.getStatus().stallNote,
      contains('no test has been reported yet'),
    );

    await session.dispose();
  });

  test('a timed out run says how long the quiet lasted', () async {
    final fake = FakeDevelop(hotRestartReady: Future<void>.value());
    var clock = DateTime(2026, 8, 18, 12);
    final session = sessionWith(fake, now: () => clock);
    await startSession(session, 'app_test.dart');

    // Same file, so this is a hot restart of the live session, and it times out
    // the way a caller's own run does.
    final run = session.startAndWait(
      'app_test.dart',
      timeout: const Duration(milliseconds: 50),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    clock = clock.add(const Duration(minutes: 5));
    final result = await run;

    expect(result.status.warning, contains('Run timed out'));
    expect(result.status.warning, contains('nothing for 5m00s'));

    await session.dispose();
  });

  test('a hot restart starts the quiet and the last test over', () async {
    final fake = FakeDevelop(hotRestartReady: Future<void>.value());
    var clock = DateTime(2026, 8, 18, 12);
    final session = sessionWith(fake, now: () => clock);
    await startSession(session, 'app_test.dart');
    fake.onLogEntry?.call(
      TestEntry(name: 'app_test login', status: TestEntryStatus.start),
    );

    clock = clock.add(const Duration(minutes: 5));
    session.sendCommand(SessionCommand.hotRestart);
    final status = session.getStatus();

    expect(status.quietFor, Duration.zero);
    expect(status.lastTestEntry, isNull);

    await session.dispose();
  });

  test('a finished run is not reported as quiet', () async {
    final fake = FakeDevelop();
    var clock = DateTime(2026, 8, 18, 12);
    final session = sessionWith(fake, now: () => clock);
    await startSession(session, 'app_test.dart');
    fake.reportTestsPassed();

    clock = clock.add(const Duration(minutes: 10));
    final status = session.getStatus();

    expect(status.quietFor, isNull);
    expect(status.stallNote, isNull);

    await session.dispose();
  });

  test('a failing test entry finishes the run as failed', () async {
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    final run = session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      timeout: const Duration(seconds: 5),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    fake.onLogEntry?.call(
      TestEntry(name: 'app_test login', status: TestEntryStatus.failure),
    );

    final result = await run;
    expect(result.started, isTrue);
    expect(result.status.testState, TestState.finishedFailed);
    await session.dispose();
  });

  test('a develop failure with a message becomes the warning', () async {
    // patrol_cli reports expected failures as ToolExit with a message.
    final fake = FakeDevelop(
      runError: const ToolExit('Cannot use release mode.'),
    );
    final session = sessionWith(fake);

    final result = await session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      timeout: const Duration(seconds: 5),
    );

    expect(result.status.testState, TestState.finishedFailed);
    expect(result.status.warning, 'Cannot use release mode.');
    expect(result.status.output, contains('Cannot use release mode.'));
    // The log is written into the project, which tearDown deletes.
    await session.awaitTeardown();
  });

  /// Runs [body] with stderr captured by [session], as `patrol mcp` does.
  Future<T> capturingStderrOf<T>(
    PatrolSession session,
    Future<T> Function() body,
  ) => IOOverrides.runZoned(body, stderr: () => session.capturingStderr);

  test('any other develop failure is logged to the output once', () async {
    final fake = FakeDevelop(runError: Exception('gradle exploded'));
    final session = sessionWith(fake, logger: Logger());

    final result = await capturingStderrOf(
      session,
      () => session.startAndWait(
        'app_test.dart',
        device: 'test-device',
        timeout: const Duration(seconds: 5),
      ),
    );

    expect(result.status.testState, TestState.finishedFailed);
    expect(
      'ERROR: Exception: gradle exploded'.allMatches(result.status.output),
      hasLength(1),
    );
    await session.awaitTeardown();
  });

  test('dispose waits for a session whose app died to tear down', () async {
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    final run = session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      timeout: const Duration(seconds: 5),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    fake.onTestsCompleted?.call(
      const TestCompletionResult(success: false, error: 'app crashed'),
    );
    await run;
    expect(session.isRunning, isFalse);

    await session.dispose();

    expect(fake.events, ['create', 'dispose']);
  });

  test('a backend that exits mid-run is reported as a failure', () async {
    final fake = FakeDevelop();
    final session = sessionWith(fake, logger: Logger());
    final result = await capturingStderrOf(session, () async {
      final run = session.startAndWait(
        'app_test.dart',
        device: 'test-device',
        timeout: const Duration(seconds: 5),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      fake.onTestsCompleted?.call(
        const TestCompletionResult(success: false, error: 'app crashed'),
      );
      return run;
    });

    expect(result.status.testState, TestState.finishedFailed);
    expect(result.status.warning, contains('stopped without the test'));
    expect('ERROR: app crashed'.allMatches(result.status.output), hasLength(1));
    // The app is gone, so the session ends with it and the next run starts cold.
    expect(session.isRunning, isFalse);
    await session.awaitTeardown();
    expect(fake.events, ['create', 'dispose']);

    await startSession(session, 'app_test.dart');
    expect(fake.events, ['create', 'dispose', 'create']);
    await session.dispose();
  });

  test('our own quit is not reported as the app dying', () async {
    final fake = FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    session.sendCommand(SessionCommand.quit);
    // The backend exits because we asked it to.
    fake.onTestsCompleted?.call(const TestCompletionResult(success: true));

    final status = session.getStatus();
    expect(status.testState, TestState.idle);
    expect(status.warning, isNull);
    await session.awaitTeardown();
  });

  group('device selection', () {
    const pinned = Device(
      name: 'pinned device',
      id: 'pinned',
      targetPlatform: TargetPlatform.android,
      real: true,
    );

    test('a --device in the develop args beats the call', () async {
      final fake = FakeDevelop();
      final session = sessionWith(
        fake,
        developArgs: ['--device', 'pinned'],
        listAttachedDevices: ({required flutterCommand}) async => const [
          pinned,
        ],
      );

      final result = await session.startAndWait(
        'app_test.dart',
        device: 'test-device',
        timeout: const Duration(milliseconds: 50),
      );

      expect(result.started, isTrue);
      expect(fake.options.single.devices, ['pinned']);
      expect(
        result.status.deviceSelectionNote,
        contains('already pin --device pinned'),
      );
      await session.dispose();
    });

    test('refuses when nothing is attached', () async {
      final session = sessionWith(
        FakeDevelop(),
        listAttachedDevices: ({required flutterCommand}) async => const [],
      );

      final result = await session.startAndWait('app_test.dart');

      expect(result.started, isFalse);
      expect(result.status.warning, contains('No Android or iOS device'));
    });

    test('refuses when devices cannot be listed', () async {
      final session = sessionWith(
        FakeDevelop(),
        listAttachedDevices: ({required flutterCommand}) async =>
            throw Exception('flutter missing'),
      );

      final result = await session.startAndWait('app_test.dart');

      expect(result.started, isFalse);
      expect(
        result.status.warning,
        contains('Failed to detect attached devices'),
      );
    });
  });

  test('quit cancels a suite that is still starting', () async {
    final lookupStarted = Completer<void>();
    final session = sessionWith(
      FakeDevelop(),
      listAttachedDevices: slowLookup(lookupStarted),
    );

    final suite = session.startSuite(
      targets: const [],
      wait: const Duration(seconds: 10),
    );
    await lookupStarted.future;
    expect(session.isSuiteRunning, isTrue);
    final answer = await session.quit();

    expect(answer, 'Cancelled the suite that was starting.');
    expect((await suite).refusal, 'Cancelled the suite that was starting.');
    expect(session.isSuiteRunning, isFalse);
    expect(session.suiteStatus, isNull, reason: 'no suite should have started');
  });

  test(
    'a suite refuses to start while the previous run is still returning',
    () async {
      final fake = FakeDevelop(runOutlivesExit: true);
      final session = sessionWith(
        fake,
        teardownTimeout: const Duration(milliseconds: 20),
      );
      await startSession(session, 'app_test.dart');
      await session.quit();

      final refused = await session.startSuite(
        targets: const [],
        wait: const Duration(seconds: 10),
      );

      expect(refused.refusal, contains('still shutting down'));
      expect(session.suiteStatus, isNull);
      fake.endRun(0);
      await session.dispose();
    },
  );

  group(
    'suite',
    () {
      /// A stand-in for `patrol test` that records its arguments and working
      /// directory next to the project, then runs [then].
      List<String> recordingSuite({String then = 'exit 0'}) => [
        'sh',
        '-c',
        [
          'printf "%s\\n" "\$@" > "${projectRoot.path}/suite_args"',
          'pwd -P > "${projectRoot.path}/suite_cwd"',
          then,
        ].join('; '),
        'patrol',
      ];

      List<String> recordedArgs() =>
          File('${projectRoot.path}/suite_args').readAsLinesSync();

      test('runs patrol test in the project with the server flags', () async {
        final session = sessionWith(
          FakeDevelop(),
          developArgs: ['--flavor', 'dev', '--open-devtools'],
          suiteCommand: recordingSuite(),
        );

        final started = await session.startSuite(
          targets: ['patrol_test/a_test.dart'],
          wait: const Duration(seconds: 10),
        );

        expect(started.refusal, isNull);
        expect(started.status!['suiteState'], 'passed');
        expect(started.status!['droppedFlags'], contains('--open-devtools'));
        expect(recordedArgs(), containsAllInOrder(['test', '--flavor=dev']));
        expect(
          recordedArgs(),
          containsAll([
            '--target=patrol_test/a_test.dart',
            '--device=test-device',
          ]),
        );
        expect(
          recordedArgs().where((a) => a.startsWith('--results-file=')),
          hasLength(1),
        );
        expect(
          File('${projectRoot.path}/suite_cwd').readAsStringSync().trim(),
          projectRoot.resolveSymbolicLinksSync(),
        );
      });

      test('is refused while a develop session runs', () async {
        final session = sessionWith(
          FakeDevelop(),
          suiteCommand: recordingSuite(),
        );
        await startSession(session, 'a_test.dart');

        final started = await session.startSuite(
          targets: const [],
          wait: const Duration(seconds: 10),
        );

        expect(started.refusal, contains('Quit it before running a suite'));
        expect(File('${projectRoot.path}/suite_args').existsSync(), isFalse);
        await session.quit();
      });

      test(
        'keeps a single-test run and a second suite out while it runs',
        () async {
          final session = sessionWith(
            FakeDevelop(),
            suiteCommand: recordingSuite(
              then: 'trap "exit 130" INT; sleep 30 & wait',
            ),
          );

          final first = await session.startSuite(
            targets: const [],
            wait: const Duration(milliseconds: 50),
          );
          expect(first.status!['suiteState'], 'running');

          final second = await session.startSuite(
            targets: const [],
            wait: const Duration(milliseconds: 50),
          );
          expect(second.refusal, contains('already running'));

          final run = await session.startAndWait(
            'a_test.dart',
            timeout: const Duration(milliseconds: 50),
          );
          expect(run.started, isFalse);
          expect(run.status.warning, contains('A suite is running'));

          expect(await session.quit(), 'Stopped the suite.');
          expect(session.isSuiteRunning, isFalse);
          expect(session.suiteStatus!['suiteState'], 'cancelled');
        },
      );

      test(
        'counts a stopping suite as running until patrol test exits',
        () async {
          final ready = File('${projectRoot.path}/ready');
          final session = sessionWith(
            FakeDevelop(),
            suiteCommand: recordingSuite(
              then:
                  'trap "sleep 1; exit 130" INT; : > "${ready.path}"; '
                  'sleep 30 & wait',
            ),
          );
          await session.startSuite(
            targets: const [],
            wait: const Duration(milliseconds: 10),
          );
          await waitUntil(ready.existsSync, 'the suite to set its trap');

          final firstQuit = session.quit();

          expect(session.isSuiteRunning, isTrue);
          expect(session.suiteStatus!['suiteState'], 'stopping');
          final refused = await session.startSuite(
            targets: const [],
            wait: const Duration(milliseconds: 10),
          );
          expect(refused.refusal, contains('already running'));
          expect(await session.quit(), 'Stopped the suite.');
          expect(await firstQuit, 'Stopped the suite.');
          expect(session.isSuiteRunning, isFalse);
          expect(session.suiteStatus!['suiteState'], 'cancelled');
        },
      );

      test('keeps its project while a suite runs', () async {
        final other = Directory.systemTemp.createTempSync('patrol_other');
        addTearDown(() => other.deleteSync(recursive: true));
        final session = sessionWith(
          FakeDevelop(),
          suiteCommand: recordingSuite(then: 'sleep 30 & wait'),
        );
        await session.startSuite(
          targets: const [],
          wait: const Duration(milliseconds: 10),
        );

        await session.ensureProjectResolved(
          testFile: 'b_test.dart',
          requestedRoot: other.path,
        );

        expect(session.projectRoot, projectRoot.path);
        await session.quit();
      });

      test('waitForSuite returns once the suite ends', () async {
        final session = sessionWith(
          FakeDevelop(),
          suiteCommand: recordingSuite(then: 'sleep 0.3'),
        );
        await session.startSuite(
          targets: const [],
          wait: const Duration(milliseconds: 10),
        );

        await session.waitForSuite(const Duration(seconds: 10));

        expect(session.suiteStatus!['suiteState'], 'passed');
      });

      test('refuses flags develop does not take, without starting', () async {
        final session = sessionWith(
          FakeDevelop(),
          developArgs: ['--no-such-flag'],
          suiteCommand: recordingSuite(),
        );

        final started = await session.startSuite(
          targets: const [],
          wait: const Duration(seconds: 10),
        );

        expect(started.refusal, startsWith('Cannot start:'));
        expect(session.isSuiteRunning, isFalse);
      });
    },
    skip: NativePlatform.current!.isWindows
        ? 'The suites are POSIX shell scripts.'
        : null,
  );
}
