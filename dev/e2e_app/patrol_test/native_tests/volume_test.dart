// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  patrol('change volume', ($) async {
    await createApp($);

    await $.pumpAndSettle();
    await $.native.pressVolumeUp();
    await $.pumpAndSettle();
    await $.native.pressVolumeDown();
    await $.pumpAndSettle();
    await $.native.pressVolumeUp();
    await $.pumpAndSettle();
  }, tags: ['physical_device', 'android', 'ios']);
}
