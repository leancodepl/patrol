import 'dart:io' show Process;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/features/drive/flutter_tool.dart';
import 'package:process/process.dart';
import 'package:test/test.dart';

import '../../fixtures.dart';
import '../../mocks.dart';

void main() {
  late Process process;
  late ProcessManager processManager;
  late FileSystem fs;

  late DisposeScope disposeScope;
  late Logger logger;

  late FlutterTool flutterTool;

  group('FlutterTool', () {
    setUp(() {
      process = MockProcess();
      when(() => process.stdout).thenAnswer((_) => Stream.empty());
      when(() => process.stderr).thenAnswer((_) => Stream.empty());
      when(() => process.exitCode).thenAnswer((_) async => 0);
      processManager = MockProcessManager();

      fs = MemoryFileSystem.test();
      final wd = fs.directory('/home/johndoe/projects/awesome_app')
        ..createSync(recursive: true);
      fs.currentDirectory = wd;

      logger = MockLogger();
      disposeScope = DisposeScope();

      flutterTool = FlutterTool(
        processManager: processManager,
        fs: fs,
        parentDisposeScope: disposeScope,
        logger: logger,
      )..init(
          driver: 'test_driver/integration_test.dart',
          host: 'localhost',
          port: '8081',
          flavor: null,
          dartDefines: const {},
        );
    });

    group('build()', () {
      setUp(() {
        when(
          () => processManager.start(
            [
              'flutter',
              '--no-version-check',
              ...['build', 'apk'],
              '--debug',
              ...['--target', 'integration_test/app_test.dart'],
              ...['--dart-define', 'PATROL_HOST=localhost'],
              ...['--dart-define', 'PATROL_PORT=8081'],
            ],
            runInShell: any(named: 'runInShell', that: equals(true)),
          ),
        ).thenAnswer((_) async => process);
      });

      test('succeeds when `flutter build` succeeds', () async {
        await flutterTool.build(
          'integration_test/app_test.dart',
          androidDevice,
        );

        verify(
          () => logger.info('$dot Building apk for app_test.dart...'),
        ).called(1);

        verify(
          () => logger.success('✓ Building apk for app_test.dart succeeded!'),
        ).called(1);
      });

      test('throws when `flutter build` fails', () async {
        when(() => process.exitCode).thenAnswer((_) async => 1);

        await expectLater(
          () async => flutterTool.build(
            'integration_test/app_test.dart',
            androidDevice,
          ),
          throwsA(
            isA<FlutterBuildFailedException>()
                .having((err) => err.code, 'exitCode', equals(1)),
          ),
        );

        verify(
          () => logger.info('$dot Building apk for app_test.dart...'),
        ).called(1);

        verify(
          () => logger.err('✗ Building apk for app_test.dart failed'),
        ).called(1);
      });
    });

    group('drive', () {
      setUp(() {
        when(
          () => processManager.start(
            [
              'flutter',
              '--no-version-check',
              'drive',
              '--no-pub',
              ...['--driver', 'test_driver/integration_test.dart'],
              ...['--target', 'integration_test/app_test.dart'],
              '--use-application-binary',
              '/home/johndoe/projects/awesome_app/build/app/outputs/flutter-apk/app-debug.apk',
              ...['--device-id', 'emulator-5554'],
            ],
            environment: any(
              named: 'environment',
              that: equals({
                'PATROL_HOST': 'localhost',
                'PATROL_PORT': '8081',
                'DRIVER_DEVICE_ID': 'emulator-5554',
                'DRIVER_DEVICE_OS': 'android',
              }),
            ),
            runInShell: any(named: 'runInShell', that: equals(true)),
          ),
        ).thenAnswer((_) async => process);
      });

      test('succeeds when `flutter drive` succeeds', () async {
        await flutterTool.drive(
          'integration_test/app_test.dart',
          androidDevice,
        );

        verify(
          () => logger.info('$dot Running app_test.dart on emulator-5554...'),
        ).called(1);

        verify(() => logger.success('✓ app_test.dart passed!')).called(1);
      });

      test('throws when `flutter drive` fails', () async {
        when(() => process.exitCode).thenAnswer((_) async => 1);

        await expectLater(
          () async => flutterTool.drive(
            'integration_test/app_test.dart',
            androidDevice,
          ),
          throwsA(
            isA<FlutterDriverFailedException>()
                .having((err) => err.code, 'exitCode', equals(1)),
          ),
        );

        verify(
          () => logger.info('$dot Running app_test.dart on emulator-5554...'),
        ).called(1);

        verify(() => logger.err('✗ app_test.dart failed')).called(1);
      });
    });
  });
}
