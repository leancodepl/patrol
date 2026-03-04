import 'common.dart';

void main() {
  patrol('taps around', ($) async {
    await createApp($);

    await $.platform.mobile.pressHome();
    await $.platform.android.pressDoubleRecentApps();

    await $.platform.mobile.openNotifications();

    await $.platform.mobile.enableWifi();
    await $.platform.mobile.disableWifi();
    await $.platform.mobile.enableWifi();

    await $.platform.mobile.enableCellular();
    await $.platform.mobile.disableCellular();
    await $.platform.mobile.enableCellular();

    await $.platform.mobile.enableDarkMode();
    await $.platform.mobile.disableDarkMode();
    await $.platform.mobile.enableDarkMode();

    await $.platform.android.pressBack();
  }, tags: ['physical_device', 'emulator', 'android']);

  patrol('taps around 2', skip: true, ($) async {
    await createApp($);

    await $.platform.mobile.pressHome();
    await $.platform.android.pressDoubleRecentApps();

    await $.platform.mobile.openNotifications();

    await $.platform.mobile.enableWifi();
    await $.platform.mobile.disableWifi();
    await $.platform.mobile.enableWifi();

    await $.platform.mobile.enableCellular();
    await $.platform.mobile.disableCellular();
    await $.platform.mobile.enableCellular();

    await $.platform.mobile.enableDarkMode();
    await $.platform.mobile.disableDarkMode();
    await $.platform.mobile.enableDarkMode();

    await $.platform.android.pressBack();
  }, tags: ['physical_device', 'emulator', 'android']);

  patrol('taps around 3', ($) async {
    await createApp($);

    await $.platform.mobile.pressHome();
    await $.platform.android.pressDoubleRecentApps();
  }, tags: ['physical_device', 'emulator', 'android']);
}
