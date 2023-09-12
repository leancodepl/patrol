import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('open maps', ($) async {
    late String mapsId;
    if (Platform.isIOS) {
      mapsId = 'com.apple.Maps';
    } else if (Platform.isAndroid) {
      mapsId = 'com.google.android.apps.maps';
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    await createApp($);

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native.openApp(appId: mapsId);
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });

  patrol('open browser', ($) async {
    late String browserId;
    if (Platform.isIOS) {
      browserId = 'com.apple.mobilesafari';
    } else if (Platform.isAndroid) {
      browserId = 'com.android.chrome';
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    await createApp($);

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native.openApp(appId: browserId);
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });
}
