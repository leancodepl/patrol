import 'dart:async';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/cli_origin.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';
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
    Platform? platform,
    Logger? logger,
    Duration errorSettle = const Duration(milliseconds: 50),
    CliOrigin cliOrigin = const CliOrigin(
      version: '4.9.0',
      source: CliSource.global,
    ),
  }) => PatrolSession(
    errorSettle: errorSettle,
    cliOrigin: cliOrigin,
    now: now,
    showTerminal: showTerminal,
    processManager: processManager ?? const LocalProcessManager(),
    platform: platform ?? const LocalPlatform(),
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

  test('quit cancels a run that is still starting', () async {
    final fake = FakeDevelop();
    // A device lookup slow enough to quit inside, which is where a real cold
    // start spends its first seconds.
    final lookupStarted = Completer<void>();
    final session = sessionWith(
      fake,
      listAttachedDevices: ({required flutterCommand}) async {
        lookupStarted.complete();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return const [
          Device(
            name: 'test device',
            id: 'test-device',
            targetPlatform: TargetPlatform.android,
            real: false,
          ),
        ];
      },
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

  /// A device lookup slow enough to act inside, which is where a real cold
  /// start spends its first seconds.
  AttachedDevicesReader slowLookup(Completer<void> started) =>
      ({required flutterCommand}) async {
        if (!started.isCompleted) {
          started.complete();
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
        return const [
          Device(
            name: 'test device',
            id: 'test-device',
            targetPlatform: TargetPlatform.android,
            real: false,
          ),
        ];
      };

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
          platform: FakePlatform(operatingSystem: 'macos'),
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
        platform: FakePlatform(operatingSystem: 'macos'),
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

  group('error', () {
    Future<({PatrolStatus status, bool started})> runOnce(
      PatrolSession session,
    ) => session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      timeout: const Duration(seconds: 5),
    );

    test('carries the failing test and the lines that follow it', () async {
      final fake = FakeDevelop();
      final session = sessionWith(fake);
      final run = runOnce(session);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      fake.reportTestFailed('logs in', error: 'Expected: true');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      fake
        ..reportError('  Actual: <false>')
        ..reportError('#0 main (login_test.dart:12)');

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
      'a hot restart clears it, and its wait does not end the new run',
      () async {
        final fake = FakeDevelop(hotRestartReady: Future<void>.value());
        final session = sessionWith(
          fake,
          errorSettle: const Duration(milliseconds: 100),
        );
        await startSession(session, 'app_test.dart');
        fake.reportTestFailed('logs in', error: 'Expected: true');

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
            contains('"args": ["run", "patrol_cli:main", "mcp"]'),
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
    expect(status.stallNote, contains('app_test login'));

    await session.dispose();
  });

  test('says a quiet run has reported no test at all', () async {
    final fake = FakeDevelop();
    var clock = DateTime(2026, 8, 18, 12);
    final session = sessionWith(fake, now: () => clock);
    await startSession(session, 'app_test.dart');

    clock = clock.add(const Duration(minutes: 6));

    // The signature of a run that builds and installs but never reports a step.
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

    clock = clock.add(const Duration(minutes: 5));
    // Same file, so this is a hot restart of the live session, and it times out
    // the way a caller's own run does.
    final result = await session.startAndWait(
      'app_test.dart',
      timeout: const Duration(milliseconds: 50),
    );

    expect(result.status.warning, contains('Run timed out'));
    expect(result.status.warning, contains('nothing for 5m00s'));

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
    // patrol_cli reports expected failures - an incompatible patrol, an
    // unsupported platform - as ToolExit with a message written for the user.
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
  });

  test('any other develop failure lands in the output', () async {
    final fake = FakeDevelop(runError: Exception('gradle exploded'));
    final session = sessionWith(fake);

    final result = await session.startAndWait(
      'app_test.dart',
      device: 'test-device',
      timeout: const Duration(seconds: 5),
    );

    expect(result.status.testState, TestState.finishedFailed);
    expect(result.status.output, contains('ERROR: Exception: gradle exploded'));
  });

  test('a backend that exits mid-run is reported as a failure', () async {
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

    final result = await run;
    expect(result.status.testState, TestState.finishedFailed);
    expect(result.status.warning, contains('stopped without the test'));
    expect(result.status.output, contains('ERROR: app crashed'));
    // The app is gone, so the session ends with it: the next run starts cold
    // instead of hot-restarting a dead app.
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
}
