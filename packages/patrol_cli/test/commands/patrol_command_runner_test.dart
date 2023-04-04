import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/extensions/command_runner.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/runner/patrol_command_runner.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

import '../ios/ios_test_backend_test.dart';
import '../src/mocks.dart';

const latestVersion = '0.0.0';

final updatePrompt = '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(version)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('patrol update')} to update''';

void main() {
  group('PatrolCommandRunner', () {
    late Logger logger;
    late PubUpdater pubUpdater;
    late ProcessManager processManager;

    late PatrolCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      pubUpdater = MockPubUpdater();
      processManager = FakeProcessManager();

      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => version);

      commandRunner = PatrolCommandRunner(
        platform: FakePlatform(),
        processManager: processManager,
        pubUpdater: pubUpdater,
        fs: MemoryFileSystem.test(),
        analytics: MockAnalytics(),
        logger: logger,
      );
    });

    test('shows update message when newer version exists', () async {
      final result = await commandRunner.run(['--version']);
      expect(result, equals(0));
      verify(() => logger.info(updatePrompt)).called(1);
    });

    test('handles FormatException', () async {
      const exception = FormatException('bad format');
      var isFirstInvocation = true;
      when(() => logger.info(any())).thenAnswer((_) {
        if (isFirstInvocation) {
          isFirstInvocation = false;
          throw exception;
        }
      });
      final result = await commandRunner.run(['--version']);
      expect(result, equals(1));
      verify(() => logger.err(exception.message)).called(1);
      verify(() => logger.info(commandRunner.usage)).called(1);
    });

    test('handles UsageException', () async {
      final exception = UsageException('not like this', 'here is how');
      var isFirstInvocation = true;
      when(() => logger.info(any())).thenAnswer((_) {
        if (isFirstInvocation) {
          isFirstInvocation = false;
          throw exception;
        }
      });
      final result = await commandRunner.run(['--version']);
      expect(result, equals(1));
      verify(() => logger.err(exception.message)).called(1);
      verify(() => logger.info(exception.usage)).called(1);
    });

    test('prints usage when no command is passed', () async {
      final result = await commandRunner.run([]);
      expect(result, equals(0));
      verify(() => logger.info(commandRunner.usage)).called(1);
    });

    test(
      'prints error message and usage when command option is passed',
      () async {
        final result = await commandRunner.run(['foo']);
        expect(result, equals(1));
        verify(
          () => logger.err('Could not find a command named "foo".'),
        ).called(1);
        verify(
          () => logger.info(commandRunner.usageWithoutDescription),
        ).called(1);
      },
    );

    test(
      'prints error message and usage when unknown option is passed',
      () async {
        final result = await commandRunner.run(['--bar']);
        expect(result, equals(1));
        verify(
          () => logger.err('Could not find an option named "bar".'),
        ).called(1);
        verify(
          () => logger.info(commandRunner.usageWithoutDescription),
        ).called(1);
      },
    );

    group('--version', () {
      test('prints current version', () async {
        final result = await commandRunner.run(['--version']);
        expect(result, equals(0));
        verify(() => logger.info('patrol_cli v$version')).called(1);
      });
    });

    group('--verbose', () {
      test('enables verbose logging', () async {
        final result = await commandRunner.run(['--verbose']);
        expect(result, equals(0));

        verify(() {
          logger.info('Verbose mode enabled. More logs will be printed.');
        }).called(1);
      });
    });
  });
}
