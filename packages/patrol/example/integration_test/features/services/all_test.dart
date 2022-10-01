import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import '../../config.dart';

void main() {
  patrolTest(
    'disables and enables all services',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await repeat(() async {
        await $.native.disableAirplaneMode();
        await $.native.enableAirplaneMode();
      });

      await repeat(() async {
        await $.native.disableCellular();
        await $.native.enableCellular();
      });

      await repeat(() async {
        await $.native.disableWifi();
        await $.native.enableWifi();
      });

      await repeat(() async {
        await $.native.disableBluetooth();
        await $.native.enableBluetooth();
      });
    },
  );
}

Future<void> repeat(Future<void> Function() callback, {int times = 2}) async {
  for (var i = 0; i < times; i++) {
    await callback();
  }
}
