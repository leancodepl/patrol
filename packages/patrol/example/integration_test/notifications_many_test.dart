@Tags(['android', 'ios'])

import 'dart:io';

import 'common.dart';

void main() {
  patrol(
    'send 2 notifications, verifies that they are visible and taps on them',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open notifications screen').tap();
      await $(RegExp('someone liked')).tap(); // appears on top

      if (await $.native.isPermissionDialogVisible()) {
        print('Dialog is visible');
        await $.native.grantPermissionWhenInUse();
      }

      await $(RegExp('special offer')).tap(); // also appears on top

      if (Platform.isIOS) {
        await $.native.closeHeadsUpNotification();
      }

      await $.native.openNotifications();
      final notifications = await $.native.getNotifications();
      print('Found ${notifications.length} notifications');
      notifications.forEach(print);

      await $.native.tap(
        Selector(
          resourceId: 'android:id/expand_button_number',
        ),
      );

      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Someone liked'),
      );
      await $('Tapped notification with ID: 1').waitUntilVisible();

      await $.native.openNotifications();
      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Special offer'),
      );
      await $('Tapped notification with ID: 2').waitUntilVisible();
    },
  );
}
