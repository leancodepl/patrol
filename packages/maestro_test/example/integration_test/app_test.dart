import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'taps around',
    ($) async {
      await maestro.openQuickSettings();
      await maestro.tap(Selector(text: 'Bluetooth'));
      await maestro.tap(Selector(text: 'Bluetooth'));
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
    appName: 'ExampleApp',
  );
}
