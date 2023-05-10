import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('disables and enables dark mode twice', ($) async {
    await createApp($);

    await $.native.disableDarkMode();
    await $.native.enableDarkMode();
    await $.native.disableDarkMode();
    await $.native.enableDarkMode();
    await $(FloatingActionButton).tap();
    await $(CircleAvatar).tap();
  });
}
