import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    // '${"alpha" * 30}ABCDE', / 12 + 1 + 150 = 163
    'alpha' * 40,
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
}
