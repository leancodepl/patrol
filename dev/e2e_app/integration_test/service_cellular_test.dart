import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables cellular twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log(
        'Test will be skipped because of iOS simulator limitations',
      );
    } else {
      await $.native.disableCellular();
      await $.native.enableCellular();
      await $.native.disableCellular();
      await $.native.enableCellular();
    }
  });
}
