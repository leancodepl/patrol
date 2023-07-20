import 'dart:io' as io;

import 'common.dart';

void main() {
  late String settingsAppId;
  if (io.Platform.isIOS) {
    settingsAppId = 'com.apple.Preferences';
  } else if (io.Platform.isAndroid) {
    // settingsAppId = 'com.google.android.apps.maps';
  }

  patrol(
    'get_native_views_test',
    ($) async {
      await createApp($);

      await $.native.pressHome();
      await $.native.openApp(appId: settingsAppId);

      // assert that a few texts are visible
      final views1 = await $.native.getNativeViews(
        Selector(text: 'Screen Time'),
        appId: settingsAppId,
      );
      print('Found views matching "Screen Time": ${views1.length}');

      expect(views1.length, equals(2));

      final views2 = await $.native.getNativeViews(
        Selector(text: 'General'),
        appId: settingsAppId,
      );
      print('Found views matching "General": ${views2.length}');
      expect(views2.length, equals(2));

      await $.native.openApp();
    },
  );
}
