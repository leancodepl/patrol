import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  patrolTest(
    'fails',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.tap(Selector(text: 'xdxd'));
      await $.native.openApp(appId: 'lol`');
      await $.native.grantPermissionOnlyThisTime();
    },
  );
}
