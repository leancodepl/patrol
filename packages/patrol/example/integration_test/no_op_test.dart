import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  final patrol = Patrol.forTest();

  patrolTest(
    'does nothing',
    config: patrolConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await patrol.pressHome();
      await patrol.pressDoubleRecentApps();

      await patrol.tap(const Selector(text: 'Some strange button'));

      await Future<void>.delayed(const Duration(minutes: 10));
    },
  );
}
