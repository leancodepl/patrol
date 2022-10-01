import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../config.dart';

void main() {
  patrolTest(
    'sends 1 notification, verifies that it is visible and taps on it',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open notifications screen').tap();
      await $.native.grantPermissionWhenInUse();

      await $(RegExp('someone liked')).tap();

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
