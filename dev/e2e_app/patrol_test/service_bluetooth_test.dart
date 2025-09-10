import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables bluetooth twice', ($) async {
    await createApp($);
    // TODO: will be handled with tags in the future
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
      return;
    } else {
      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
      await $.native.disableBluetooth();
      await $.native.enableBluetooth();
    }
  });
}
