// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'common.dart';

void main() {
  patrol('disables and enables cellular twice', ($) async {
    await createApp($);
    if (await $.native.isVirtualDevice() && Platform.isIOS) {
      $.log('Test will be skipped because of iOS simulator limitations');
    } else {
      await $.native.disableCellular();
      await $.native.enableCellular();
      await $.native.disableCellular();
      await $.native.enableCellular();
    }
  }, tags: ['android', 'emulator', 'physical_device']);
}
