import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import '../../config.dart';

void main() {
  patrolTest(
    'disables and enables dark mode twice',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.disableDarkMode();
      await $.native.enableDarkMode();
      await $.native.disableDarkMode();
      await $.native.enableDarkMode();
    },
  );
}
