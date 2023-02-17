import 'dart:io';

import 'common.dart';

void main() {
  patrol(
    'taps on notification',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open notifications screen').tap();

      if (await $.native.isPermissionDialogVisible()) {
        print('Dialog is visible');
        await $.native.grantPermissionWhenInUse();
      }

      await $(RegExp('someone liked')).tap();

      if (Platform.isIOS) {
        await $.native.closeHeadsUpNotification();
      }

      await $.native.openNotifications();
      final notifications = await $.native.getNotifications();
      print('Found ${notifications.length} notifications');
      notifications.forEach(print);

      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Tap to see who'),
      );
      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
  );
}
