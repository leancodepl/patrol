import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

Future<void> main() async {
  Maestro.forTest();

  maestroTest(
    'does nothing',
    config: maestroConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await Future<void>.delayed(const Duration(minutes: 10));
    },
  );
}
