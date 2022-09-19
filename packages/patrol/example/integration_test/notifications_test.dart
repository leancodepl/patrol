import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  patrolTest(
    'sends a notification and taps on it',
    config: patrolConfig,
    ($) async {
      $.log('Yay, notification_test.dart is starting!');

      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open notifications screen').tap();

      await $(RegExp('someone liked')).tap(); // appears on top
      await $(RegExp('special offer')).tap(); // also appears on top

      (await $.native.getNotifications()).forEach($.log);

      await $.native.tapOnNotificationByIndex(1);
      await $.native.tapOnNotificationBySelector(
        const Selector(textContains: 'special offer'),
      );
    },
  );
}
