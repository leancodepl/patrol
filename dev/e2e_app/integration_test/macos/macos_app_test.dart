import 'package:flutter/material.dart';

import '../common.dart';

void main() {
  patrol('taps around', ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect($(#counterText).text, '0');

    await $(FloatingActionButton).tap();

    expect($(#counterText).text, '1');

    await $(#textField).enterText('Hello, Flutter!');
    expect($('Hello, Flutter!'), findsOneWidget);

    await $('Open scrolling screen').scrollTo().tap();
    await $.waitUntilVisible($(#topText));

    await $.scrollUntilVisible(finder: $(#bottomText));

    await $.tap($(#backButton));
    await $.scrollUntilVisible(
      finder: $(#counterText),
      scrollDirection: AxisDirection.up,
    );
  });
}
