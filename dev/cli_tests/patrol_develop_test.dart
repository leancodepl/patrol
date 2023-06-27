import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:path/path.dart';

/// Exactly like example_test.dart but with expectation that fails.
const exampleTestWithFailingContents = r'''
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

void main(List<String> args) async {
  _verifyWorkingDirectory();

  const afterBuildCompletedTimeout = Duration(minutes: 1);
  const inactivityTimeout = Duration(minutes: 15);

  var isFirstTestPassed = false;
  var isReloaded = false;
  Timer? inactivityTimer;
  final output = StringBuffer();

  final exampleAppDirectory = io.Directory(
    join('..', '..', 'packages', 'patrol', 'example'),
  );
  final exampleTestFile = io.File(
    join(exampleAppDirectory.path, 'integration_test', 'example_test.dart'),
  );

  final process = await io.Process.start(
    'patrol',
    [
      'develop',
      ...['--target', 'integration_test/example_test.dart'],
      ...args
    ],
    runInShell: true,
    workingDirectory: exampleAppDirectory.path,
  );

  process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((msg) => print('[patrol develop] $msg'));

  process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((data) async {
    print('[patrol develop] $data');
    output.write(data);
    final stringOutput = output.toString();

    if (isFirstTestPassed == false &&
        stringOutput.contains('All tests passed')) {
      isFirstTestPassed = true;
    }

    final isReadyToRestart = isFirstTestPassed &&
        isReloaded == false &&
        stringOutput.contains('press "r" to restart');

    if (isReadyToRestart) {
      exampleTestFile.writeAsStringSync(exampleTestWithFailingContents);
      process.stdin.add('R'.codeUnits);
      isReloaded = true;
    }

    final isRestartedTestFailed = isFirstTestPassed &&
        isReloaded &&
        stringOutput.contains('Some tests failed');

    if (isRestartedTestFailed) {
      print(
        'exampleTestWithFailingContents was successfully restarted as example_test and it has failed as expected',
      );
      print('Exiting with exit code 0');
      // TODO: kill `patrol develop` process and its children
      io.exit(0);
    }

    inactivityTimer?.cancel();

    if (stringOutput.contains('Completed building')) {
      inactivityTimer = Timer(afterBuildCompletedTimeout, () {
        print('One minute of inactivity, something went wrong...');
        print('isFirstTestPassed: $isFirstTestPassed');
        print('isReloaded: $isReloaded');
        print('Running file:');
        print(exampleTestFile.readAsStringSync());
        print('End of the running file');
        print('Exiting with exit code 1');
        io.exit(1);
      });
    } else {
      inactivityTimer = Timer(inactivityTimeout, () {
        print('Fifteen minutes of inactivity, something went wrong...');
        print('Exiting with exit code 1');
        io.exit(1);
      });
    }
  });
}

void _verifyWorkingDirectory() {
  if (!io.Directory.current.path.endsWith('cli_tests')) {
    print('This test must be run from dev/cli_tests directory');
    io.exit(1);
  }
}
