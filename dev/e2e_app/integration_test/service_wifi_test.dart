import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables wifi twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log(
        'Test will be skipped because it of iOS simulator limitations',
      );
    } else {
      await $.native.disableWifi();
      await $.native.enableWifi();
      await $.native.disableWifi();
      await $.native.enableWifi();
    }
  });
}
