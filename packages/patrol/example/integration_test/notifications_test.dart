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
      await $.native.pressHome();
      await $.native.openNotifications();

      // wait for notification to show up
      await Future<void>.delayed(const Duration(seconds: 7));

      final views = await $.native.getNativeViews(
        Selector(textContains: 'Someone liked'),
      );
      for (var i = 0; i < views.length; i++) {
        print('Found view $i: ${views[i]}');
      }

      await $.native.tapOnNotificationBySelector(
        Selector(textContains: 'Someone liked'),
      );

      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
  );
}
