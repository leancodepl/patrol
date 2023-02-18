import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'common.dart';

Future<void> main() async {
  late String mapsId;
  if (Platform.isIOS) {
    mapsId = 'com.apple.Maps';
  } else if (Platform.isAndroid) {
    mapsId = 'com.google.android.apps.maps';
  }

  patrol('counter state is the same after switching apps', ($) async {
    await createApp($);

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native.openApp(appId: mapsId);
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });
}
