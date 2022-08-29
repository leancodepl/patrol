import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

Future<void> main() async {
  Maestro.forTest();

  maestroTest(
    'wait',
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      final testBinding = $.tester.binding;
      testBinding.window.platformDispatcher.semanticsEnabledTestValue = true;

      await Future<void>.delayed(const Duration(minutes: 10));
    },
    config: maestroConfig,
  );
}
