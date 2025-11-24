// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  patrol('opens quick settings', ($) async {
    await createApp($);

    await $.platform.mobile.openQuickSettings();
    await $.platform.mobile.pressHome();
  });
}
