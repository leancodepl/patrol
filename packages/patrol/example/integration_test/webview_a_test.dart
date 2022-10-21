import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  testWebViewA();
}

void testWebViewA() {
  patrolTest(
    'interacts with the LeanCode website in a webview',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open webview screen A').scrollTo().tap();

      await $.native.tap(Selector(text: 'Accept cookies'));
      await $.native.tap(Selector(text: 'Select items'));
      await $.native.tap(Selector(text: 'Developer'));
      await $.native.tap(Selector(text: '1 item selected'));
      await $.native.enterTextByIndex('test@leancode.pl', index: 0);
    },
  );
}
