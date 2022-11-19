import 'dart:io' show Process;

import 'package:dispose_scope/dispose_scope.dart';
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
  late Logger logger;
  late DisposeScope disposeScope;

  late FlutterTool flutterTool;

  group('FlutterTool', () {
    setUp(() {
      process = MockProcess();
      when(() => process.stdout).thenAnswer((_) => Stream.empty());
      when(() => process.stderr).thenAnswer((_) => Stream.empty());
      when(() => process.exitCode).thenAnswer((_) async => 0);

      processManager = MockProcessManager();
      when(
        () => processManager.start(
          any(),
          environment: any(named: 'environment'),
          runInShell: any(named: 'runInShell', that: equals(true)),
        ),
      ).thenAnswer((_) async => process);

      logger = MockLogger();
      disposeScope = DisposeScope();

      flutterTool = FlutterTool(
        processManager: processManager,
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

      test('fails when `flutter build` fails', () async {
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

      test('fails when `flutter drive` fails', () async {
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
