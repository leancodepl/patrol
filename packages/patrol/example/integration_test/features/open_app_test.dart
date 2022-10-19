import 'dart:io' show Platform;

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';

Future<void> main() async {
  late String mapsId;
  if (Platform.isIOS) {
    mapsId = 'com.apple.Maps';
  } else if (Platform.isAndroid) {
    mapsId = 'com.google.android.apps.maps';
  }

  patrolTest(
    'counter state is the same after switching apps',
    config: patrolConfig,
    nativeAutomation: true,
    binding: Binding.integrationTest,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      expect($(#counterText).text, '0');
      await $(FloatingActionButton).tap();

      await $(FloatingActionButton).tap();

      await $.native.pressHome();
      await $.native.openApp(appId: mapsId);
      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
    },
  );
}
