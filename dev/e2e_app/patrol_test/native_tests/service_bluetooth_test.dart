// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  patrol(
    'disables and enables bluetooth twice',
    ($) async {
      await createApp($);

      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
    },
    tags: ['android', 'emulator', 'ios', 'physical_device'],
  );
}
