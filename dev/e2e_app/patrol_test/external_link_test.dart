import 'dart:io';

import 'common.dart';

void main() {
  patrol('Open external url', ($) async {
    await createApp($);

    await $.native.openUrl('https://leancode.co');

    try {
      await $.native.tap(Selector(text: 'Use without an account'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native.tap(Selector(text: 'Contact us'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native.tap(Selector(text: 'No thanks'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    try {
      await $.native.tap(Selector(text: 'ACCEPT ALL COOKIES'));
    } on PatrolActionException catch (_) {
      // ignore
    }

    if (Platform.isIOS) {
      await $.native.waitUntilVisible(
        Selector(text: 'Subscribe'),
        appId: 'com.apple.mobilesafari',
      );
    } else {
      await $.native.waitUntilVisible(Selector(text: 'Subscribe'));
    }
  });
}
