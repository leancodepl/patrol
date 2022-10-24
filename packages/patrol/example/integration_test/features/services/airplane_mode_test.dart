@Tags(['ios'])

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../config.dart';

void main() {
  patrolTest(
    'disables and enables airplane mode twice',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.disableAirplaneMode();
      await $.native.enableAirplaneMode();
      await $.native.disableAirplaneMode();
      await $.native.enableAirplaneMode();
    },
  );
}
