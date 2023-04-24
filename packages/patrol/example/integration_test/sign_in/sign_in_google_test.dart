import 'package:flutter/material.dart';

import '../common.dart';

void main() {
  patrol(
    'signs in with Google',
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
}
