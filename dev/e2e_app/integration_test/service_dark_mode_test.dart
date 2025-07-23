import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables dark mode twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
    } else {
      await $.native.disableDarkMode();
      await $.native.enableDarkMode();
      await $.native.disableDarkMode();
      await $.native.enableDarkMode();
    }
  }, tags: ['locale_testing_ios']);
}
