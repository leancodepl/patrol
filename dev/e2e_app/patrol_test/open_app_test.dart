import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('open maps', ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.platform.mobile.pressHome();
    await $.platform.mobile.openPlatformApp(
      androidAppId: GoogleApp.maps,
      iosAppId: AppleApp.maps,
    );
    await $.platform.mobile.pressHome();
    await $.platform.mobile.openApp();

    expect($(#counterText).text, '1');
  }, tags: ['android', 'emulator', 'ios', 'simulator']);

  patrol(
    'same open maps test that should be skipped',
    skip: true,
    ($) async {
      await createApp($);
      await $.waitUntilVisible($(#counterText));

      expect($(#counterText).text, '0');

      await $(FloatingActionButton).tap();

      await $.platform.mobile.pressHome();
      await $.platform.mobile.openPlatformApp(
        androidAppId: GoogleApp.maps,
        iosAppId: AppleApp.maps,
      );
      await $.platform.mobile.pressHome();
      await $.platform.mobile.openApp();

      expect($(#counterText).text, '1');
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );

  patrol('open browser', ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.platform.mobile.pressHome();
    await $.platform.mobile.openPlatformApp(
      androidAppId: GoogleApp.chrome,
      iosAppId: AppleApp.safari,
    );
    await $.platform.mobile.pressHome();
    await $.platform.mobile.openApp();

    expect($(#counterText).text, '1');
  }, tags: ['android', 'emulator', 'ios', 'simulator']);
}
