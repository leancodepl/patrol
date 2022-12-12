import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrolTest(
    'counter state is the same after going to Home and switching apps',
    config: patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidget(ExampleApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      print('EXAMPLE APP: TEST END!');
    },
  );
}
