// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'common.dart';

void main() {
  patrol('performs swipe back gesture ', ($) async {
    await createApp($);

    final openLoadingScreenButton = $(find.text('Open loading screen'));

    await openLoadingScreenButton.scrollTo().tap();

    await $.platform.mobile.swipeBack(dy: 0.6);

    await openLoadingScreenButton.waitUntilExists();
  });
}
