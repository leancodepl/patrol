import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // PatrolBinding.ensureInitialized();

  group('3 unrelated tests', () {
    // do common setup here

    patrolTest(
      'counter state is the same after going to Home and switching apps',
      config: patrolConfig,
      nativeAutomation: true,
      binding: Binding.integrationTest,
      ($) async {
        await $.native.openApp();
        await $.pumpWidgetAndSettle(ExampleApp());

        await $(FloatingActionButton).tap();
        expect($(#counterText).text, '1');

        await $.native.pressHome();
        await $.native.pressDoubleRecentApps();

        expect($(#counterText).text, '1');
        await $(FloatingActionButton).tap();
        expect($(#counterText).text, '2');

        await $.native.openNotifications();
        await $.native.pressBack();
      },
    );

    patrolTest(
      'taps around',
      config: patrolConfig,
      nativeAutomation: true,
      binding: Binding.integrationTest,
      ($) async {
        await $.native.openApp();
        await $.pumpWidgetAndSettle(ExampleApp());

        await $.native.openQuickSettings();
        await $.native.tap(Selector(text: 'Bluetooth'));
        await $.native.tap(Selector(text: 'Bluetooth'));
        await $.native.pressBack();

        await $.native.openNotifications();

        await $.native.enableWifi();
        await $.native.disableWifi();
        await $.native.enableWifi();

        await $.native.enableCellular();
        await $.native.disableCellular();
        await $.native.enableCellular();

        await $.native.enableDarkMode();
        await $.native.disableDarkMode();
        await $.native.enableDarkMode();

        await $.native.pressBack();
      },
    );

    patrolTest(
      'grants various permissions',
      config: patrolConfig,
      nativeAutomation: true,
      binding: Binding.integrationTest,
      ($) async {
        await $.native.openApp();
        await $.pumpWidgetAndSettle(ExampleApp());

        await $('Open permissions screen').scrollTo().tap();

        await requestAndGrantCameraPermission($);
        await requestAndGrantMicrophonePermission($);
      },
    );
  });
}

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
