import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/command_runner.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

import '../../fakes.dart';
import '../../mocks.dart';

void main() {
  const latestVersion = '0.0.0';

  group('update', () {
    late Logger logger;
    late Progress progress;
    late PubUpdater pubUpdater;
    late ArtifactsRepository artifactsRepository;
    late PatrolCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      progress = MockProgress();
      when(() => logger.progress(any())).thenReturn(progress);

      pubUpdater = MockPubUpdater();
      artifactsRepository = MockArtifactsRepository();

      commandRunner = PatrolCommandRunner(
        logger: logger,
        pubUpdater: pubUpdater,
        artifactsRepository: artifactsRepository,
      );
    });

    test(
      'updates when newer version exists',
      () async {
        when(() => pubUpdater.getLatestVersion('patrol_cli'))
            .thenAnswer((_) async => latestVersion);

        when(() => pubUpdater.update(packageName: 'patrol_cli'))
            .thenAnswer((_) async => FakeProcessResult());

        when(
          () => artifactsRepository.downloadArtifacts(
            version: any(named: 'version', that: equals(latestVersion)),
          ),
        ).thenAnswer((_) async {});

        final result = await commandRunner.run(['update']);
        expect(result, equals(0));

        verify(
          () => logger.progress(
            'Checking if newer patrol_cli version is available',
          ),
        ).called(1);
        verify(
          () => progress.complete(
            'New patrol_cli version is available ($latestVersion)',
          ),
        ).called(1);

        verify(
          () => logger.progress(
            'Updating patrol_cli to version $latestVersion',
          ),
        ).called(1);
        verify(
          () => progress.complete(
            'Updated patrol_cli to version $latestVersion',
          ),
        ).called(1);

        verify(
          () => logger.progress(
            'Downloading artifacts for version $latestVersion',
          ),
        ).called(1);
        verify(
          () => progress.complete(
            'Downloaded artifacts for version $latestVersion',
          ),
        ).called(1);

        verify(() => pubUpdater.update(packageName: 'patrol_cli')).called(1);
        verify(
          () => artifactsRepository.downloadArtifacts(
            version: any(named: 'version', that: equals(latestVersion)),
          ),
        );
      },
    );

    test(
      'does not update when already on latest version',
      () async {
        when(() => pubUpdater.getLatestVersion('patrol_cli'))
            .thenAnswer((_) async => globalVersion);

        final result = await commandRunner.run(['update']);
        expect(result, equals(0));
        verify(
          () => progress.complete(
            "You're already using the latest patrol_cli version ($globalVersion)",
          ),
        ).called(1);

        verifyNever(() => pubUpdater.update(packageName: 'patrol_cli'));
        verifyNever(
          () => artifactsRepository.downloadArtifacts(
            version: any(named: 'version'),
          ),
        );
      },
    );

    test(
      'gracefully exits when latest version cannot be checked',
      () async {
        when(() => pubUpdater.getLatestVersion('patrol_cli'))
            .thenThrow(Exception('Failed to update package'));

        final result = await commandRunner.run(['update']);
        expect(result, equals(1));

        verify(
          () => logger.progress(
            'Checking if newer patrol_cli version is available',
          ),
        ).called(1);

        verify(
          () => progress.fail(
            'Failed to check if newer patrol_cli version is available',
          ),
        );

        verify(() => pubUpdater.getLatestVersion('patrol_cli')).called(1);
      },
    );
  });
}
