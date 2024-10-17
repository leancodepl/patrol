// Uncomment to test `Multiple exceptions were thrown` issue
// import 'package:flutter/widgets.dart';

import 'common.dart';

void main() {
  patrol('opens the overflow screen', ($) async {
    await createApp($);

    await $('Open overflow screen').scrollTo().tap();

    // Uncomment to test `Multiple exceptions were thrown` issue
    // return $(ValueKey('key')).scrollTo().tap();
  });
}
