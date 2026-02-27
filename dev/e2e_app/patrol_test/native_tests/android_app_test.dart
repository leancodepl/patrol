// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  patrol('taps around', ($) async {
    await createApp($);

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
  }, tags: ['android', 'emulator']);

  patrol(
    'taps around 2',
    skip: true,
    ($) async {
      await createApp($);

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
    },
    tags: ['android', 'emulator'],
  );

  patrol('taps around 3', ($) async {
    await createApp($);

    await $.native.pressHome();
    await $.native.pressDoubleRecentApps();
  }, tags: ['android', 'emulator']);
}
