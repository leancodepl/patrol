import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/mcp/patrol_session.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

class _MockDevelopService extends Mock implements DevelopService {}

/// Captures what the session hands its develop service, so tests can drive the
/// callbacks the real service would fire and read the stdin it would receive.
class _FakeDevelop {
  _FakeDevelop({Device? device, Future<void>? hotRestartReady}) {
    when(() => service.device).thenReturn(device);
    when(
      () => service.hotRestartReady,
    ).thenAnswer((_) => hotRestartReady ?? Completer<void>().future);
    // A develop session outlives a test run: run() returns when the session is
    // quit, as the real one does when `flutter attach` exits.
    when(() => service.run(any())).thenAnswer((invocation) {
      options.add(invocation.positionalArguments.first as DevelopOptions);
      final finished = Completer<void>();
      _runs.add(finished);
      return finished.future;
    });
  }

  final service = _MockDevelopService();

  final _runs = <Completer<void>>[];

  /// What each started session was asked to run.
  final options = <DevelopOptions>[];

  /// `create` and the disposal of each session's scope, in the order they
  /// happened.
  final events = <String>[];

  /// The completion callback each session was created with.
  final completions = <void Function(TestCompletionResult result)?>[];

  final stdinChars = <String>[];
  void Function(Entry entry)? onLogEntry;
  void Function(TestCompletionResult result)? onTestsCompleted;

  DevelopService create({
    required String projectRoot,
    required DisposeScope disposeScope,
    required Stream<List<int>> stdin,
    Future<void> Function()? onExit,
    void Function(TestCompletionResult result)? onTestsCompleted,
    void Function(Entry entry)? onLogEntry,
    bool verbose = false,
  }) {
    events.add('create');
    this.onLogEntry = onLogEntry;
    this.onTestsCompleted = onTestsCompleted;
    completions.add(onTestsCompleted);
    // Teardown takes a moment, as it does in a real session where processes
    // have to be reaped, so an overlapping start is visible in the order.
    disposeScope.addDispose(
      () => Future<void>.delayed(
        const Duration(milliseconds: 30),
        () => events.add('dispose'),
      ),
    );
    stdin.listen((bytes) {
      final chars = String.fromCharCodes(bytes);
      stdinChars.add(chars);
      if (chars.contains(SessionCommand.quit.value)) {
        _runs.lastOrNull?.complete();
      }
    });
    return service;
  }

  /// What `patrol` reports when every test in develop mode has run.
  void reportTestsPassed() => onLogEntry?.call(
    ConfigEntry(config: {ConfigEntry.developCompletedKey: true}),
  );
}

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
    _FakeDevelop fake, {
    List<String> developArgs = const [],
    Duration readyTimeout = const Duration(milliseconds: 50),
    ProjectRootResolver? resolveProjectRoot,
  }) => PatrolSession(
    listAttachedDevices: ({required flutterCommand}) async => const [
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
    logger: MockLogger(),
    developArgs: developArgs,
    logFile: '${projectRoot.path}/patrol.log',
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
    final fake = _FakeDevelop();

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
    final fake = _FakeDevelop();

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
    final fake = _FakeDevelop();
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
    final fake = _FakeDevelop();
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
    final fake = _FakeDevelop();
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
    final fake = _FakeDevelop();
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
    final fake = _FakeDevelop();
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
    final fake = _FakeDevelop();
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

  test('the previous session cannot report on the current one', () async {
    final other = Directory.systemTemp.createTempSync('patrol_other_project');
    addTearDown(() => other.deleteSync(recursive: true));
    File('${other.path}/pubspec.yaml').writeAsStringSync('name: other\n');
    final fake = _FakeDevelop();
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
    // The first session's backend reports its exit late, while the second one
    // is building.
    fake.completions.first?.call(
      const TestCompletionResult(success: false, error: 'backend exited'),
    );
    fake.reportTestsPassed();

    final result = await second;
    expect(result.status.testState, TestState.finishedPassed);
    expect(result.status.warning, isNull);
    expect(result.status.output, isNot(contains('backend exited')));
  });

  test('quit answers once the session has released its resources', () async {
    final fake = _FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');

    await session.quit();

    expect(fake.events, ['create', 'dispose']);
    expect(session.getStatus().isDevelopRunning, isFalse);
  });

  test('a new session waits for the previous one to let go', () async {
    // The old session removes the `adb forward` the new one needs, so starting
    // before it is gone leaves the automator unreachable.
    final fake = _FakeDevelop();
    final session = sessionWith(fake);
    await startSession(session, 'app_test.dart');
    session.sendCommand(SessionCommand.quit);

    await startSession(session, 'app_test.dart');

    expect(fake.events, ['create', 'dispose', 'create']);
  });

  test('status names the project the server is anchored to', () async {
    final session = sessionWith(_FakeDevelop());
    await session.ensureProjectResolved();

    final status = session.getStatus();

    expect(status.projectRoot, projectRoot.path);
    expect(status.toMap()['projectRoot'], projectRoot.path);
  });

  test(
    'refuses a different test file instead of answering for the loaded one',
    () async {
      final fake = _FakeDevelop();
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
    final fake = _FakeDevelop();
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
    final fake = _FakeDevelop(hotRestartReady: Future<void>.value());
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
        _FakeDevelop(),
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
    final fake = _FakeDevelop(
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
}
