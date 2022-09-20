import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';
import 'test_slot.dart';

Future<void> main() async {
  final nativeAutomator = NativeAutomator.forTest(useBinding: false);

  Future<void> requestAndGrantCameraPermission(PatrolTester $) async {
    expect($(#camera).$(#statusText).text, 'Not granted');
    await $('Request camera permission').tap();
    await nativeAutomator.grantPermissionWhenInUse();
    await $.pump();
    expect($(#camera).$(#statusText).text, 'Granted');
  }

  Future<void> requestAndGrantMicrophonePermission(PatrolTester $) async {
    expect($(#microphone).$(#statusText).text, 'Not granted');
    await $('Request microphone permission').tap();
    await nativeAutomator.grantPermissionWhenInUse();
    await $.pump();
    expect($(#microphone).$(#statusText).text, 'Granted');
  }

  await convenientTestMain(MyConvenientTestSlot(), () {
    tTestWidgets(
      'grants various permissions (convenient_test)',
      (t) async {
        final $ = PatrolTester(
          tester: t.tester,
          nativeAutomator: nativeAutomator,
          config: patrolConfig,
        );
        await $.pumpWidgetAndSettle(const ExampleApp());

        await $('Open permissions screen').scrollTo().tap();

        await requestAndGrantCameraPermission($);
        await requestAndGrantMicrophonePermission($);
      },
    );
  });
}
