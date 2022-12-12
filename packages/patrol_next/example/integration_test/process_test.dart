@Tags(['android', 'ios'])

import 'dart:io' as io;

import 'package:flutter/material.dart';

import 'common.dart';

Future<void> main() async {
  patrol('takes a few screenshots', ($) async {
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
      arguments: ['-c', '"non-existent-program"'],
    );
    expect(result.exitCode, 127);

    expect($(#counterText).text, '1');
  });
}
