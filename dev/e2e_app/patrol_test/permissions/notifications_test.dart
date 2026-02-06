import 'dart:io' as io;

import 'package:e2e_app/keys.dart';

import '../common.dart';

void main() {
  patrol('taps on notification by text contains', ($) async {
    await createApp($);
    await $('Open notifications screen').scrollTo().tap();

    if (await $.platform.mobile.isPermissionDialogVisible()) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    await handleAndroid14NotificationPermission($);

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

  patrol('taps on notification by text', ($) async {
    await createApp($);
    await $('Open notifications screen').scrollTo().tap();

    if (await $.platform.mobile.isPermissionDialogVisible()) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }
    await handleAndroid14NotificationPermission($);
    await $(K.showNotificationNowButton).tap();
    if (io.Platform.isIOS) {
      await $.platform.ios.closeHeadsUpNotification();
    }
    await $.platform.mobile.openNotifications();
    await $.platform.mobile.tapOnNotificationBySelector(
      Selector(text: 'Someone liked your recent post'),
    );
    await $('Tapped notification with ID: 1').waitUntilVisible();
  });

  patrol('taps on notification by index', ($) async {
    await createApp($);
    await $('Open notifications screen').scrollTo().tap();

    if (await $.platform.mobile.isPermissionDialogVisible()) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }
    await handleAndroid14NotificationPermission($);
    await $(K.showNotificationNowButton).tap();
    if (io.Platform.isIOS) {
      await $.platform.ios.closeHeadsUpNotification();
    }
    await $.platform.mobile.openNotifications();
    await $.platform.mobile.tapOnNotificationByIndex(0);
    await $('Tapped notification with ID: 1').waitUntilVisible();
  });

  // Regression test: on iOS 18+, the notification list includes a header element
  // that should be filtered out by getNotifications() to match tapOnNotificationByIndex()
  patrol('getNotifications returns only real notifications', ($) async {
    await createApp($);
    await $('Open notifications screen').scrollTo().tap();

    if (await $.platform.mobile.isPermissionDialogVisible()) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }
    await handleAndroid14NotificationPermission($);
    await $(K.showNotificationNowButton).tap();
    if (io.Platform.isIOS) {
      await $.platform.ios.closeHeadsUpNotification();
    }
    await $.platform.mobile.openNotifications();

    final notifications = await $.platform.mobile.getNotifications();
    expect(notifications.length, equals(1));
    expect(notifications[0].raw, contains('Someone liked'));

    await $.platform.mobile.tapOnNotificationByIndex(0);
    await $('Tapped notification with ID: 1').waitUntilVisible();
  });
}

/// Android 14+ requires additional permission to schedule notifications.
/// This function handles the workaround for conditionally granting permission.
Future<void> handleAndroid14NotificationPermission(
  PatrolIntegrationTester $,
) async {
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
}
