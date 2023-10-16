import '../common.dart';

void main() {
  patrol(
    'taps on notification (permission when in use )',
    ($) async {
      await createApp($);
      await $('Open notifications screen').scrollTo().tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await $('Show in a few seconds').tap();
      await $.native.pressHome();
      await $.native.openNotifications();

      // wait for notification to show up
      await Future<void>.delayed(const Duration(seconds: 5));

      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Someone liked'),
      );

      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
  );

  patrol(
    'taps on notification (permission only this time)',
    ($) async {
      await createApp($);
      await $('Open notifications screen').scrollTo().tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionOnlyThisTime();
      }

      await $('Show in a few seconds').tap();
      await $.native.pressHome();
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
