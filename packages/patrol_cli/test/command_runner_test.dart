import 'package:args/command_runner.dart';
import 'package:file/memory.dart';
import 'package:logging/logging.dart';
import 'package:mason_logger/mason_logger.dart' show lightCyan, lightYellow;
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/command_runner.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/constants.dart';
import 'package:patrol_cli/src/common/extensions/command_runner.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class MockPubUpdater extends Mock implements PubUpdater {}

class MockArtifactsRepository extends Mock implements ArtifactsRepository {}

const latestVersion = '0.0.0';

final updatePrompt = '''
${lightYellow.wrap('Update available!')} ${lightCyan.wrap(version)} \u2192 ${lightCyan.wrap(latestVersion)}
Run ${lightCyan.wrap('patrol update')} to update''';

void main() {
  group('PatrolCommandRunner', () {
    late Logger logger;
    late PubUpdater pubUpdater;
    late ArtifactsRepository artifactsRepository;

    late PatrolCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      pubUpdater = MockPubUpdater();
      artifactsRepository = MockArtifactsRepository();
      when(() => artifactsRepository.areArtifactsPresent()).thenReturn(true);

      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => version);

      commandRunner = PatrolCommandRunner(
        logger: logger,
        pubUpdater: pubUpdater,
        artifactsRepository: artifactsRepository,
        fs: MemoryFileSystem.test(),
      );
    });

    test('shows update message when newer version exists', () async {
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => latestVersion);

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
      verify(() => logger.severe(exception.message)).called(1);
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
      verify(() => logger.severe(exception.message)).called(1);
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
          () => logger.severe('Could not find a command named "foo".'),
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
          () => logger.severe('Could not find an option named "bar".'),
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
