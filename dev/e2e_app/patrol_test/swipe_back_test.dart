import 'common.dart';

void main() {
  patrol('performs swipe back gesture ', ($) async {
    await createApp($);

    final openLoadingScreenButton = $(find.text('Open loading screen'));

    await openLoadingScreenButton.scrollTo().tap();

    await $.native.swipeBack(dy: 0.6);

    await openLoadingScreenButton.waitUntilExists();
  });
}
