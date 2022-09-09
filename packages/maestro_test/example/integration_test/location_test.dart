import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'accepts location permission',
    config: maestroConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open location screen').tap();

      await maestro.selectCoarseLocation();
      await maestro.selectFineLocation();
      await maestro.grantPermissionOnlyThisTime();

      await $.pump();

      expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
      expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
    },
  );
}
