import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrolSetUp(() {
    // Smoke test for https://github.com/leancodepl/patrol/issues/2021
    expect(2 + 2, equals(4));
  });

  patrol(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $(#textField).enterText('Hello, Flutter!');
      expect($('Hello, Flutter!'), findsOneWidget);

      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();

      expect($(#counterText).text, '2');
      expect($('Hello, Flutter!'), findsOneWidget);
    },
  );

  patrol(
    'short test with two tags',
    tags: ['smoke', 'fume'],
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');
    },
  );

  patrol(
    'short test with tag',
    tags: ['smoke'],
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $(#textField).enterText('Hello, Flutter!');
      expect($('Hello, Flutter!'), findsOneWidget);
    },
  );
}
