import 'dart:async';

import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('DevelopService', () {
    late MockDeviceFinder deviceFinder;
    late MockTestFinderFactory testFinderFactory;
    late MockTestFinder testFinder;
    late MockTestBundler testBundler;
    late MockDartDefinesReader dartDefinesReader;
    late MockCompatibilityChecker compatibilityChecker;
    late MockPubspecReader pubspecReader;
    late MockAndroidTestBackend androidTestBackend;
    late MockIOSTestBackend iosTestBackend;
    late MockMacOSTestBackend macosTestBackend;
    late MockWebTestBackend webTestBackend;
    late MockFlutterTool flutterTool;
    late MockLogger logger;

    const androidDevice = Device(
      name: 'emulator-5554',
      id: 'emulator-5554',
      targetPlatform: TargetPlatform.android,
      real: false,
    );

    setUpAll(() {
      registerFallbackValue(
        const AndroidAppOptions(
          flutter: FlutterAppOptions(
            command: FlutterCommand('flutter'),
            target: 'patrol_test/test_bundle.dart',
            flavor: null,
            buildMode: BuildMode.debug,
            dartDefines: <String, String>{},
            dartDefineFromFilePaths: <String>[],
            buildName: null,
            buildNumber: null,
          ),
          packageName: 'com.example.app',
          appServerPort: 8080,
          testServerPort: 8081,
          uninstall: false,
        ),
      );
      registerFallbackValue(androidDevice);
      registerFallbackValue(const FlutterCommand('flutter'));
      registerFallbackValue(<String, String>{});
    });

    setUp(() {
      deviceFinder = MockDeviceFinder();
      testFinderFactory = MockTestFinderFactory();
      testFinder = MockTestFinder();
      testBundler = MockTestBundler();
      dartDefinesReader = MockDartDefinesReader();
      compatibilityChecker = MockCompatibilityChecker();
      pubspecReader = MockPubspecReader();
      androidTestBackend = MockAndroidTestBackend();
      iosTestBackend = MockIOSTestBackend();
      macosTestBackend = MockMacOSTestBackend();
      webTestBackend = MockWebTestBackend();
      flutterTool = MockFlutterTool();
      logger = MockLogger();

      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);

      when(
        pubspecReader.read,
      ).thenReturn(PatrolPubspecConfig.empty(flutterPackageName: 'test_app'));

      when(() => testFinderFactory.create(any())).thenReturn(testFinder);
      when(
        () => testFinder.findTest(any(), any()),
      ).thenReturn('patrol_test/onboarding_test.dart');

      when(() => testBundler.ensureEntrypoint(any())).thenReturn(null);
      when(
        () => testBundler.getEntrypointFile(any()),
      ).thenReturn(MemoryFileSystem().file('patrol_test/test_bundle.dart'));
      when(() => testBundler.deleteEntrypointProxy(any())).thenReturn(null);

      when(() => dartDefinesReader.fromFile()).thenReturn(<String, String>{});
      when(
        () => dartDefinesReader.fromCli(args: any(named: 'args')),
      ).thenReturn(<String, String>{});
      when(
        () => dartDefinesReader.extractDartDefineConfigJsonMap(any()),
      ).thenReturn(<String, Object?>{});

      when(
        () => deviceFinder.find(
          any(),
          flutterCommand: any(named: 'flutterCommand'),
        ),
      ).thenAnswer((_) async => [androidDevice]);

      when(() => androidTestBackend.build(any())).thenAnswer((_) async {});
    });

    DevelopService buildService() => DevelopService(
      deviceFinder: deviceFinder,
      testFinderFactory: testFinderFactory,
      testBundler: testBundler,
      dartDefinesReader: dartDefinesReader,
      compatibilityChecker: compatibilityChecker,
      pubspecReader: pubspecReader,
      androidTestBackend: androidTestBackend,
      iosTestBackend: iosTestBackend,
      macosTestBackend: macosTestBackend,
      webTestBackend: webTestBackend,
      flutterTool: flutterTool,
      logger: logger,
      stdin: const Stream.empty(),
      onTestsCompleted: (result) => _lastResult = result,
    );

    const options = DevelopOptions(
      target: 'onboarding_test.dart',
      flutterCommand: FlutterCommand('flutter'),
      buildMode: BuildMode.debug,
      testServerPort: 8081,
      appServerPort: 8080,
      generateBundle: false,
      uninstall: false,
      checkCompatibility: false,
    );

    test(
      'reports test completion when the app shuts down before attach returns',
      () async {
        // The backend process exits early (e.g. "App shut down on request")
        // while `flutter attach` stays alive for the whole session.
        final backendExit = Completer<void>();
        when(
          () => androidTestBackend.execute(
            any(),
            any(),
            interruptible: any(named: 'interruptible'),
            showFlutterLogs: any(named: 'showFlutterLogs'),
            hideTestSteps: any(named: 'hideTestSteps'),
            flavor: any(named: 'flavor'),
            clearTestSteps: any(named: 'clearTestSteps'),
            onLogEntry: any(named: 'onLogEntry'),
          ),
        ).thenAnswer((_) => backendExit.future);

        // attach never completes -- it blocks for the whole develop session.
        final attachNeverCompletes = Completer<void>();
        when(
          () => flutterTool.attachForHotRestart(
            flutterCommand: any(named: 'flutterCommand'),
            deviceId: any(named: 'deviceId'),
            target: any(named: 'target'),
            appId: any(named: 'appId'),
            dartDefines: any(named: 'dartDefines'),
            openDevtools: any(named: 'openDevtools'),
            attachUsingUrl: any(named: 'attachUsingUrl'),
            onQuit: any(named: 'onQuit'),
          ),
        ).thenAnswer((_) => attachNeverCompletes.future);

        _lastResult = null;

        // `run()` never returns (attach is still pending), so don't await it.
        unawaited(buildService().run(options));

        // Simulate the app shutting down after the test started.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        backendExit.complete();

        // onTestsCompleted must fire promptly -- BEFORE attach returns.
        // Before the fix this only happened after attach, so it never fired
        // and MCP callers hung until their global timeout.
        await _waitFor(() => _lastResult != null);

        expect(_lastResult, isNotNull);
        expect(_lastResult!.success, isTrue);
        expect(attachNeverCompletes.isCompleted, isFalse);
      },
    );

    test(
      'reports failure when the backend fails before attach returns',
      () async {
        final backendExit = Completer<void>();
        when(
          () => androidTestBackend.execute(
            any(),
            any(),
            interruptible: any(named: 'interruptible'),
            showFlutterLogs: any(named: 'showFlutterLogs'),
            hideTestSteps: any(named: 'hideTestSteps'),
            flavor: any(named: 'flavor'),
            clearTestSteps: any(named: 'clearTestSteps'),
            onLogEntry: any(named: 'onLogEntry'),
          ),
        ).thenAnswer((_) => backendExit.future);

        final attachNeverCompletes = Completer<void>();
        when(
          () => flutterTool.attachForHotRestart(
            flutterCommand: any(named: 'flutterCommand'),
            deviceId: any(named: 'deviceId'),
            target: any(named: 'target'),
            appId: any(named: 'appId'),
            dartDefines: any(named: 'dartDefines'),
            openDevtools: any(named: 'openDevtools'),
            attachUsingUrl: any(named: 'attachUsingUrl'),
            onQuit: any(named: 'onQuit'),
          ),
        ).thenAnswer((_) => attachNeverCompletes.future);

        _lastResult = null;

        unawaited(
          buildService().run(options).catchError((Object _) {
            // The failure is rethrown by run(); swallow it here since the
            // assertion is on the reported result, not on run()'s error.
          }),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));
        backendExit.completeError(Exception('boom'));

        await _waitFor(() => _lastResult != null);

        expect(_lastResult, isNotNull);
        expect(_lastResult!.success, isFalse);
        expect(_lastResult!.error, isA<Exception>());
      },
    );
  });
}

TestCompletionResult? _lastResult;

/// Polls [condition] until it becomes true or a generous deadline elapses,
/// failing the test on timeout instead of hanging forever.
Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within the timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}
