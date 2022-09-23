import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';

late String mapsId;
late String myAppId;

Future<void> main() async {
  patrolTest(
    'counter state is the same after going to Home and switching apps',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.pressHome();
      await $.native.pressRecentApps();

      await $.native.openApp(appId: 'pl.leancode.patrol.Example');

      await _wait();

      $.log('test end');
    },
  );
}

Future<void> _wait() => Future<void>.delayed(Duration(seconds: 5));
