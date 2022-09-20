import 'dart:io' show Platform;

import 'package:convenient_test_dev/convenient_test_dev.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';
import 'test_slot.dart';

late String mapsId;
late String myAppId;

Future<void> main() async {
  if (Platform.isIOS) {
    mapsId = 'com.apple.Maps';
    myAppId = 'pl.leancode.patrol.Example';
  } else if (Platform.isAndroid) {
    mapsId = 'com.google.android.apps.maps';
    myAppId = 'pl.leancode.patrol.example';
  }

  final patrol = NativeAutomator.forTest(useBinding: false);

  await convenientTestMain(MyConvenientTestSlot(), () {
    tTestWidgets(
      'state is preserved when app is exited (convenient_test)',
      (t) async {
        final $ = PatrolTester(
          tester: t.tester,
          nativeAutomator: patrol,
          config: patrolConfig,
        );

        await $.pumpWidgetAndSettle(const ExampleApp());

        await $(FloatingActionButton).tap();
        await $(FloatingActionButton).tap();

        await _wait();

        await $.native.pressHome();

        $.log("I went to home! Now I'm gonna open the mail app");

        await _wait();

        await $.native.openApp(id: mapsId);
        $.log("Opened mail app! Now I'm gonna go to home");

        await _wait();

        await $.native.pressHome();

        await $.native.openApp(id: myAppId);
        $.log('Opening the app under test again...');

        expect($(#counterText).text, '2');
      },
    );
  });
}

Future<void> _wait() => Future<void>.delayed(const Duration(seconds: 2));
