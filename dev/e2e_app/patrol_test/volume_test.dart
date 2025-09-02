import 'dart:io' as io;

import 'common.dart';

void main() {
  patrol('change volume', ($) async {
    await createApp($);

    if (io.Platform.isAndroid) {
      await $.pumpAndSettle();
      await $.native.pressVolumeUp();
      await $.pumpAndSettle();
      await $.native.pressVolumeDown();
      await $.pumpAndSettle();
      await $.native.pressVolumeUp();
      await $.pumpAndSettle();
    }
  });
}
