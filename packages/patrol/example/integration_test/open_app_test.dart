import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  late String mapsId;
  if (Platform.isIOS) {
    mapsId = 'com.apple.Maps';
  } else if (Platform.isAndroid) {
    mapsId = 'com.google.android.apps.maps';
  } else if (Platform.isMacOS) {
    mapsId = 'com.apple.Maps';
  }

  patrol('counter state is the same after switching apps', ($) async {
    await createApp($);

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    if (Platform.isMacOS) {
      await $.native.openApp(appId: mapsId);
    } else {
      await $.native.pressHome();
      await $.native.openApp(appId: mapsId);
      await $.native.pressHome();
      await $.native.openApp();
    }

    expect($(#counterText).text, '1');
  });
}
