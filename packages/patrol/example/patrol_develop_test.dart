import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

void main(List<String> args) async {
  var isFirstTestPassed = false;
  var isReloaded = false;
  Timer? inactivityTimer;
  final output = StringBuffer();

  const failingTestString = r'''
import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'This test is used to `test patrol develop`',
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $(#textField).enterText('Hello, Flutter!');
      expect($('Hello, Flutter!'), findsOneWidget);

      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();

      expect($(#counterText).text, '2');
      expect($('Hello, fail here!'), findsOneWidget);
    },
  );
}
''';

  final runningTestFilePath = join('integration_test', 'example_test.dart');
  final runningTestFile = File(runningTestFilePath);

  final process = await Process.start(
    'patrol',
    ['develop', '--target', 'integration_test/example_test.dart', ...args],
  );

  process.stderr.transform(utf8.decoder).listen(print);

  process.stdout.transform(utf8.decoder).listen((data) async {
    print(data);
    output.write(data);
    final stringOutput = output.toString();

    if (isFirstTestPassed == false &&
        stringOutput.contains('All tests passed')) {
      isFirstTestPassed = true;
    }

    if (isFirstTestPassed &&
        isReloaded == false &&
        stringOutput.contains('press "r" to restart')) {
      runningTestFile.writeAsStringSync(failingTestString);
      process.stdin.add('R'.codeUnits);
      isReloaded = true;
    }

    if (isFirstTestPassed &&
        isReloaded &&
        stringOutput.contains('Some tests failed')) {
      print(
        'example_test_fake was successfully restarted as example_test and it has failed as expected',
      );
      print('Exiting with exit code 0');
      // TODO: kill `patrol develop` process and its children
      exit(0);
    }

    inactivityTimer?.cancel();

    if (stringOutput.contains('Completed building')) {
      inactivityTimer = Timer(Duration(minutes: 1), () {
        print('One minute of inactivity, something went wrong...');
        print('isFirstTestPassed: $isFirstTestPassed');
        print('isReloaded: $isReloaded');
        print('Running file:');
        print(runningTestFile.readAsStringSync());
        print('End of the running file');
        print('Exiting with exit code 1');
        exit(1);
      });
    } else {
      inactivityTimer = Timer(Duration(minutes: 10), () {
        print('Ten minutes of inactivity, something went wrong...');
        print('Exiting with exit code 1');
        exit(1);
      });
    }
  });
}
