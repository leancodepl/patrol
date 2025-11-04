import 'dart:io' as io;

import 'package:e2e_app/keys.dart';

import '../common.dart';

void main() {
  patrol('taps on notification', ($) async {
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

    await $(K.showNotificationLaterButton).tap();
    await $.native.pressHome();
    await $.native.openNotifications();

    // wait for notification to show up
    await Future<void>.delayed(const Duration(seconds: 5));

    await $.native.tapOnNotificationBySelector(
      Selector(textContains: 'Someone liked'),
    );

    await $('Tapped notification with ID: 1').waitUntilVisible();
  });

  patrol(
    'taps on notification native2',
    ($) async {
      await createApp($);
      await $('Open notifications screen').scrollTo().tap();

      if (await $.native2.isPermissionDialogVisible()) {
        await $.native2.grantPermissionWhenInUse();
      }

      // Until we resolve the issue of invoking native methods without a
      // selector intended for the platform on which we are running the test,
      // we need to add this check.
      if (io.Platform.isAndroid) {
        // Android 14+ requires additional permission to schedule notifications.
        // Workaround for conditionally granting permission.
        final android14PermissionSelector = AndroidSelector(
          text: 'Allow setting alarms and reminders',
        );
        final nativeViews = await $.native2.getNativeViews(
          NativeSelector(android: android14PermissionSelector),
        );
        if (nativeViews.androidViews.isNotEmpty) {
          await $.native2.tap(
            NativeSelector(android: android14PermissionSelector),
          );
          await $.native2.pressBack();
        }
      }

      await $(K.showNotificationLaterButton).tap();
      await $.native2.pressHome();
      await $.native2.openNotifications();

      // wait for notification to show up
      await Future<void>.delayed(const Duration(seconds: 5));

      await $.native2.tapOnNotificationBySelector(
        NativeSelector(
          android: AndroidSelector(textContains: 'Someone liked'),
          ios: IOSSelector(titleContains: 'Someone liked'),
        ),
      );

      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
    // Uncomment after fix https://github.com/leancodepl/patrol/issues/2703
    // tags: ['locale_testing_ios'],
  );
}
