import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/runner/patrol_command_runner.dart';
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
    late PatrolCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      progress = MockProgress();
      when(() => logger.progress(any())).thenReturn(progress);

      pubUpdater = MockPubUpdater();

      commandRunner = PatrolCommandRunner(
        logger: logger,
        pubUpdater: pubUpdater,
      );
    });

    test(
      'updates when newer version exists',
      () async {
        when(() => pubUpdater.getLatestVersion('patrol_cli'))
            .thenAnswer((_) async => latestVersion);

        when(() => pubUpdater.update(packageName: 'patrol_cli'))
            .thenAnswer((_) async => FakeProcessResult());

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

        verify(() => pubUpdater.update(packageName: 'patrol_cli')).called(1);
      },
    );

    test(
      'does not update when already on latest version',
      () async {
        when(() => pubUpdater.getLatestVersion('patrol_cli'))
            .thenAnswer((_) async => version);

        final result = await commandRunner.run(['update']);
        expect(result, equals(0));
        verify(
          () => progress.complete(
            "You're on the latest patrol_cli version ($version)",
          ),
        ).called(1);

        verifyNever(() => pubUpdater.update(packageName: 'patrol_cli'));
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
