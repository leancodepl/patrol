import 'dart:async';

import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
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

    const iosDevice = Device(
      name: 'iPhone 17 Pro',
      id: 'iphone-17-pro',
      targetPlatform: TargetPlatform.iOS,
      real: true,
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
      registerFallbackValue(
        IOSAppOptions(
          flutter: const FlutterAppOptions(
            command: FlutterCommand('flutter'),
            target: 'patrol_test/test_bundle.dart',
            flavor: null,
            buildMode: BuildMode.debug,
            dartDefines: <String, String>{},
            dartDefineFromFilePaths: <String>[],
            buildName: null,
            buildNumber: null,
          ),
          scheme: 'Runner',
          configuration: 'Debug',
          simulator: true,
          osVersion: 'latest',
          appServerPort: 8080,
          testServerPort: 8081,
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

    DevelopService buildService({void Function(Entry entry)? onLogEntry}) =>
        DevelopService(
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
          onLogEntry: onLogEntry,
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
            forwardFlutterLogs: any(named: 'forwardFlutterLogs'),
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
            forwardFlutterLogs: any(named: 'forwardFlutterLogs'),
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

    group('with prebuilt APKs', () {
      const prebuiltOptions = DevelopOptions(
        target: 'onboarding_test.dart',
        flutterCommand: FlutterCommand('flutter'),
        buildMode: BuildMode.debug,
        testServerPort: 8081,
        appServerPort: 8080,
        generateBundle: false,
        uninstall: false,
        checkCompatibility: false,
        prebuiltApksDir: '/apks',
      );

      late Completer<void> attachCompleter;
      late Completer<void> backendExit;
      void Function(Entry entry)? backendOnLogEntry;
      var backendStarted = false;
      var hotRestarts = 0;

      setUpAll(() {
        registerFallbackValue(
          const FlutterAppOptions(
            command: FlutterCommand('flutter'),
            target: 'patrol_test/test_bundle.dart',
            flavor: null,
            buildMode: BuildMode.debug,
            dartDefines: <String, String>{},
            dartDefineFromFilePaths: <String>[],
            buildName: null,
            buildNumber: null,
          ),
        );
      });

      setUp(() {
        attachCompleter = Completer<void>();
        backendExit = Completer<void>();
        backendOnLogEntry = null;
        backendStarted = false;
        hotRestarts = 0;

        when(
          () => androidTestBackend.prepareSourcesForAttach(any()),
        ).thenAnswer((_) async {});
        when(
          () => androidTestBackend.executePrebuilt(
            any(),
            any(),
            apksDir: any(named: 'apksDir'),
            showFlutterLogs: any(named: 'showFlutterLogs'),
            hideTestSteps: any(named: 'hideTestSteps'),
            clearTestSteps: any(named: 'clearTestSteps'),
            onLogEntry: any(named: 'onLogEntry'),
          ),
        ).thenAnswer((invocation) {
          backendOnLogEntry =
              invocation.namedArguments[#onLogEntry]
                  as void Function(Entry entry)?;
          backendStarted = true;
          return backendExit.future;
        });
        when(
          () => flutterTool.attachForHotRestart(
            flutterCommand: any(named: 'flutterCommand'),
            deviceId: any(named: 'deviceId'),
            target: any(named: 'target'),
            appId: any(named: 'appId'),
            dartDefines: any(named: 'dartDefines'),
            openDevtools: any(named: 'openDevtools'),
            attachUsingUrl: any(named: 'attachUsingUrl'),
            forwardFlutterLogs: any(named: 'forwardFlutterLogs'),
            onQuit: any(named: 'onQuit'),
          ),
        ).thenAnswer((_) => attachCompleter.future);
        when(() => flutterTool.hotRestart()).thenAnswer((_) => hotRestarts++);
      });

      test(
        'skips the build, prepares the sources and hot restarts once attached',
        () async {
          unawaited(buildService().run(prebuiltOptions));
          await _waitFor(() => backendStarted);

          verifyNever(() => androidTestBackend.build(any()));
          verify(
            () => androidTestBackend.prepareSourcesForAttach(any()),
          ).called(1);
          final apksDir = verify(
            () => androidTestBackend.executePrebuilt(
              any(),
              any(),
              apksDir: captureAny(named: 'apksDir'),
              showFlutterLogs: any(named: 'showFlutterLogs'),
              hideTestSteps: any(named: 'hideTestSteps'),
              clearTestSteps: any(named: 'clearTestSteps'),
              onLogEntry: any(named: 'onLogEntry'),
            ),
          ).captured.single;
          expect(apksDir, '/apks');

          // The APK runs the test bundled at build time; the requested target
          // is only hot restarted in once `flutter attach` has connected.
          expect(hotRestarts, 0);
          attachCompleter.complete();
          await _waitFor(() => hotRestarts == 1);
        },
      );

      test(
        'holds back log entries until the requested target is hot restarted',
        () async {
          final received = <String>[];
          unawaited(
            buildService(
              onLogEntry: (entry) => received.add((entry as LogEntry).message),
            ).run(prebuiltOptions),
          );
          await _waitFor(() => backendOnLogEntry != null);

          // Emitted by the placeholder test baked into the APK -- must not be
          // mistaken for a result of the requested target (e.g. by patrol_mcp).
          backendOnLogEntry!(LogEntry(message: 'placeholder finished'));
          expect(received, isEmpty);

          attachCompleter.complete();
          await _waitFor(() => hotRestarts == 1);

          backendOnLogEntry!(LogEntry(message: 'requested target finished'));
          expect(received, ['requested target finished']);
        },
      );

      test('is rejected on non-Android devices', () async {
        const iosDevice = Device(
          name: 'iPhone',
          id: 'ios-sim',
          targetPlatform: TargetPlatform.iOS,
          real: false,
        );
        when(
          () => deviceFinder.find(
            any(),
            flutterCommand: any(named: 'flutterCommand'),
          ),
        ).thenAnswer((_) async => [iosDevice]);

        await expectLater(
          buildService().run(prebuiltOptions),
          throwsA(isA<ToolExit>()),
        );
        verifyNever(() => androidTestBackend.build(any()));
      });
    });

    group('iOS logs', () {
      /// Runs a develop session on [iosDevice] and reports where the app's
      /// logs were routed. The simulator keeps `flutter logs` whatever the
      /// flavor, because attach reads the VM service URL from them.
      Future<({bool fromFlutterLogs, bool fromPatrol})> runOnIos({
        required String? flavor,
      }) async {
        bool? fromFlutterLogs;
        bool? fromPatrol;

        when(
          () => deviceFinder.find(
            any(),
            flutterCommand: any(named: 'flutterCommand'),
          ),
        ).thenAnswer((_) async => [iosDevice]);
        when(() => iosTestBackend.build(any())).thenAnswer((_) async {});
        when(
          () => iosTestBackend.getInstalledAppsEnvVariable(any()),
        ).thenAnswer((_) async => '[]');
        when(
          () => iosTestBackend.execute(
            any(),
            any(),
            interruptible: any(named: 'interruptible'),
            showFlutterLogs: any(named: 'showFlutterLogs'),
            hideTestSteps: any(named: 'hideTestSteps'),
            clearTestSteps: any(named: 'clearTestSteps'),
            onLogEntry: any(named: 'onLogEntry'),
            videoConfig: any(named: 'videoConfig'),
          ),
        ).thenAnswer((invocation) {
          fromPatrol =
              invocation.namedArguments[#showFlutterLogs] as bool? ?? false;
          return Completer<void>().future;
        });
        when(
          () => flutterTool.attachForHotRestart(
            flutterCommand: any(named: 'flutterCommand'),
            deviceId: any(named: 'deviceId'),
            target: any(named: 'target'),
            appId: any(named: 'appId'),
            dartDefines: any(named: 'dartDefines'),
            openDevtools: any(named: 'openDevtools'),
            attachUsingUrl: any(named: 'attachUsingUrl'),
            forwardFlutterLogs: any(named: 'forwardFlutterLogs'),
            onQuit: any(named: 'onQuit'),
          ),
        ).thenAnswer((invocation) {
          fromFlutterLogs =
              invocation.namedArguments[#forwardFlutterLogs] as bool? ?? true;
          return Completer<void>().future;
        });

        unawaited(
          buildService().run(
            DevelopOptions(
              target: options.target,
              flutterCommand: options.flutterCommand,
              buildMode: options.buildMode,
              testServerPort: options.testServerPort,
              appServerPort: options.appServerPort,
              flavor: flavor,
              generateBundle: false,
              uninstall: false,
              checkCompatibility: false,
            ),
          ),
        );

        await _waitFor(() => fromFlutterLogs != null && fromPatrol != null);
        return (fromFlutterLogs: fromFlutterLogs!, fromPatrol: fromPatrol!);
      }

      // `flutter logs` needs a scheme named Runner, which a flavored project
      // does not have, so the app's logs have to come from Patrol's own stream.
      test('come from Patrol when a flavor is set', () async {
        final routing = await runOnIos(flavor: 'dev');

        expect(routing.fromFlutterLogs, isFalse);
        expect(routing.fromPatrol, isTrue);
      });

      test('come from flutter logs when no flavor is set', () async {
        final routing = await runOnIos(flavor: null);

        expect(routing.fromFlutterLogs, isTrue);
        expect(routing.fromPatrol, isFalse);
      });
    });

    group('resolveFlutterLogs', () {
      test('falls back to Patrol on a flavored iOS project', () {
        final result = DevelopService.resolveFlutterLogs(
          targetPlatform: TargetPlatform.iOS,
          flavor: 'dev',
          showFlutterLogs: false,
          attachUsingUrl: false,
        );

        expect(result.showFlutterLogs, isTrue);
        expect(result.forwardFlutterLogs, isFalse);
      });

      test('uses flutter logs on a flavorless iOS project', () {
        final result = DevelopService.resolveFlutterLogs(
          targetPlatform: TargetPlatform.iOS,
          flavor: null,
          showFlutterLogs: false,
          attachUsingUrl: false,
        );

        expect(result.showFlutterLogs, isFalse);
        expect(result.forwardFlutterLogs, isTrue);
      });

      test('uses flutter logs on a flavored Android project', () {
        final result = DevelopService.resolveFlutterLogs(
          targetPlatform: TargetPlatform.android,
          flavor: 'dev',
          showFlutterLogs: false,
          attachUsingUrl: false,
        );

        expect(result.showFlutterLogs, isFalse);
        expect(result.forwardFlutterLogs, isTrue);
      });

      // `flutter attach` reads the Dart VM service URL from `flutter logs`, so
      // a flavored iOS simulator cannot drop it.
      test('keeps flutter logs when attach reads the URL from them', () {
        final result = DevelopService.resolveFlutterLogs(
          targetPlatform: TargetPlatform.iOS,
          flavor: 'dev',
          showFlutterLogs: false,
          attachUsingUrl: true,
        );

        expect(result.forwardFlutterLogs, isTrue);
      });

      test('honors an explicit request on a flavorless Android project', () {
        final result = DevelopService.resolveFlutterLogs(
          targetPlatform: TargetPlatform.android,
          flavor: null,
          showFlutterLogs: true,
          attachUsingUrl: false,
        );

        expect(result.showFlutterLogs, isTrue);
        expect(result.forwardFlutterLogs, isTrue);
      });
    });
  });

  group('shouldAttachUsingUrl', () {
    Device device(TargetPlatform platform, {required bool real}) => Device(
      name: 'device',
      id: 'device',
      targetPlatform: platform,
      real: real,
    );

    test('is true on macOS', () {
      expect(
        shouldAttachUsingUrl(device(TargetPlatform.macOS, real: true)),
        isTrue,
      );
    });

    test('is true on the iOS simulator', () {
      expect(
        shouldAttachUsingUrl(device(TargetPlatform.iOS, real: false)),
        isTrue,
      );
    });

    test('is false on a physical iOS device', () {
      expect(
        shouldAttachUsingUrl(device(TargetPlatform.iOS, real: true)),
        isFalse,
      );
    });

    test('is false on Android', () {
      expect(
        shouldAttachUsingUrl(device(TargetPlatform.android, real: false)),
        isFalse,
      );
    });

    test('is false on web', () {
      expect(
        shouldAttachUsingUrl(device(TargetPlatform.web, real: false)),
        isFalse,
      );
    });
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
