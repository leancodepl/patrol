import 'dart:io';

import '../common.dart';

void main() {
  patrol(
    'taps on notification',
    ($) async {
      await createApp($);
      await $('Open notifications screen').scrollTo().tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      // Android 14+ requires additional permission to schedule notifications.
      // Workaround for conditionally granting permission.
      final android14PermissionSelector = Selector(
        text: 'Allow setting alarms and reminders',
      );
      final android14PermissionScreen = await $.native.getNativeViews(
        android14PermissionSelector,
      );
      if (android14PermissionScreen.isNotEmpty) {
        await $.native.tap(android14PermissionSelector);
        await $.native.pressBack();
      }

      await $('Show in a few seconds').tap();
      if (!Platform.isMacOS) {
        await $.native.pressHome();
      }
      await $.native.openNotifications();

      // wait for notification to show up
      await Future<void>.delayed(const Duration(seconds: 5));

      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Someone liked'),
      );

      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
  );
}
