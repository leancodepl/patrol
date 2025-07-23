import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables airplane mode twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
      return;
    } else {
      await $.native.disableAirplaneMode();
      await $.native.enableAirplaneMode();
      await $.native.disableAirplaneMode();
      await $.native.enableAirplaneMode();
    }
  }, tags: ['locale_testing_android']);
}
