import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables bluetooth twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log(
        'Test will be skipped because of iOS simulator limitations',
      );
    } else {
      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
    }
  });
}
