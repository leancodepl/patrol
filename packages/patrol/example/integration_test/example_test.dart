import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      print('DEBUG_PATROL: Will call native methods');
      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');
    },
  );
}
