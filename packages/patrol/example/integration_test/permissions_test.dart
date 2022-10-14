import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  Future<void> requestAndGrantCameraPermission(PatrolTester $) async {
    expect($(#camera).$(#statusText).text, 'Not granted');

    await $('Request camera permission').tap();

    final request = await $.native.isPermissionDialogVisible(
      timeout: Duration(seconds: 2),
    );
    if (request) {
      await $.native.grantPermissionWhenInUse();
    }

    await $.pump();
    expect($(#camera).$(#statusText).text, 'Granted');
  }

  Future<void> requestAndGrantMicrophonePermission(PatrolTester $) async {
    expect($(#microphone).$(#statusText).text, 'Not granted');

    await $('Request microphone permission').tap();

    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    await $.pump();
    expect($(#microphone).$(#statusText).text, 'Granted');
  }

  Future<void> requestAndDenyContactsPermission(PatrolTester $) async {
    expect($(#contacts).$(#statusText).text, 'Not granted');

    await $('Request contacts permission').tap();

    if (await $.native.isPermissionDialogVisible()) {
      await $.native.denyPermission();
    }

    await $.pump();
    expect($(#contacts).$(#statusText).text, 'Not granted');
  }

  patrolTest(
    'grants various permissions',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open permissions screen').scrollTo().tap();

      await requestAndGrantCameraPermission($);
      await requestAndGrantMicrophonePermission($);
      await requestAndDenyContactsPermission($);
    },
  );
}
