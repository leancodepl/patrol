import 'package:example/main.dart';
import 'package:patrol_test/patrol_test.dart';

import 'config.dart';

Future<void> main() async {
  Patrol.forTest();

  patrolTest(
    'does nothing',
    config: patrolConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await Future<void>.delayed(const Duration(minutes: 10));
    },
  );
}
