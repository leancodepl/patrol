import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:path/path.dart';

/// Exactly like example_test.dart but with an expectation that fails.
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

      await $.platform.mobile.pressHome();
      await $.platform.mobile.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();

      expect($(#counterText).text, '2');
      expect($('Hello, fail here!'), findsOneWidget);
    },
  );
}
''';

/// Exactly like web/web_develop_test.dart but with an expectation that fails.
const webTestWithFailingContents = r'''
import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('This test is used to `test patrol develop` on web', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await Future<void>.delayed(const Duration(seconds: 1));

    expect($('This is the home page'), findsOneWidget);

    await $('Go to Page 1').scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('This is Page 1'), findsOneWidget);

    await $.platform.web.goBack();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    expect($('Hello, fail here!'), findsOneWidget);
  });
}
''';

void main(List<String> args) async {
  _verifyWorkingDirectory();

  // On web the develop session is one long-lived `flutter run -d chrome` plus a
  // Playwright driver, and "r" hot-restarts them rather than relaunching.
  final isWeb = args.contains('--web');
  final passthroughArgs = args.where((a) => a != '--web').toList();

  final target = isWeb
      ? join('patrol_test', 'web', 'web_develop_test.dart')
      : join('patrol_test', 'example_test.dart');
  final failingContents = isWeb
      ? webTestWithFailingContents
      : exampleTestWithFailingContents;
  // Mobile builds print this once the native runner is built; on web the
  // equivalent milestone is Flutter attaching its debug service to the page.
  final buildDoneMarker = isWeb
      ? 'Debug service listening on'
      : 'Completed building';

  const afterBuildCompletedTimeout = Duration(minutes: 5, seconds: 30);
  const inactivityTimeout = Duration(minutes: 15);

  final exampleAppDirectory = io.Directory(join('..', 'e2e_app'));
  final targetFile = io.File(join(exampleAppDirectory.path, target));
  final originalContents = targetFile.readAsStringSync();

  var isFirstTestPassed = false;
  var isBrokenVersionStarted = false;
  var isBrokenRestartCompleted = false;
  var isBrokenVersionFailed = false;
  var isRestoredVersionStarted = false;
  Timer? inactivityTimer;
  final output = StringBuffer();

  final process = await io.Process.start(
    'patrol',
    [
      'develop',
      ...['--target', target],
      ...['--no-open-devtools'],
      if (isWeb) ...['-d', 'chrome'],
      ...passthroughArgs,
      '--verbose',
    ],
    runInShell: true,
    workingDirectory: exampleAppDirectory.path,
  );

  Never finish(int code) {
    // Always leave the repo as we found it -- this test rewrites a test file
    // that is part of the e2e suite.
    targetFile.writeAsStringSync(originalContents);
    process.stdin.add('q'.codeUnits);
    process.kill();
    io.exit(code);
  }

  process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((msg) => print('[patrol develop] $msg'));

  process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (data) {
      print('[patrol develop] $data');
      output.write(data);
      final stringOutput = output.toString();

      if (isFirstTestPassed == false &&
          stringOutput.contains(
            'All tests were executed. Press "r" to start again or "q" to quit',
          )) {
        isFirstTestPassed = true;
      }

      // Round 1 -> 2: break the test, then hot restart. The edited code must
      // actually be picked up, which is the whole point of develop mode.
      final isReadyToBreak =
          isFirstTestPassed &&
          !isBrokenVersionStarted &&
          stringOutput.contains('Hot Restart: attached to the app');

      if (isReadyToBreak) {
        print('[test] breaking $target and hot restarting');
        targetFile.writeAsStringSync(failingContents);
        process.stdin.add('R'.codeUnits);
        process.stdin.flush();
        isBrokenVersionStarted = true;
      }

      // The previous run's teardown can dump exception reports while the
      // restart is still compiling; only the restarted run's output counts.
      if (isBrokenVersionStarted &&
          !isBrokenRestartCompleted &&
          stringOutput.contains('Restarted application')) {
        isBrokenRestartCompleted = true;
        output.clear();
        return;
      }

      final hasFailed =
          stringOutput.contains('When the exception was thrown') ||
          stringOutput.contains('Expected: exactly one matching candidate');

      if (isBrokenRestartCompleted && !isBrokenVersionFailed && hasFailed) {
        print('[test] broken version failed as expected');
        isBrokenVersionFailed = true;

        // Round 2 -> 3: restore and hot restart again. The second round is
        // what catches state carried over from the previous run -- on web the
        // page is never reloaded, so nothing resets it implicitly.
        print('[test] restoring $target and hot restarting again');
        targetFile.writeAsStringSync(originalContents);
        output.clear();
        process.stdin.add('R'.codeUnits);
        process.stdin.flush();
        isRestoredVersionStarted = true;
        return;
      }

      if (isRestoredVersionStarted &&
          stringOutput.contains(
            'All tests were executed. Press "r" to start again or "q" to quit',
          )) {
        print(
          '[test] restored version passed again after a second hot restart',
        );
        print('Exiting with exit code 0');
        finish(0);
      }

      inactivityTimer?.cancel();

      if (stringOutput.contains(buildDoneMarker)) {
        inactivityTimer = Timer(afterBuildCompletedTimeout, () {
          print(
            '${afterBuildCompletedTimeout.inSeconds} seconds of inactivity, '
            'something went wrong...',
          );
          print('isFirstTestPassed: $isFirstTestPassed');
          print('isBrokenVersionStarted: $isBrokenVersionStarted');
          print('isBrokenRestartCompleted: $isBrokenRestartCompleted');
          print('isBrokenVersionFailed: $isBrokenVersionFailed');
          print('isRestoredVersionStarted: $isRestoredVersionStarted');
          print('Running file:');
          print(targetFile.readAsStringSync());
          print('End of the running file');
          print('Exiting with exit code 1');
          finish(1);
        });
      } else {
        inactivityTimer = Timer(inactivityTimeout, () {
          print('Fifteen minutes of inactivity, something went wrong...');
          print('Exiting with exit code 1');
          finish(1);
        });
      }
    },
  );
}

void _verifyWorkingDirectory() {
  if (!io.Directory.current.path.endsWith('cli_tests')) {
    print('This test must be run from dev/cli_tests directory');
    io.exit(1);
  }
}
