import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables wifi twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log(
        'The test will be skipped due to the limitations of the iOS simulator.',
      );
    } else {
      await $.native.disableWifi();
      await $.native.enableWifi();
      await $.native.disableWifi();
      await $.native.enableWifi();
    }
  });
}
