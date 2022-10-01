import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import '../../config.dart';

void main() {
  patrolTest(
    'disables and enables cellular twice',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.disableCellular();
      await $.native.enableCellular();
      await $.native.disableCellular();
      await $.native.enableCellular();
    },
  );
}
