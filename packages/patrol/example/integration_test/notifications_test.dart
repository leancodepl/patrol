import 'common.dart';

void main() {
  patrol(
    'taps on notification by selector',
    ($) async {
      await createApp($);
      await $('Open notifications screen').tap();

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

  // Not reliable, because often there are more than our only notification.
  // See also:
  // * https://github.com/leancodepl/patrol/issues/157
  // * https://github.com/leancodepl/patrol/issues/384

  /*
  patrol(
    'taps on notification by index',
    ($) async {
      await createApp($);
      await $('Open notifications screen').tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await $('Show in a few seconds').tap();
      await $.native.pressHome();
      await $.native.openNotifications();

      // wait for notification to show up
      await Future<void>.delayed(const Duration(seconds: 5));

      await $.native.tapOnNotificationByIndex(0);

      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
  );
  */
}
