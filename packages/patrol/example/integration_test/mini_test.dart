import 'dart:io' show Platform;

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

late String mapsId;
late String myAppId;

Future<void> main() async {
  if (Platform.isIOS) {
    mapsId = 'com.apple.Maps';
  } else if (Platform.isAndroid) {
    mapsId = 'com.google.android.apps.maps';
  }

  patrolTest(
    'counter state is the same after going to Home and switching apps',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $(FloatingActionButton).tap();
      await $(FloatingActionButton).tap();

      await $.native.pressHome();
      await $.native.openApp(appId: mapsId);
      await $.native.pressHome();
      await $.native.openApp(); // opens the app under test

      expect($(#counterText).text, '2');
    },
  );
}
