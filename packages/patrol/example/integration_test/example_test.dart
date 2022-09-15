import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  final patrol = NativeAutomator.forTest();

  patrolTest(
    'counter state is the same after going to Home and switching apps',
    config: patrolConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await patrol.pressHome();
      await patrol.pressDoubleRecentApps();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      await patrol.openNotifications();
      await patrol.pressBack();
    },
  );
}
