import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables cellular twice', ($) async {
    await createApp($);
    if (await $.platform.mobile.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
    } else {
      await $.platform.mobile.disableCellular();
      await $.platform.mobile.enableCellular();
      await $.platform.mobile.disableCellular();
      await $.platform.mobile.enableCellular();
    }
  }, tags: ['android', 'ios', 'physical_device']);
}
