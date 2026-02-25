import 'common.dart';

void main() {
  patrol(
    'disables and enables bluetooth twice',
    ($) async {
      await createApp($);

      await $.platform.mobile.disableBluetooth();
      await $.platform.mobile.enableBluetooth();
      await $.platform.mobile.disableBluetooth();
      await $.platform.mobile.enableBluetooth();
    },
    tags: ['android', 'ios', 'physical_device'],
  );
}
