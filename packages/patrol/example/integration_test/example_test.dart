import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'counter state is the same when the app is resumed',
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();

      expect($(#counterText).text, '2');
    },
  );

  patrol(
    'text field state is the same when app is resumed',
    ($) async {
      await createApp($);

      await $(#textField).enterText('Hello, Flutter!');
      expect($('Hello, Flutter!'), findsOneWidget);

      await $.native.pressHome();
      await $.native.openApp();

      expect($('Hello, Flutter!'), findsOneWidget);
    },
  );
}
