import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.native.pressHome();
      await $.native.pressDoubleRecentApps();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');
    },
  );
}
