// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'dart:io' as io;

import 'package:e2e_app/keys.dart';

import '../common.dart';

void main() {
  patrol('taps on notification', ($) async {
    await createApp($);
    await $('Open notifications screen').scrollTo().tap();

    if (await $.platform.mobile.isPermissionDialogVisible()) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    // Android 14+ requires additional permission to schedule notifications.
    // Workaround for conditionally granting permission.
    final android14PermissionSelector = Selector(
      text: 'Allow setting alarms and reminders',
    );
    final android14PermissionScreen = await $.platform.action.mobile(
      android: () async => (await $.platform.android.getNativeViews(
        android14PermissionSelector.android,
      )).roots.map(NativeView.fromAndroid).toList(),
      ios: () async => (await $.platform.ios.getNativeViews(
        android14PermissionSelector.ios,
      )).roots.map(NativeView.fromIOS).toList(),
    );
    if (android14PermissionScreen.isNotEmpty) {
      await $.platform.mobile.tap(android14PermissionSelector);
      await $.platform.android.pressBack();
    }

    await $(K.showNotificationLaterButton).tap();
    await $.platform.mobile.pressHome();
    await $.platform.mobile.openNotifications();

    // wait for notification to show up
    await Future<void>.delayed(const Duration(seconds: 5));

    await $.platform.mobile.tapOnNotificationBySelector(
      Selector(textContains: 'Someone liked'),
    );

    await $('Tapped notification with ID: 1').waitUntilVisible();
  });

  patrol(
    'taps on notification native2',
    ($) async {
      await createApp($);
      await $('Open notifications screen').scrollTo().tap();

      if (await $.platform.mobile.isPermissionDialogVisible()) {
        await $.platform.mobile.grantPermissionWhenInUse();
      }

      // Until we resolve the issue of invoking native methods without a
      // selector intended for the platform on which we are running the test,
      // we need to add this check.
      if (io.Platform.isAndroid) {
        // Android 14+ requires additional permission to schedule notifications.
        // Workaround for conditionally granting permission.
        final android14PermissionSelector = Selector(
          text: 'Allow setting alarms and reminders',
        );
        final nativeViews = await $.platform.action.mobile(
          android: () async => (await $.platform.android.getNativeViews(
            android14PermissionSelector.android,
          )).roots.map(NativeView.fromAndroid).toList(),
          ios: () async => <NativeView>[],
        );
        if (nativeViews.isNotEmpty) {
          await $.platform.mobile.tap(android14PermissionSelector);
          await $.platform.android.pressBack();
        }
      }

      await $(K.showNotificationLaterButton).tap();
      await $.platform.mobile.pressHome();
      await $.platform.mobile.openNotifications();

      // wait for notification to show up
      await Future<void>.delayed(const Duration(seconds: 5));

      await $.platform.action.mobile(
        android: () => $.platform.android.tapOnNotificationBySelector(
          AndroidSelector(textContains: 'Someone liked'),
        ),
        ios: () => $.platform.ios.tapOnNotificationBySelector(
          IOSSelector(titleContains: 'Someone liked'),
        ),
      );

      await $('Tapped notification with ID: 1').waitUntilVisible();
    },
    // Uncomment after fix https://github.com/leancodepl/patrol/issues/2703
    // tags: ['locale_testing_ios'],
  );
}
