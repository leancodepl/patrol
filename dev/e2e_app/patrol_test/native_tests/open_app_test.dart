// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('open maps', ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native2.openPlatformApp(
      androidAppId: GoogleApp.maps,
      iosAppId: AppleApp.maps,
    );
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });

  patrol('same open maps test that should be skipped', skip: true, ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native2.openPlatformApp(
      androidAppId: GoogleApp.maps,
      iosAppId: AppleApp.maps,
    );
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });

  patrol('open browser', ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    await $.native.pressHome();
    await $.native2.openPlatformApp(
      androidAppId: GoogleApp.chrome,
      iosAppId: AppleApp.safari,
    );
    await $.native.pressHome();
    await $.native.openApp();

    expect($(#counterText).text, '1');
  });
}
