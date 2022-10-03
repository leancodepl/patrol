import 'dart:io' show Platform;

import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';
import 'test_slot.dart';

late String mapsId;

Future<void> main() async {
  if (Platform.isIOS) {
    mapsId = 'com.apple.Maps';
  } else if (Platform.isAndroid) {
    mapsId = 'com.google.android.apps.maps';
  }

  final nativeAutomator = NativeAutomator.forTest(
    useBinding: false,
    packageName: patrolConfig.packageName,
    bundleId: patrolConfig.bundleId,
  );

  await convenientTestMain(MyConvenientTestSlot(), () {
    tTestWidgets(
      'state is preserved when app is exited (convenient_test)',
      (t) async {
        final $ = PatrolTester(
          tester: t.tester,
          nativeAutomator: nativeAutomator,
          config: patrolConfig,
        );

        await $.pumpWidgetAndSettle(const ExampleApp());

        await $(FloatingActionButton).tap();
        await $(FloatingActionButton).tap();

        await _wait();
        await $.native.pressHome();
        await _wait();
        await $.native.openApp(appId: mapsId);
        await _wait();
        await $.native.pressHome();
        await $.native.openApp();

        expect($(#counterText).text, '2');
      },
    );
  });
}

Future<void> _wait() => Future<void>.delayed(const Duration(seconds: 2));
