import 'dart:io';

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
  }, tags: ['linux']);

  patrol('native actions throw on Linux', ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));

    expect(Platform.isLinux, isTrue);
    await expectLater(
      () => $.platform.mobile.pressHome(),
      throwsA(isA<UnsupportedError>()),
    );
  }, tags: ['linux']);

  patrol('skipped on Linux', skip: true, ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));
  }, tags: ['linux']);
}
