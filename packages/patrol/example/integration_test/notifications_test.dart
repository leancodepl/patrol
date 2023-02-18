import 'common.dart';

void main() {
  patrol(
    'taps on notification',
    ($) async {
      await createApp($);
      await $('Open notifications screen').tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await $('Show in a few seconds').tap();
      // if (Platform.isIOS) {
      //   await $.native.closeHeadsUpNotification();
      // }
      await $.native.pressHome();

      await $.native.openNotifications();
      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Tap to see who'),
      );

      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
  );
}
