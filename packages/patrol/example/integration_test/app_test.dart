import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  final patrol = Patrol.forTest();

  patrolTest(
    'taps around',
    config: patrolConfig,
    ($) async {
      await patrol.openQuickSettings();
      await patrol.tap(const Selector(text: 'Bluetooth'));
      await patrol.tap(const Selector(text: 'Bluetooth'));
      await patrol.pressBack();

      await patrol.openNotifications();

      await patrol.enableWifi();
      await patrol.disableWifi();
      await patrol.enableWifi();

      await patrol.enableCelluar();
      await patrol.disableCelluar();
      await patrol.enableCelluar();

      await patrol.enableDarkMode();
      await patrol.disableDarkMode();
      await patrol.enableDarkMode();

      await patrol.pressBack();
    },
  );
}
