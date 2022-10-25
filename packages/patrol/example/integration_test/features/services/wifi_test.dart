@Tags(['android', 'ios'])

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../config.dart';

void main() {
  patrolTest(
    'disables and enables wifi twice',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.disableWifi();
      await $.native.enableWifi();
      await $.native.disableWifi();
      await $.native.enableWifi();
    },
  );
}
