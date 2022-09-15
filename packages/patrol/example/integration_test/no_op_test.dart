import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  patrolTest(
    'does nothing',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $.native.pressHome();
      await $.native.pressDoubleRecentApps();

      await $.native.tap(const Selector(text: 'Some strange button'));

      await Future<void>.delayed(const Duration(minutes: 10));
    },
  );
}
