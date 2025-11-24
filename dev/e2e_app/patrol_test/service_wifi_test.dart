// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables wifi twice', ($) async {
    await createApp($);
    if (await $.platform.mobile.isVirtualDevice() && Platform.isIOS) {
      $.log(
        'The test will be skipped due to the limitations of the iOS simulator.',
      );
    } else {
      await $.platform.mobile.disableWifi();
      await $.platform.mobile.enableWifi();
      await $.platform.mobile.disableWifi();
      await $.platform.mobile.enableWifi();
    }
  });
}
