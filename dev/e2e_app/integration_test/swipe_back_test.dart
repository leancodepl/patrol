import 'common.dart';

void main() {
  patrol(
    'performs swipe back gesture ',
    ($) async {
      await createApp($);

      await $(find.text('Open loading screen')).scrollTo().tap();

      await $.native.swipeBack(height: 0.2);
    },
  );
}
