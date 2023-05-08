import 'dart:io' show Platform;

import 'common.dart';

void main() {
  late String appId;
  if (Platform.isIOS) {
    appId = 'com.apple.Preferences';
  } else if (Platform.isAndroid) {
    appId = 'com.android.settings';
  }

  patrol('scrolls the Settings app', ($) async {
    await createApp($);

    final view = $.tester.view;
    final width = view.physicalSize.width;
    final height = view.physicalSize.height;

    await $.native.openApp(appId: appId);

    final from = Offset((width / 2) / width, (height / 2) / height);
    final to = Offset((width / 2) / width, 100 / height);

    await $.native.swipe(from: from, to: to);
  });
}
