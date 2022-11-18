import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/command_runner.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

import '../../command_runner_test.dart';
import '../../fakes.dart';

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
        when(() => pubUpdater.getLatestVersion(any()))
            .thenAnswer((_) async => latestVersion);

        when(() => pubUpdater.update(packageName: 'patrol_cli'))
            .thenAnswer((_) async => FakeProcessResult());

        when(
          () => artifactsRepository.downloadArtifacts(
            version: any(named: 'version', that: equals(latestVersion)),
          ),
        ).thenAnswer((_) async {});

        when(() => logger.progress(any())).thenReturn(progress);

        final result = await commandRunner.run(['update']);
        expect(result, equals(0));

        verify(() => logger.progress('Checking for updates')).called(1);
        verify(
          () => progress.complete('New version is available ($latestVersion)'),
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
        when(() => pubUpdater.getLatestVersion(any()))
            .thenAnswer((_) async => globalVersion);
        when(() => logger.progress(any())).thenReturn(MockProgress());

        final result = await commandRunner.run(['update']);
        expect(result, equals(0));
        verify(
          () => logger.info(
            'You already have the newest version of patrol_cli ($globalVersion)',
          ),
        ).called(1);

        //verifyNever(() => logger.progress(any()));
        verifyNever(() => pubUpdater.update(packageName: 'patrol_cli'));
      },
    );
  });
}
