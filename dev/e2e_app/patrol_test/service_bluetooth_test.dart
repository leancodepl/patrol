// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables bluetooth twice', ($) async {
    await createApp($);
    // TODO: will be handled with tags in the future
    if (await $.platform.mobile.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
      return;
    } else {
      await $.platform.mobile.disableBluetooth();
      await $.platform.mobile.enableBluetooth();
      await $.platform.mobile.disableBluetooth();
      await $.platform.mobile.enableBluetooth();
    }
  });
}
