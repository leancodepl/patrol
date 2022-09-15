import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  final patrol = NativeAutomator.forTest();

  patrolTest(
    'sends a notification and taps on it',
    config: patrolConfig,
    ($) async {
      $.log('Yay, notification_test.dart is starting!');

      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open notifications screen').tap();

      await $(RegExp('someone liked')).tap(); // appears on top
      await $(RegExp('special offer')).tap(); // also appears on top

      (await patrol.getNotifications()).forEach($.log);

      await patrol.tapOnNotificationByIndex(1);
      await patrol.tapOnNotificationBySelector(
        const Selector(textContains: 'special offer'),
      );
    },
  );
}
