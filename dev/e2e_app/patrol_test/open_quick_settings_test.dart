import 'common.dart';

void main() {
  patrol(
    'opens quick settings',
    ($) async {
      await createApp($);

      await $.platform.mobile.openQuickSettings();
      await $.platform.mobile.pressHome();
    },
    tags: ['android', 'emulator', 'ios', 'simulator', 'physical_device'],
  );
}
