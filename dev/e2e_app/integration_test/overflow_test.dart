import 'common.dart';

void main() {
  patrol('opens the overflow screen', ($) async {
    await createApp($);

    await $('Open overflow screen').scrollTo().tap();
  });
}
