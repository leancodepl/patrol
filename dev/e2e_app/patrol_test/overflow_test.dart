// Uncomment to test `Multiple exceptions were thrown` issue
// import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('opens the overflow screen', ($) async {
    await createApp($);

    await $('Open overflow screen').scrollTo().tap();

    return $(ValueKey('key')).scrollTo().tap();
  });
}
