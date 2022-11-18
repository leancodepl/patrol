import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/command_runner.dart';
import 'package:patrol_cli/src/common/constants.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';

import '../../command_runner_test.dart';

void main() {
  const latestVersion = '0.0.0';

  group('update', () {
    late PubUpdater pubUpdater;
    late Logger logger;
    late PatrolCommandRunner commandRunner;

    setUp(() {
      pubUpdater = MockPubUpdater();
      // when(() => pubUpdater.getLatestVersion(patrolCliPackage)).thenAnswer((invocation) async => )

      logger = MockLogger();
      commandRunner = PatrolCommandRunner(
        logger: logger,
        pubUpdater: pubUpdater,
      );
    });

    test(
      'does not update when already on latest version',
      () async {
        when(() => pubUpdater.getLatestVersion(any()))
            .thenAnswer((_) async => globalVersion);
        //when(() => logger.progress(any())).thenReturn(MockProgress());

        final result = await commandRunner.run(['update']);
        expect(result, equals(0));
        verify(
          () => logger.info(
            'You already have the newest version of patrol_cli ($globalVersion)',
          ),
        ).called(1);

        //verifyNever(() => logger.progress(any()));
        verifyNever(() => pubUpdater.update(packageName: patrolCliPackage));
      },
    );
  });
}
