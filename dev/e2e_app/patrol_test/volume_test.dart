import 'dart:io' as io;

import 'common.dart';

void main() {
  patrol('change volume', ($) async {
    await createApp($);

    if (io.Platform.isAndroid) {
      await $.pumpAndSettle();
      await $.platform.mobile.pressVolumeUp();
      await $.pumpAndSettle();
      await $.platform.mobile.pressVolumeDown();
      await $.pumpAndSettle();
      await $.platform.mobile.pressVolumeUp();
      await $.pumpAndSettle();
    }
  });
}
