import 'package:e2e_app/keys.dart';

import 'common.dart';

void main() {
  patrol(
    'at() waits until widget at index exists',
    ($) async {
      await createApp($);
      await $(K.atFinderScreenButton).scrollTo().tap();

      await $(K.atFinderItem).at(1).tap();
      await $(K.atFinderItem).first.tap();
      await $(K.atFinderItem).last.tap();

      await $(K.atFinderFirstItemTapped).waitUntilVisible();
      await $(K.atFinderSecondItemTapped).waitUntilVisible();
      expect($(K.atFinderSecondItemTapped).text, 'Second item tapped 2');
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
