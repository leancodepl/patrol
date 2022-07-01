import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';


void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'sends a notification and taps on it',
    ($) async {
      await $.pumpWidgetAndSettle(const MyApp());

      await $('Open notifications screen').tap();

      await $(RegExp('.*ID=1')).tap(); // appears on top
      await $(RegExp('.*ID=2')).tap(); // also appears on top

      (await maestro.getNotifications()).forEach(print);

      await maestro.tapOnNotification(index: 1);

      await maestro.openHalfNotificationShade();
      await maestro.tap(const Selector(textContains: 'ID=2'));
    },
  );
}
