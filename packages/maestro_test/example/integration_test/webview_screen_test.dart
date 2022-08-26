import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'sends a notification and taps on it',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open webview screen').tap();

      // FIXME: Doesn't work
      final widgets1 = await maestro.getNativeWidgets(
        Selector(text: 'Select items'),
      );
      widgets1.forEach($.log);

      await maestro.tap(Selector(text: 'Select items'));
      await maestro.tap(Selector(text: 'Developer'));
      await maestro.tap(Selector(text: '1 item selected'));

      await maestro.enterText(
        Selector(className: 'android.widget.EditText'),
        text: 'barpac02@gmail.com',
      );
    },
    config: maestroConfig,
  );
}
