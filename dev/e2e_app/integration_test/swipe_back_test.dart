import 'common.dart';

void main() {
  patrol(
    'performs swipe back gesture ',
    ($) async {
      await createApp($);

      final openLoadingScreenButton = $(find.text('Open loading screen'));

      await openLoadingScreenButton.scrollTo().tap();

      await $.native.swipeBack(height: 0.2);

      await openLoadingScreenButton.waitUntilExists();
    },
  );
}
