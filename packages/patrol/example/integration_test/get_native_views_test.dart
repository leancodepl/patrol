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
      final view = await $.native.getNativeViews(Selector(text: 'Screen time'));
      expect(view.length, equals(1));

      await $.native.openApp();
    },
  );
}
