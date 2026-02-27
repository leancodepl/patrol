import 'dart:io';

import 'common.dart';

void main() {
  patrol(
    'Open external url',
    ($) async {
      await createApp($);

      await $.platform.mobile.openUrl('https://leancode.co');

      try {
        await $.platform.mobile.tap(Selector(text: 'Use without an account'));
      } on PatrolActionException catch (_) {
        // ignore
      }

      try {
        await $.platform.mobile.tap(Selector(text: 'No thanks'));
      } on PatrolActionException catch (_) {
        // ignore
      }

      try {
        await $.platform.mobile.tap(Selector(text: 'ACCEPT ALL COOKIES'));
      } on PatrolActionException catch (_) {
        // ignore
      }

      if (Platform.isIOS) {
        await $.platform.mobile.waitUntilVisible(
          Selector(text: 'Subscribe'),
          appId: 'com.apple.mobilesafari',
        );
      } else {
        await $.platform.mobile.waitUntilVisible(Selector(text: 'Contact us'));
      }
    },
    tags: ['android', 'emulator', 'ios', 'simulator', 'physical_device'],
  );
}
