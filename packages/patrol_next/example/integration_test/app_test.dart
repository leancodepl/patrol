import 'common.dart';

void main() {
  patrol('taps around', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $.native.pressHome();
    await $.native.pressDoubleRecentApps();

    await $.native.openNotifications();

    await $.native.enableWifi();
    await $.native.disableWifi();
    await $.native.enableWifi();

    await $.native.enableCellular();
    await $.native.disableCellular();
    await $.native.enableCellular();

    await $.native.enableDarkMode();
    await $.native.disableDarkMode();
    await $.native.enableDarkMode();

    await $.native.pressBack();
  });
}
