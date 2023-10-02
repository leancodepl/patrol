import 'package:flutter/material.dart';

import '../common.dart';

String _generateString(int length) {
  return 'a' * length;
}

void main() {
  patrol(
    // way too long for ATO because of https://github.com/android/android-test/issues/1935
    _generateString(200),
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
    '${"alpha" * 36}A', // 194 - max allowed value
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');
    },
  );

  patrol(
    '${"kocyk" * 36}AA', // 195 - 1 too many
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');
    },
  );
}
