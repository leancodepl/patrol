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

    Matcher unsupported(String message) => throwsA(
      isA<UnsupportedError>().having(
        (e) => e.message,
        'message',
        '$message Patrol supports only Dart-side (Flutter) interactions on '
            'Linux.',
      ),
    );

    // An Android and iOS action (PlatformAction.mobile).
    await expectLater(
      () => $.platform.mobile.pressHome(),
      unsupported(
        'This action is supported only on Android and iOS, not on Linux.',
      ),
    );
    // A cross-platform action without a Linux branch (PlatformAction.safe).
    await expectLater(
      () => $.platform.tap(Selector(text: 'Add')),
      unsupported('This action is not supported on Linux.'),
    );
    // An action for one platform only (PlatformAction.call).
    expect(
      () => $.platform.action(android: () {}),
      unsupported('This action is not supported on Linux.'),
    );
  }, tags: ['linux']);

  patrol('skipped on Linux', skip: true, ($) async {
    await createApp($);
    await $.waitUntilVisible($(#counterText));
  }, tags: ['linux']);
}
