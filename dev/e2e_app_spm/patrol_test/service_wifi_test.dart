import 'common.dart';

void main() {
  patrol(
    'disables and enables wifi twice',
    ($) async {
      await createApp($);
      await $.platform.mobile.disableWifi();
      await $.platform.mobile.enableWifi();
      await $.platform.mobile.disableWifi();
      await $.platform.mobile.enableWifi();
    },
    tags: ['android', 'emulator', 'ios', 'physical_device'],
  );
}
