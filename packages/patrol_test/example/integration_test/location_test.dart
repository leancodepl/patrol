import 'package:example/main.dart';
import 'package:patrol_test/patrol_test.dart';

import 'config.dart';

void main() {
  final patrol = Patrol.forTest();

  patrolTest(
    'accepts location permission',
    config: patrolConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open location screen').tap();

      await patrol.selectCoarseLocation();
      await patrol.selectFineLocation();
      await patrol.grantPermissionOnlyThisTime();

      await $.pump();

      expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
      expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
    },
  );
}
