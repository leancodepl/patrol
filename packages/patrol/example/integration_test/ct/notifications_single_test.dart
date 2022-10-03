import 'dart:io' show Platform;

import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';
import 'test_slot.dart';

Future<void> main() async {
  final nativeAutomator = NativeAutomator.forTest(
    useBinding: false,
    packageName: patrolConfig.packageName,
    bundleId: patrolConfig.bundleId,
  );

  await convenientTestMain(MyConvenientTestSlot(), () {
    tTestWidgets(
      'sends 1 notification, verifies that it is visible and taps on it',
      (t) async {
        final $ = PatrolTester(
          tester: t.tester,
          config: patrolConfig,
          nativeAutomator: nativeAutomator,
        );
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
  });
}
