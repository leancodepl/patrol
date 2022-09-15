import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  patrolTest(
    'taps around',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.native.openQuickSettings();
      await $.native.tap(const Selector(text: 'Bluetooth'));
      await $.native.tap(const Selector(text: 'Bluetooth'));
      await $.native.pressBack();

      await $.native.openNotifications();

      await $.native.enableWifi();
      await $.native.disableWifi();
      await $.native.enableWifi();

      await $.native.enableCelluar();
      await $.native.disableCelluar();
      await $.native.enableCelluar();

      await $.native.enableDarkMode();
      await $.native.disableDarkMode();
      await $.native.enableDarkMode();

      await $.native.pressBack();
    },
  );
}
