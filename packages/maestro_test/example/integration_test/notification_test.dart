import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'sends a notification and taps on it',
    ($) async {
      $.log('WHERE IS MY PRINT?!');

      await $.pumpWidgetAndSettle(MyApp());

      await $('Open notifications screen').tap();

      await $(RegExp('.*ID=1')).tap(); // appears on top
      await $(RegExp('.*ID=2')).tap(); // also appears on top

      (await maestro.getNotifications()).forEach($.log);

      await maestro.tapOnNotificationByIndex(1);
      await maestro.tapOnNotificationBySelector(Selector(textContains: 'ID=2'));
      // await maestro.tapOnNotificationBySelector(Selector(textContains: 'ID=2'));
    },
    appName: 'AspeCTS',
    sleep: Duration(seconds: 5),
  );
}
