import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/commands/build_android.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
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
      PatrolPubspecConfig.empty(flutterPackageName: 'test_app'),
    );
    registerFallbackValue(MemoryFileSystem().file('test'));
    registerFallbackValue(Directory.current);
  });

  group('BuildAndroidCommand', () {
    late BuildAndroidCommand command;
    late MockLogger mockLogger;
    late MockTestFinderFactory mockTestFinderFactory;
    late MockTestFinder mockTestFinder;
    late MockTestBundler mockTestBundler;
    late MockDartDefinesReader mockDartDefinesReader;
    late MockPubspecReader mockPubspecReader;
    late MockAndroidTestBackend mockAndroidTestBackend;
    late MockAnalytics mockAnalytics;
    late MockCompatibilityChecker mockCompatibilityChecker;
    late CommandRunner<int> runner;

    setUp(() {
      mockLogger = MockLogger();
      mockTestFinderFactory = MockTestFinderFactory();
      mockTestFinder = MockTestFinder();
      mockTestBundler = MockTestBundler();
      mockDartDefinesReader = MockDartDefinesReader();
      mockPubspecReader = MockPubspecReader();
      mockAndroidTestBackend = MockAndroidTestBackend();
      mockAnalytics = MockAnalytics();
      mockCompatibilityChecker = MockCompatibilityChecker();

      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.detail(any())).thenReturn(null);
      when(() => mockLogger.err(any())).thenReturn(null);

      when(
        () => mockTestFinderFactory.create(any()),
      ).thenReturn(mockTestFinder);

      when(
        () => mockTestFinder.findAllTests(
          excludes: any(named: 'excludes'),
          testFileSuffix: any(named: 'testFileSuffix'),
        ),
      ).thenReturn(['patrol_test/app_test.dart']);

      when(
        () => mockTestBundler.getBundledTestFile(any()),
      ).thenReturn(MemoryFileSystem().file('patrol_test/test_bundle.dart'));

      when(() => mockDartDefinesReader.fromFile()).thenReturn({});
      when(
        () => mockDartDefinesReader.fromCli(args: any(named: 'args')),
      ).thenReturn({});
      when(
        () => mockDartDefinesReader.extractDartDefineConfigJsonMap(any()),
      ).thenReturn({});

      when(() => mockPubspecReader.read()).thenReturn(
        PatrolPubspecConfig(
          flutterPackageName: 'test_app',
          android: AndroidPubspecConfig(
            packageName: 'com.example.app',
            appName: 'TestApp',
          ),
          ios: IOSPubspecConfig.empty(),
          macos: MacOSPubspecConfig.empty(),
        ),
      );

      when(() => mockAndroidTestBackend.build(any())).thenAnswer((_) async {});

      when(
        () => mockCompatibilityChecker.checkVersionsCompatibilityForBuild(
          patrolVersion: any(named: 'patrolVersion'),
        ),
      ).thenAnswer((_) async {});

      command = BuildAndroidCommand(
        testFinderFactory: mockTestFinderFactory,
        testBundler: mockTestBundler,
        dartDefinesReader: mockDartDefinesReader,
        pubspecReader: mockPubspecReader,
        androidTestBackend: mockAndroidTestBackend,
        analytics: mockAnalytics,
        logger: mockLogger,
        compatibilityChecker: mockCompatibilityChecker,
      );
    });

    group('run', () {
      Future<int> runCommand([List<String> args = const []]) async {
        runner = CommandRunner<int>('test', 'Test runner')
          ..argParser.addOption('flutter-command', defaultsTo: 'flutter')
          ..addCommand(command);

        final result = await runner.run(['android', ...args]) ?? 0;

        return result;
      }

      test('builds Android app with default options', () async {
        final result = await runCommand();

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.flutter.buildMode, equals(BuildMode.debug));
        expect(opts.flutter.flavor, isNull);
        expect(opts.packageName, equals('com.example.app'));
        expect(opts.uninstall, equals(true));
      });

      test('builds Android app with release build mode', () async {
        final result = await runCommand(['--release']);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.flutter.buildMode, equals(BuildMode.release));
      });

      test('builds Android app with profile build mode', () async {
        final result = await runCommand(['--profile']);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.flutter.buildMode, equals(BuildMode.profile));
      });

      test('builds Android app with custom flavor', () async {
        final result = await runCommand(['--flavor', 'dev']);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.flutter.flavor, equals('dev'));
      });

      test(
        'builds Android app with flavor from config when not provided',
        () async {
          when(() => mockPubspecReader.read()).thenReturn(
            PatrolPubspecConfig(
              flutterPackageName: 'test_app',
              android: AndroidPubspecConfig(
                packageName: 'com.example.app',
                appName: 'TestApp',
                flavor: 'production',
              ),
              ios: IOSPubspecConfig.empty(),
              macos: MacOSPubspecConfig.empty(),
            ),
          );

          final result = await runCommand();

          expect(result, equals(0));

          final captured = verify(
            () => mockAndroidTestBackend.build(captureAny()),
          ).captured;
          final opts = captured.first as AndroidAppOptions;

          expect(opts.flutter.flavor, equals('production'));
        },
      );

      test('builds Android app with custom package name', () async {
        final result = await runCommand(['--package-name', 'com.custom.app']);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.packageName, equals('com.custom.app'));
      });

      test('builds Android app with uninstall option', () async {
        final result = await runCommand(['--uninstall']);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.uninstall, equals(true));
      });

      test('builds Android app with build name and number', () async {
        final result = await runCommand([
          '--build-name',
          '1.2.3',
          '--build-number',
          '42',
        ]);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.flutter.buildName, equals('1.2.3'));
        expect(opts.flutter.buildNumber, equals('42'));
      });

      test('builds Android app with custom dart defines', () async {
        when(
          () => mockDartDefinesReader.fromCli(args: any(named: 'args')),
        ).thenReturn({'CUSTOM_KEY': 'custom_value'});

        final result = await runCommand([
          '--dart-define',
          'CUSTOM_KEY=custom_value',
        ]);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(
          opts.flutter.dartDefines,
          containsPair('CUSTOM_KEY', 'custom_value'),
        );
      });

      test('includes internal dart defines in build options', () async {
        final result = await runCommand();

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(
          opts.flutter.dartDefines,
          containsPair('PATROL_APP_PACKAGE_NAME', 'com.example.app'),
        );
        expect(
          opts.flutter.dartDefines,
          containsPair('PATROL_ANDROID_APP_NAME', 'TestApp'),
        );
        expect(
          opts.flutter.dartDefines,
          containsPair(
            'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE',
            'false',
          ),
        );
      });

      test('builds Android app with specific test targets', () async {
        when(() => mockTestFinder.findTests(any(), any())).thenReturn([
          'patrol_test/specific_test.dart',
          'patrol_test/another_test.dart',
        ]);

        final result = await runCommand([
          '--target',
          'patrol_test/specific_test.dart',
          '--target',
          'patrol_test/another_test.dart',
        ]);

        expect(result, equals(0));

        verify(
          () => mockTestFinder.findTests([
            'patrol_test/specific_test.dart',
            'patrol_test/another_test.dart',
          ]),
        ).called(1);

        verify(() => mockAndroidTestBackend.build(any())).called(1);
      });

      test('builds Android app with test bundle generation', () async {
        final result = await runCommand(['--generate-bundle']);

        expect(result, equals(0));

        verify(
          () => mockTestBundler.createTestBundle(
            'patrol_test',
            ['patrol_test/app_test.dart'],
            null,
            null,
          ),
        ).called(1);

        verify(() => mockAndroidTestBackend.build(any())).called(1);
      });

      test('builds Android app with tags and exclude tags', () async {
        final result = await runCommand([
          '--generate-bundle',
          '--tags',
          'smoke',
          '--exclude-tags',
          'flaky',
        ]);

        expect(result, equals(0));

        verify(
          () => mockTestBundler.createTestBundle(
            'patrol_test',
            ['patrol_test/app_test.dart'],
            'smoke',
            'flaky',
          ),
        ).called(1);
      });

      test('runs compatibility check when enabled', () async {
        when(() => mockPubspecReader.getPatrolVersion()).thenReturn('2.0.0');

        final result = await runCommand(['--check-compatibility']);

        expect(result, equals(0));

        verify(
          () => mockCompatibilityChecker.checkVersionsCompatibilityForBuild(
            patrolVersion: '2.0.0',
          ),
        ).called(1);
      });

      test('skips compatibility check when disabled', () async {
        final result = await runCommand(['--no-check-compatibility']);

        expect(result, equals(0));

        verifyNever(
          () => mockCompatibilityChecker.checkVersionsCompatibilityForBuild(
            patrolVersion: any(named: 'patrolVersion'),
          ),
        );
      });

      test('builds Android app with dart define from file', () async {
        when(
          () => mockDartDefinesReader.extractDartDefineConfigJsonMap(any()),
        ).thenReturn({'FILE_KEY': 'file_value'});

        final result = await runCommand([
          '--dart-define-from-file',
          'defines.json',
        ]);

        expect(result, equals(0));

        verify(
          () => mockDartDefinesReader.extractDartDefineConfigJsonMap([
            'defines.json',
          ]),
        ).called(1);

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.flutter.dartDefineFromFilePaths, contains('defines.json'));
      });

      test('passes correct app and test server ports', () async {
        final result = await runCommand([
          '--app-server-port',
          '9090',
          '--test-server-port',
          '9091',
        ]);

        expect(result, equals(0));

        final captured = verify(
          () => mockAndroidTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as AndroidAppOptions;

        expect(opts.appServerPort, equals(9090));
        expect(opts.testServerPort, equals(9091));
      });

      test('rethrows exception when androidTestBackend.build fails', () async {
        const error = 'Build process failed';

        when(
          () => mockAndroidTestBackend.build(any()),
        ).thenThrow(Exception(error));

        await expectLater(
          runCommand,
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains(error),
            ),
          ),
        );

        verify(() => mockLogger.err('Exception: $error')).called(1);
      });

      test('logs error information when build fails', () async {
        const error = 'Build process failed';

        when(
          () => mockAndroidTestBackend.build(any()),
        ).thenThrow(Exception(error));

        await expectLater(runCommand, throwsA(isA<Exception>()));

        verify(() => mockLogger.err('Exception: $error')).called(1);
      });
    });

    group('printApkPaths', () {
      test('prints correct paths for debug build without flavor', () {
        command.printApkPaths(buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'debug', 'app-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for release build without flavor', () {
        command.printApkPaths(buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'release', 'app-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'release', 'app-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for debug build with flavor', () {
        command.printApkPaths(flavor: 'dev', buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'dev', 'debug', 'app-dev-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'dev', 'debug', 'app-dev-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for release build with flavor', () {
        command.printApkPaths(flavor: 'prod', buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'prod', 'release', 'app-prod-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'prod', 'release', 'app-prod-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for custom build mode without flavor', () {
        command.printApkPaths(buildMode: 'profile');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'profile', 'app-profile.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'profile', 'app-profile-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for custom build mode with flavor', () {
        command.printApkPaths(flavor: 'staging', buildMode: 'profile');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'staging', 'profile', 'app-staging-profile.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'staging', 'profile', 'app-staging-profile-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles uppercase build mode correctly', () {
        command.printApkPaths(buildMode: 'DEBUG');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'debug', 'app-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles mixed case build mode correctly with flavor', () {
        command.printApkPaths(flavor: 'Dev', buildMode: 'Release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'Dev', 'release', 'app-Dev-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'Dev', 'release', 'app-Dev-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles complex flavor names correctly', () {
        command.printApkPaths(flavor: 'staging-prod', buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'staging-prod', 'release', 'app-staging-prod-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'staging-prod', 'release', 'app-staging-prod-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles null flavor correctly', () {
        command.printApkPaths(buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'debug', 'app-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints paths in correct order', () {
        command.printApkPaths(flavor: 'dev', buildMode: 'debug');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(captured.length, 2);
        expect(captured[0], contains('(app under test)'));
        expect(captured[1], contains('(test instrumentation app)'));
      });

      test('calls logger info exactly twice per invocation', () {
        command.printApkPaths(buildMode: 'debug');

        verify(() => mockLogger.info(any())).called(2);
      });

      test('checks proper paths for flavor and build mode', () {
        command.printApkPaths(flavor: 'dev', buildMode: 'debug');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(
          captured[0],
          contains(join('build', 'app', 'outputs', 'apk', 'dev', 'debug')),
        );
        expect(
          captured[1],
          contains(
            join(
              'build',
              'app',
              'outputs',
              'apk',
              'androidTest',
              'dev',
              'debug',
            ),
          ),
        );
      });

      test('generates consistent APK names for same parameters', () {
        command.printApkPaths(flavor: 'prod', buildMode: 'release');
        final firstCall = verify(() => mockLogger.info(captureAny())).captured;

        // Reset mock
        reset(mockLogger);
        when(() => mockLogger.info(any())).thenReturn(null);

        command.printApkPaths(flavor: 'prod', buildMode: 'release');
        final secondCall = verify(() => mockLogger.info(captureAny())).captured;

        expect(firstCall, equals(secondCall));
      });
    });
  });
}
