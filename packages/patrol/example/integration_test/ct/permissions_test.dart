import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:example/main.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';
import 'test_slot.dart';

void main() {
  final patrol = Patrol.forTest(useBinding: false);

  Future<void> requestAndGrantCameraPermission(PatrolTester $) async {
    expect($(#camera).$(#statusText).text, 'Not granted');
    await $('Request camera permission').tap();
    await patrol.grantPermissionWhenInUse();
    await $.pump();
    expect($(#camera).$(#statusText).text, 'Granted');
  }

  Future<void> requestAndGrantMicrophonePermission(PatrolTester $) async {
    expect($(#microphone).$(#statusText).text, 'Not granted');
    await $('Request microphone permission').tap();
    await patrol.grantPermissionWhenInUse();
    await $.pump();
    expect($(#microphone).$(#statusText).text, 'Granted');
  }

  convenientTestMain(MyConvenientTestSlot(), () {
    tTestWidgets(
      'grants various permissions (convenient_test)',
      (t) async {
        final $ = PatrolTester(tester: t.tester, config: patrolConfig);
        await $.pumpWidgetAndSettle(const ExampleApp());

        await $('Open permissions screen').scrollTo().tap();

        await requestAndGrantCameraPermission($);
        await requestAndGrantMicrophonePermission($);
      },
    );
  });
}
