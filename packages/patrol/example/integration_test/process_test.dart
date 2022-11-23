@Tags(['android', 'ios'])

import 'dart:io' show Platform;

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  late String mapsId;
  if (Platform.isIOS) {
    mapsId = 'com.apple.Maps';
  } else if (Platform.isAndroid) {
    mapsId = 'com.google.android.apps.maps';
  }

  patrolTest(
    'takes a few screenshots',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.host.runProcess(
        'bash',
        arguments: ['-c', 'echo "hello world" > hello.txt'],
      );

      await $.pumpWidgetAndSettle(ExampleApp());

      expect($(#counterText).text, '0');

      await $.host.runProcess(
        'bash',
        arguments: [
          '-c',
          'echo "counter text: ${$(#counterText).text}" > counter_text.txt',
        ],
      );

      await $(FloatingActionButton).tap();

      await $.native.pressHome();

      await $.native.openApp(appId: mapsId);

      await $.native.pressHome();

      await $.native.openApp();

      await $.host.runProcess(
        'bash',
        arguments: ['-c', '"this command will fail"'],
      );

      expect($(#counterText).text, '1');
    },
  );
}
