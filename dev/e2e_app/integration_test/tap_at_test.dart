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

  patrol('taps at the middle of the screen in the Settings app', ($) async {
    await createApp($);

    await $.native.openApp(appId: appId);
    // Native view with the text "Bluetooth" is universally present in the settings app
    await $.native.waitUntilVisible(Selector(textContains: 'Bluetooth'));
    await $.native.tapAt(
      Offset(0.5, 0.5),
      appId: appId,
    );
  });
}
