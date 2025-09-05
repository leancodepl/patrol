import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/commands/build_ios.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      IOSAppOptions(
        flutter: const FlutterAppOptions(
          command: FlutterCommand('flutter'),
          target: 'integration_test/test_bundle.dart',
          flavor: null,
          buildMode: BuildMode.debug,
          dartDefines: <String, String>{},
          dartDefineFromFilePaths: <String>[],
          buildName: null,
          buildNumber: null,
        ),
        bundleId: 'com.example.app',
        scheme: 'Runner',
        configuration: 'Debug',
        simulator: true,
        osVersion: 'latest',
        appServerPort: 8080,
        testServerPort: 8081,
      ),
    );
    registerFallbackValue(
      PatrolPubspecConfig.empty(flutterPackageName: 'test_app'),
    );
    registerFallbackValue(MemoryFileSystem().file('test'));
    registerFallbackValue(Directory.current);
  });

  group('BuildIOSCommand', () {
    late BuildIOSCommand command;
    late MockLogger mockLogger;
    late MockTestFinder mockTestFinder;
    late MockTestBundler mockTestBundler;
    late MockDartDefinesReader mockDartDefinesReader;
    late MockPubspecReader mockPubspecReader;
    late MockIOSTestBackend mockIosTestBackend;
    late MockAnalytics mockAnalytics;
    late MockCompatibilityChecker mockCompatibilityChecker;
    late CommandRunner<int> runner;

    setUp(() {
      mockLogger = MockLogger();
      mockTestFinder = MockTestFinder();
      mockTestBundler = MockTestBundler();
      mockDartDefinesReader = MockDartDefinesReader();
      mockPubspecReader = MockPubspecReader();
      mockIosTestBackend = MockIOSTestBackend();
      mockAnalytics = MockAnalytics();
      mockCompatibilityChecker = MockCompatibilityChecker();

      when(() => mockLogger.info(any())).thenReturn(null);
      when(() => mockLogger.detail(any())).thenReturn(null);
      when(() => mockLogger.err(any())).thenReturn(null);

      when(
        () => mockTestFinder.findAllTests(
          excludes: any(named: 'excludes'),
          testFileSuffix: any(named: 'testFileSuffix'),
        ),
      ).thenReturn(['integration_test/app_test.dart']);

      when(() => mockTestBundler.bundledTestFile).thenReturn(
        MemoryFileSystem().file('integration_test/test_bundle.dart'),
      );

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
          android: AndroidPubspecConfig.empty(),
          ios: IOSPubspecConfig(
            bundleId: 'com.example.app',
            appName: 'TestApp',
          ),
          macos: MacOSPubspecConfig.empty(),
        ),
      );

      when(() => mockIosTestBackend.build(any())).thenAnswer((_) async {});
      when(
        () => mockIosTestBackend.getSdkVersion(real: any(named: 'real')),
      ).thenAnswer((_) async => '17.0');
      when(
        () => mockIosTestBackend.xcTestRunPath(
          real: any(named: 'real'),
          scheme: any(named: 'scheme'),
          sdkVersion: any(named: 'sdkVersion'),
          absolutePath: any(named: 'absolutePath'),
        ),
      ).thenAnswer((_) async => 'build/ios_integ/Runner_Test.xctestrun');

      when(
        () => mockCompatibilityChecker.checkVersionsCompatibilityForBuild(
          patrolVersion: any(named: 'patrolVersion'),
        ),
      ).thenAnswer((_) async {});

      command = BuildIOSCommand(
        testFinder: mockTestFinder,
        testBundler: mockTestBundler,
        dartDefinesReader: mockDartDefinesReader,
        pubspecReader: mockPubspecReader,
        iosTestBackend: mockIosTestBackend,
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

        final result = await runner.run(['ios', ...args]) ?? 0;

        return result;
      }

      test('builds iOS app with default options', () async {
        final result = await runCommand();

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.flutter.buildMode, equals(BuildMode.debug));
        expect(opts.flutter.flavor, isNull);
        expect(opts.bundleId, isNull);
        expect(opts.simulator, equals(false));
        expect(opts.clearPermissions, equals(false));
      });

      test('builds iOS app with release build mode', () async {
        final result = await runCommand(['--release']);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.flutter.buildMode, equals(BuildMode.release));
      });

      test('builds iOS app with profile build mode', () async {
        final result = await runCommand(['--profile']);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.flutter.buildMode, equals(BuildMode.profile));
      });

      test('builds iOS app with custom flavor', () async {
        final result = await runCommand(['--flavor', 'dev']);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.flutter.flavor, equals('dev'));
        expect(opts.scheme, equals('dev'));
        expect(opts.configuration, equals('Debug-dev'));
      });

      test(
        'builds iOS app with flavor from config when not provided',
        () async {
          when(() => mockPubspecReader.read()).thenReturn(
            PatrolPubspecConfig(
              flutterPackageName: 'test_app',
              android: AndroidPubspecConfig.empty(),
              ios: IOSPubspecConfig(
                bundleId: 'com.example.app',
                appName: 'TestApp',
                flavor: 'production',
              ),
              macos: MacOSPubspecConfig.empty(),
            ),
          );

          final result = await runCommand();

          expect(result, equals(0));

          final captured = verify(
            () => mockIosTestBackend.build(captureAny()),
          ).captured;
          final opts = captured.first as IOSAppOptions;

          expect(opts.flutter.flavor, equals('production'));
        },
      );

      test('builds iOS app for simulator', () async {
        final result = await runCommand(['--simulator']);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.simulator, equals(true));
      });

      test('builds iOS app with clear permissions', () async {
        final result = await runCommand(['--clear-permissions']);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.clearPermissions, equals(true));
      });

      test('builds iOS app with custom iOS version', () async {
        final result = await runCommand(['--ios', '16.0']);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.osVersion, equals('16.0'));
      });

      test('builds iOS app with build name and number', () async {
        final result = await runCommand([
          '--build-name',
          '1.2.3',
          '--build-number',
          '42',
        ]);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.flutter.buildName, equals('1.2.3'));
        expect(opts.flutter.buildNumber, equals('42'));
      });

      test('builds iOS app with custom dart defines', () async {
        when(
          () => mockDartDefinesReader.fromCli(args: any(named: 'args')),
        ).thenReturn({'CUSTOM_KEY': 'custom_value'});

        final result = await runCommand([
          '--dart-define',
          'CUSTOM_KEY=custom_value',
        ]);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(
          opts.flutter.dartDefines,
          containsPair('CUSTOM_KEY', 'custom_value'),
        );
      });

      test('includes internal dart defines in build options', () async {
        final result = await runCommand();

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(
          opts.flutter.dartDefines,
          containsPair('PATROL_APP_BUNDLE_ID', 'com.example.app'),
        );
        expect(
          opts.flutter.dartDefines,
          containsPair('PATROL_IOS_APP_NAME', 'TestApp'),
        );
        expect(
          opts.flutter.dartDefines,
          containsPair(
            'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE',
            'false',
          ),
        );
      });

      test('builds iOS app with specific test targets', () async {
        when(() => mockTestFinder.findTests(any(), any())).thenReturn([
          'integration_test/specific_test.dart',
          'integration_test/another_test.dart',
        ]);

        final result = await runCommand([
          '--target',
          'integration_test/specific_test.dart',
          '--target',
          'integration_test/another_test.dart',
        ]);

        expect(result, equals(0));

        verify(
          () => mockTestFinder.findTests([
            'integration_test/specific_test.dart',
            'integration_test/another_test.dart',
          ]),
        ).called(1);

        verify(() => mockIosTestBackend.build(any())).called(1);
      });

      test('builds iOS app with test bundle generation', () async {
        final result = await runCommand(['--generate-bundle']);

        expect(result, equals(0));

        verify(
          () => mockTestBundler.createTestBundle(
            ['integration_test/app_test.dart'],
            null,
            null,
          ),
        ).called(1);

        verify(() => mockIosTestBackend.build(any())).called(1);
      });

      test('builds iOS app with tags and exclude tags', () async {
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
            ['integration_test/app_test.dart'],
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

      test('builds iOS app with dart define from file', () async {
        final result = await runCommand([
          '--dart-define-from-file',
          'defines.json',
        ]);

        expect(result, equals(0));

        final captured = verify(
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

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
          () => mockIosTestBackend.build(captureAny()),
        ).captured;
        final opts = captured.first as IOSAppOptions;

        expect(opts.appServerPort, equals(9090));
        expect(opts.testServerPort, equals(9091));
      });

      test('rethrows exception when iosTestBackend.build fails', () async {
        const error = 'Build process failed';

        when(() => mockIosTestBackend.build(any())).thenThrow(Exception(error));

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

        when(() => mockIosTestBackend.build(any())).thenThrow(Exception(error));

        await expectLater(runCommand, throwsA(isA<Exception>()));

        verify(() => mockLogger.err('Exception: $error')).called(1);
      });
    });

    group('printBinaryPaths', () {
      test('prints correct paths for simulator build', () {
        command.printBinaryPaths(simulator: true, buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'debug-iphonesimulator', 'Runner.app')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'debug-iphonesimulator', 'RunnerUITests-Runner.app')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for device build', () {
        command.printBinaryPaths(simulator: false, buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'release-iphoneos', 'Runner.app')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'release-iphoneos', 'RunnerUITests-Runner.app')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles different build modes correctly', () {
        command.printBinaryPaths(simulator: true, buildMode: 'profile');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(captured[0], contains('profile-iphonesimulator'));
        expect(captured[1], contains('profile-iphonesimulator'));
      });

      test('calls logger info exactly twice', () {
        command.printBinaryPaths(simulator: false, buildMode: 'debug');

        verify(() => mockLogger.info(any())).called(2);
      });

      test('prints paths in correct order', () {
        command.printBinaryPaths(simulator: true, buildMode: 'debug');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(captured[0], contains('Runner.app (app under test)'));
        expect(
          captured[1],
          contains('RunnerUITests-Runner.app (test instrumentation app)'),
        );
      });
    });
  });
}
