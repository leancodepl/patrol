import 'dart:io' show Platform;

import 'common.dart';

void main() {
  final String appId;
  if (Platform.isIOS) {
    appId = 'com.apple.Preferences';
  } else if (Platform.isAndroid) {
    appId = 'com.android.settings';
  } else {
    throw UnsupportedError('Unsupported platform');
  }

  patrol('scrolls the Settings app', ($) async {
    await createApp($);

    await $.native.openApp(appId: appId);
    await $.native.swipe(
      from: Offset(0.5, 0.8),
      to: Offset(0.5, 0.2),
      appId: appId,
    );
  });
}
