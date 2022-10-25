@Tags(['android', 'ios'])

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';

void main() {
  patrolTest(
    'opens quick settings',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.openQuickSettings();
    },
  );
}
