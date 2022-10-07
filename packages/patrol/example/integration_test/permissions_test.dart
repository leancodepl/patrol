import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  Future<void> requestAndGrantCameraPermission(PatrolTester $) async {
    expect($(#camera).$(#statusText).text, 'Not granted');
    await $('Request camera permission').tap();
    await $.native.grantPermissionWhenInUse();
    await $.pump();
    expect($(#camera).$(#statusText).text, 'Granted');
  }

  Future<void> requestAndGrantMicrophonePermission(PatrolTester $) async {
    expect($(#microphone).$(#statusText).text, 'Not granted');
    await $('Request microphone permission').tap();
    await $.native.grantPermissionWhenInUse();
    await $.pump();
    expect($(#microphone).$(#statusText).text, 'Granted');
  }

  patrolTest(
    'grants various permissions',
    config: patrolConfig,
    nativeAutomation: true,
    binding: Binding.integrationTest,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open permissions screen').scrollTo().tap();

      await requestAndGrantCameraPermission($);
      await requestAndGrantMicrophonePermission($);
    },
  );
}
