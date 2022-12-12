@Tags(['android', 'ios'])

import 'dart:io';

import '../../common.dart';

void main() {
  patrol(
    'sends 1 notification, verifies that it is visible and taps on it',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open notifications screen').tap();
      await $(RegExp('someone liked')).tap();

      if (await $.native.isPermissionDialogVisible()) {
        print('Dialog is visible');
        await $.native.grantPermissionWhenInUse();
      }

      if (Platform.isIOS) {
        await $.native.closeHeadsUpNotification();
      }

      await $.native.openNotifications();
      final notifications = await $.native.getNotifications();
      $.log('Found ${notifications.length} notifications');
      notifications.forEach($.log);

      expect(notifications.length, equals(1));
      await $.native.tapOnNotificationByIndex(0);
    },
  );
}
