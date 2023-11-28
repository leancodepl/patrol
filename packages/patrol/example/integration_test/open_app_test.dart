import 'dart:io' as io;

import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('open maps', ($) async {
    final String mapsId;
    if (io.Platform.isIOS) {
      mapsId = 'com.apple.Maps';
    } else if (io.Platform.isAndroid) {
      mapsId = 'com.google.android.apps.maps';
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native.openApp(appId: mapsId);
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });

  patrol('open browser', ($) async {
    final String browserId;
    if (io.Platform.isIOS) {
      browserId = 'com.apple.mobilesafari';
    } else if (io.Platform.isAndroid) {
      browserId = 'com.android.chrome';
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native.openApp(appId: browserId);
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });
}
