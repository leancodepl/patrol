import 'common.dart';

void main() {
  patrol('disables and enables airplane mode twice', ($) async {
    await createApp($);

    await $.native.disableAirplaneMode();
    await $.native.enableAirplaneMode();
    await $.native.disableAirplaneMode();
    await $.native.enableAirplaneMode();
  });

  patrol('disables and enables wifi twice', ($) async {
    await createApp($);

    await $.native.disableWifi();
    await $.native.enableWifi();
    await $.native.disableWifi();
    await $.native.enableWifi();
  });

  patrol('disables and enables dark mode twice', ($) async {
    await createApp($);

    await $.native.disableDarkMode();
    await $.native.enableDarkMode();
    await $.native.disableDarkMode();
    await $.native.enableDarkMode();
  });

  patrol('disables and enables cellular twice', ($) async {
    await createApp($);

    await $.native.disableCellular();
    await $.native.enableCellular();
    await $.native.disableCellular();
    await $.native.enableCellular();
  });

  patrol('disables and enables bluetooth twice', ($) async {
    await createApp($);

    await $.native.disableBluetooth();
    await $.native.enableBluetooth();
    await $.native.disableBluetooth();
    await $.native.enableBluetooth();
  });
}
