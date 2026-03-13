// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'package:e2e_app/keys.dart';

import 'common.dart';

void main() {
  patrol(
    'performs pull to refresh gesture (native)',
    ($) async {
      await createApp($);
      await $('Open scrolling screen').scrollTo().tap();
      expect($(K.refreshText), findsNothing);
      await $.native.pullToRefresh();
      await $(K.refreshText).waitUntilVisible();
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
  patrol(
    'performs pull to refresh gesture (native2)',
    ($) async {
      await createApp($);
      await $('Open scrolling screen').scrollTo().tap();
      expect($(K.refreshText), findsNothing);
      await $.native2.pullToRefresh();
      await $(K.refreshText).waitUntilVisible();
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
