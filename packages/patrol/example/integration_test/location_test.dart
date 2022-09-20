import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  patrolTest(
    'accepts location permission',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open location screen').tap();

      await $.native.selectCoarseLocation();
      await $.native.selectFineLocation();
      await $.native.grantPermissionOnlyThisTime();

      await $.pump();

      expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
      expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
    },
  );
}
