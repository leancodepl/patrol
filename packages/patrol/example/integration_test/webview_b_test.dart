import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  patrolTest(
    'interacts with the orange website in a webview',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open webview screen B').scrollTo().tap();

      await $.native.tap(Selector(text: 'login'));
      await $.native.enterTextByIndex('test@leancode.pl', index: 0);
      await $.native.enterTextByIndex('ny4ncat', index: 1);
    },
  );
}
