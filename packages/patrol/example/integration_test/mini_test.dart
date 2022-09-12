import 'dart:io' show Platform;

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

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

  final patrol = Patrol.forTest();

  patrolTest(
    'counter state is the same after going to Home and switching apps',
    config: patrolConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $(FloatingActionButton).tap();
      await $(FloatingActionButton).tap();

      await _wait();

      await patrol.pressHome();

      $.log("I went to home! Now I'm gonna open the mail app");

      await _wait();

      await patrol.openApp(id: mapsId);
      $.log("Opened mail app! Now I'm gonna go to home");

      await _wait();

      await patrol.pressHome();

      await patrol.openApp(id: myAppId);
      $.log('Opening the app under test again...');

      expect($(#counterText).text, '2');

      await _wait();

      $.log("More functionality is not implemented, so I'm gonna head out now");
    },
  );
}

Future<void> _wait() => Future<void>.delayed(const Duration(seconds: 2));
