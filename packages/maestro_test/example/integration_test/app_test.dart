import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'taps around',
    ($) async {
      await maestro.openQuickSettings();
      await maestro.tap(const Selector(text: 'Bluetooth'));
      await maestro.tap(const Selector(text: 'Bluetooth'));
      await maestro.pressBack();

      await maestro.openNotifications();

      await maestro.enableWifi();
      await maestro.disableWifi();
      await maestro.enableWifi();

      await maestro.enableCelluar();
      await maestro.disableCelluar();
      await maestro.enableCelluar();

      await maestro.enableDarkMode();
      await maestro.disableDarkMode();
      await maestro.enableDarkMode();

      await maestro.pressBack();
    },
    config: maestroConfig,
  );
}
