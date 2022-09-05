import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'counter state is the same after going to Home and switching apps',
    config: maestroConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await maestro.pressHome();
      await maestro.pressDoubleRecentApps();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      await maestro.openNotifications();
      await maestro.pressBack();
    },
  );
}
