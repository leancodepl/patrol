@Tags(['android'])

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  patrolTest(
    'takes a screenshot',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());
      await $.native.takeScreenshot();
      await $.native.takeScreenshot('another-screenshot.png');
    },
  );
}
