import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';

void main() {
  patrolTest(
    'prints native widgets',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.pressHome();
      await $.native.getNativeWidgets(Selector(textContains: 'a'));
    },
  );
}
