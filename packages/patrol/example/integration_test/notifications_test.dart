import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  patrolTest(
    'sends a notification and taps on it',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      $.log('Yay, notification_test.dart is starting!');

      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open notifications screen').tap();

      await $.native.grantPermissionWhenInUse();

      await $(RegExp('someone liked')).tap(); // appears on top
      await $(RegExp('special offer')).tap(); // also appears on top

      // wait for pop-up notification to disappear on iOS
      await Future<void>.delayed(Duration(seconds: 10));

      await $.native.openNotifications();
      final notifications = await $.native.getNotifications();
      $.log('Found ${notifications.length} notifications');
      notifications.forEach($.log);

      expect(notifications.length, isNonZero);
      await $.native.tapOnNotificationByIndex(notifications.length - 1);
      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Special offer'),
      );
    },
  );
}
