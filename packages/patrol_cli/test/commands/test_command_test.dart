import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:fake_async/fake_async.dart';
import 'package:file/memory.dart';
import 'package:glob/glob.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/commands/test.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_config.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart' show BuildMode;
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('TestCommand', () {
    late MockDeviceFinder deviceFinder;
    late MockTestFinderFactory testFinderFactory;
    late MockTestFinder testFinder;
    late MockTestBundler testBundler;
    late MockDartDefinesReader dartDefinesReader;
    late MockPubspecReader pubspecReader;
    late MockAndroidTestBackend androidTestBackend;
    late MockIOSTestBackend iosTestBackend;
    late MockWebTestBackend webTestBackend;
    late MockWebCoverageTool webCoverageTool;
    late MockLogger logger;

    const androidDevice = Device(
      name: 'emulator-5554',
      id: 'emulator-5554',
      targetPlatform: TargetPlatform.android,
      real: false,
    );

    const iosSimulator = Device(
      name: 'iPhone 17 Pro',
      id: 'iphone-17-pro-simulator',
      targetPlatform: TargetPlatform.iOS,
      real: false,
    );

    const flutterOptions = FlutterAppOptions(
      command: FlutterCommand('flutter'),
      target: 'patrol_test/test_bundle.dart',
      flavor: null,
      buildMode: BuildMode.debug,
      dartDefines: <String, String>{},
      dartDefineFromFilePaths: <String>[],
      buildName: null,
      buildNumber: null,
    );

    setUpAll(() {
      registerFallbackValue(
        const AndroidAppOptions(
          flutter: flutterOptions,
          packageName: 'com.example.app',
          appServerPort: 8082,
          testServerPort: 8081,
          uninstall: true,
        ),
      );
      registerFallbackValue(
        IOSAppOptions(
          flutter: flutterOptions,
          bundleId: 'com.example.app',
          scheme: 'Runner',
          configuration: 'Debug',
          simulator: true,
          osVersion: 'latest',
          appServerPort: 8082,
          testServerPort: 8081,
        ),
      );
      registerFallbackValue(const WebAppOptions(flutter: flutterOptions));
      registerFallbackValue(androidDevice);
      registerFallbackValue(const FlutterCommand('flutter'));
      registerFallbackValue(
        const VideoRecordingConfig(enabled: false, outputDirectory: 'videos'),
      );
      registerFallbackValue(<String>{});
      registerFallbackValue(<RegExp>{});
      registerFallbackValue(<Glob>{});
    });

    setUp(() {
      deviceFinder = MockDeviceFinder();
      testFinderFactory = MockTestFinderFactory();
      testFinder = MockTestFinder();
      testBundler = MockTestBundler();
      dartDefinesReader = MockDartDefinesReader();
      pubspecReader = MockPubspecReader();
      androidTestBackend = MockAndroidTestBackend();
      iosTestBackend = MockIOSTestBackend();
      webTestBackend = MockWebTestBackend();
      webCoverageTool = MockWebCoverageTool();
      logger = MockLogger();

      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);
      when(() => logger.warn(any())).thenReturn(null);

      when(
        pubspecReader.read,
      ).thenReturn(PatrolPubspecConfig.empty(flutterPackageName: 'test_app'));

      when(() => testFinderFactory.create(any())).thenReturn(testFinder);
      when(
        () => testFinder.findAllTests(
          excludes: any(named: 'excludes'),
          testFileSuffix: any(named: 'testFileSuffix'),
        ),
      ).thenReturn(['patrol_test/onboarding_test.dart']);

      when(
        () => testBundler.getBundledTestFile(any(), web: any(named: 'web')),
      ).thenReturn(MemoryFileSystem().file('patrol_test/test_bundle.dart'));

      when(() => dartDefinesReader.fromFile()).thenReturn(<String, String>{});
      when(
        () => dartDefinesReader.fromCli(args: any(named: 'args')),
      ).thenReturn(<String, String>{});
      when(
        () => dartDefinesReader.extractDartDefineConfigJsonMap(any()),
      ).thenReturn(<String, Object?>{});

      when(() => androidTestBackend.build(any())).thenAnswer((_) async {});
      when(() => iosTestBackend.build(any())).thenAnswer((_) async {});

      when(
        webCoverageTool.prepareDataDirectory,
      ).thenAnswer((_) async => MemoryFileSystem().directory('coverage'));
      when(
        () => webCoverageTool.run(
          flutterPackageName: any(named: 'flutterPackageName'),
          packagesRegExps: any(named: 'packagesRegExps'),
          ignoreGlobs: any(named: 'ignoreGlobs'),
          includeWorkspacePackages: any(named: 'includeWorkspacePackages'),
        ),
      ).thenAnswer((_) async {});
    });

    Future<int?> runTest(Device device, List<String> args) {
      when(
        () => deviceFinder.find(
          any(),
          flutterCommand: any(named: 'flutterCommand'),
        ),
      ).thenAnswer((_) async => [device]);

      final runner = CommandRunner<int>('patrol', 'Test runner');
      addGlobalFlags(runner.argParser);
      runner.addCommand(
        TestCommand(
          deviceFinder: deviceFinder,
          testFinderFactory: testFinderFactory,
          testBundler: testBundler,
          dartDefinesReader: dartDefinesReader,
          compatibilityChecker: MockCompatibilityChecker(),
          pubspecReader: pubspecReader,
          androidTestBackend: androidTestBackend,
          iosTestBackend: iosTestBackend,
          macOSTestBackend: MockMacOSTestBackend(),
          webTestBackend: webTestBackend,
          coverageTool: MockCoverageTool(),
          webCoverageTool: webCoverageTool,
          analytics: MockAnalytics(),
          logger: logger,
          readFlutterVersion: (_) => FlutterVersion('3.38.0', 'stable'),
        ),
      );

      return runner.run([
        'test',
        '--no-generate-bundle',
        '--no-check-compatibility',
        ...args,
      ]);
    }

    Future<void> iosExecute() => iosTestBackend.execute(
      any(),
      any(),
      showFlutterLogs: any(named: 'showFlutterLogs'),
      hideTestSteps: any(named: 'hideTestSteps'),
      clearTestSteps: any(named: 'clearTestSteps'),
      videoConfig: any(named: 'videoConfig'),
      screenshotsOutputDir: any(named: 'screenshotsOutputDir'),
    );

    Future<void> iosUninstall() => iosTestBackend.uninstall(
      appId: any(named: 'appId'),
      flavor: any(named: 'flavor'),
      device: any(named: 'device'),
    );

    Future<void> webExecute() => webTestBackend.execute(
      any(),
      any(),
      showFlutterLogs: any(named: 'showFlutterLogs'),
      hideTestSteps: any(named: 'hideTestSteps'),
      clearTestSteps: any(named: 'clearTestSteps'),
    );

    Future<void> webCoverageRun() => webCoverageTool.run(
      flutterPackageName: any(named: 'flutterPackageName'),
      packagesRegExps: any(named: 'packagesRegExps'),
      ignoreGlobs: any(named: 'ignoreGlobs'),
      includeWorkspacePackages: any(named: 'includeWorkspacePackages'),
    );

    final throwsInterrupted = throwsA(
      isA<ToolInterrupted>().having(
        (err) => err.exitCode,
        'exitCode',
        exitCodeInterrupted,
      ),
    );

    group('when the run is interrupted', () {
      test('rethrows the interrupt with exit code 130 and no bug '
          'report message', () async {
        when(iosUninstall).thenAnswer((_) async {});
        when(iosExecute).thenThrow(const ToolInterrupted('xcodebuild'));

        await expectLater(
          runTest(iosSimulator, ['--bundle-id', 'com.example.app']),
          throwsInterrupted,
        );

        verifyNever(() => logger.err(any(that: contains('please report it'))));
      });

      test('rethrows an interrupt during the build with no bug report '
          'message', () async {
        when(
          () => iosTestBackend.build(any()),
        ).thenThrow(const ToolInterrupted('xcodebuild'));

        await expectLater(
          runTest(iosSimulator, ['--bundle-id', 'com.example.app']),
          throwsInterrupted,
        );

        verifyNever(() => logger.err(any(that: contains('please report it'))));
      });

      test('still uninstalls the app after the run', () async {
        when(iosUninstall).thenAnswer((_) async {});
        when(iosExecute).thenThrow(const ToolInterrupted('xcodebuild'));

        await expectLater(
          runTest(iosSimulator, ['--bundle-id', 'com.example.app']),
          throwsInterrupted,
        );

        // The first uninstall runs before the tests, the second is the
        // finalizer.
        verifyInOrder([iosUninstall, iosExecute, iosUninstall]);
      });

      test('keeps the interrupt when the uninstall after it fails', () async {
        var uninstalls = 0;
        when(iosUninstall).thenAnswer((_) async {
          if (uninstalls++ > 0) {
            throw Exception('device is gone');
          }
        });
        when(iosExecute).thenThrow(const ToolInterrupted('xcodebuild'));

        await expectLater(
          runTest(iosSimulator, ['--bundle-id', 'com.example.app']),
          throwsInterrupted,
        );
        expect(uninstalls, 2);
      });

      test('skips the web coverage conversion', () async {
        when(webExecute).thenThrow(const ToolInterrupted('web test run'));

        await expectLater(
          runTest(Device.bundledForTest('chrome')!, [
            '--device',
            'chrome',
            '--coverage',
          ]),
          throwsInterrupted,
        );

        verifyNever(webCoverageRun);
      });
    });

    test('gives up on the Android uninstall after the run once it takes '
        'longer than 30s', () {
      fakeAsync((async) {
        var uninstalls = 0;
        when(() => androidTestBackend.uninstall(any(), any())).thenAnswer(
          // The first uninstall is the one before the tests start.
          (_) => uninstalls++ == 0 ? Future.value() : Completer<void>().future,
        );
        when(
          () => androidTestBackend.execute(
            any(),
            any(),
            showFlutterLogs: any(named: 'showFlutterLogs'),
            hideTestSteps: any(named: 'hideTestSteps'),
            flavor: any(named: 'flavor'),
            clearTestSteps: any(named: 'clearTestSteps'),
            videoConfig: any(named: 'videoConfig'),
            pullScreenshots: any(named: 'pullScreenshots'),
            screenshotsOutputDir: any(named: 'screenshotsOutputDir'),
          ),
        ).thenAnswer((_) async {});

        int? exitCode;
        unawaited(
          runTest(androidDevice, [
            '--package-name',
            'com.example.app',
          ]).then((code) => exitCode = code),
        );

        async.elapse(const Duration(seconds: 29));
        expect(uninstalls, 2);
        expect(exitCode, isNull);
        verifyNever(() => logger.warn(any()));

        async.elapse(const Duration(seconds: 1));
        expect(exitCode, 0);
        verify(
          () => logger.warn(any(that: contains('did not finish'))),
        ).called(1);
      });
    });
  });
}
