@Tags(['android'])

import 'dart:io' show Platform;

import 'common.dart';

Future<void> main() async {
  late String appId;
  if (Platform.isIOS) {
    appId = 'com.apple.Preferences';
  } else if (Platform.isAndroid) {
    appId = 'com.android.settings';
  }

  patrol('scrolls the Settings app', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    final window = $.tester.binding.window;
    final width = window.physicalSize.width;
    final height = window.physicalSize.height;

    await $.native.openApp(appId: appId);

    final from = Offset((width / 2) / width, (height / 2) / height);
    final to = Offset((width / 2) / width, 100 / height);

    await $.native.swipe(from: from, to: to);
  });
}
