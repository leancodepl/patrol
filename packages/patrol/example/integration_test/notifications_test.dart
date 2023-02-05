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

  patrol(
    'opens and closes notification shade',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.openNotifications();
      await $.native.closeNotifications();

      await $.native.openNotifications();
      await $.native.closeNotifications();
    },
  );

  patrol(
    'exits the app and enters it again',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $.native.pressHome();
      await $.native.openApp(appId: 'com.apple.Preferences');
      await $.native.pressHome();
    },
  );

  // Disabled because the first notification is often about Android device setup
  // patrol(
  //   'sends a notification, verifies that it is visible and taps on it by index',
  //   ($) async {
  //     await $.pumpWidgetAndSettle(ExampleApp());

  //     await $('Open notifications screen').tap();
  //     await $(RegExp('someone liked')).tap();

  //     if (await $.native.isPermissionDialogVisible()) {
  //       print('Dialog is visible');
  //       await $.native.grantPermissionWhenInUse();
  //     }

  //     if (Platform.isIOS) {
  //       await $.native.closeHeadsUpNotification();
  //     }

  //     await $.native.openNotifications();
  //     final notifications = await $.native.getNotifications();
  //     print('Found ${notifications.length} notifications');
  //     notifications.forEach(print);

  //     await $.native.tapOnNotificationByIndex(0);
  //     await $('Tapped notification with ID: 1').waitUntilVisible();
  //   },
  // );
}
