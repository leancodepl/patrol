import 'common.dart';

void main() {
  patrol(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      await createApp($);

      await $('Open scrolling screen').scrollTo().tap();
      await $.waitUntilVisible($(#topText));

      await $('Throw dio exception').tap();

      await $.scrollUntilVisible(finder: $(#bottomText));

      await $.tap($(#backButton));
    },
  );
}
