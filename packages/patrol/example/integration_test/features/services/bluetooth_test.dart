import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import '../../config.dart';

void main() {
  patrolTest(
    'disables and enables bluetooth twice',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
    },
  );
}
