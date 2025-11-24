// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables airplane mode twice', ($) async {
    await createApp($);
    if (await $.platform.mobile.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
      return;
    } else {
      await $.platform.mobile.disableAirplaneMode();
      await $.platform.mobile.enableAirplaneMode();
      await $.platform.mobile.disableAirplaneMode();
      await $.platform.mobile.enableAirplaneMode();
    }
  }, tags: ['locale_testing_android']);
}
