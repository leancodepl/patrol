@Tags(['android', 'ios'])

import 'dart:io' as io;

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'config.dart';

Future<void> main() async {
  patrolTest(
    'takes a few screenshots',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      io.ProcessResult? result;

      result = await $.host.runProcess(
        'bash',
        arguments: ['-c', 'echo "hello world" > hello.txt'],
      );
      expect(result.exitCode, 0);

      await $.pumpWidgetAndSettle(ExampleApp());

      expect($(#counterText).text, '0');

      result = await $.host.runProcess(
        'bash',
        arguments: [
          '-c',
          'echo "counter text: ${$(#counterText).text}" > counter_text.txt',
        ],
      );
      expect(result.exitCode, 0);

      await $(FloatingActionButton).tap();

      await $.native.pressHome();

      await $.native.openApp();

      result = await $.host.runProcess(
        'bash',
        arguments: ['-c', '"this command will fail"'],
      );
      expect(result.exitCode, 127);

      expect($(#counterText).text, '1');
    },
  );
}
