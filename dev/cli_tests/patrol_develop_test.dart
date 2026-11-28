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

/// A passing test named [name], which the skip stages put next to their
/// skipped tests. Two tests of one file need two names, since the last test is
/// found by name.
String _passingTest([
  String name = 'This test is used to `test patrol develop`',
]) =>
    '''
  patrol(
    '$name',
    (\$) async {
      await createApp(\$);

      await \$(FloatingActionButton).tap();
      expect(\$(#counterText).text, '1');
    },
  );
''';

/// Printed by a `setUp` that only skipped tests have, so it must not appear.
const skippedSetUpMarker = 'SKIPPED_TEST_SETUP_RAN';

String _testFile(String body) =>
    '''
import 'package:flutter/material.dart';

import 'common.dart';

void main() {
$body}
''';

/// The name of the test whose `setUp` throws in the last stage.
const setUpThrowsTestName = 'This test has a setUp that throws';

/// Files the test hot restarts into, in order. Each stage ends when `done`
/// holds for its output: the end of the run, or for a throwing `setUp`, the
/// test's failure entry.
final skipStages =
    <({String name, String contents, bool Function(String) done})>[
      (
        name: 'a skipped last test',
        done: _endsRun,
        contents: _testFile('''
${_passingTest()}
  patrol('This skipped test is the last one in the file', (\$) async {},
      skip: true);
'''),
      ),
      (
        name: 'a skipped test in the middle',
        done: _endsRun,
        contents: _testFile('''
${_passingTest()}
  group('skipped tests', () {
    setUp(() => print('$skippedSetUpMarker'));
    patrol('This skipped test is in the middle', (\$) async {}, skip: true);
  });
${_passingTest('This test runs after the skipped one')}'''),
      ),
      (
        name: 'a skipped group at the end',
        done: _endsRun,
        contents: _testFile('''
${_passingTest()}
  group('skipped group', () {
    setUp(() => print('$skippedSetUpMarker'));
    patrol('This test is in a skipped group', (\$) async {});
  }, skip: true);
'''),
      ),
      (
        name: 'only skipped tests',
        done: _endsRun,
        contents: _testFile(r'''
  patrol('This test is skipped', ($) async {}, skip: true);
'''),
      ),
      (
        name: 'a last test whose setUp throws',
        done: (output) =>
            output.contains('❌') && output.contains(setUpThrowsTestName),
        contents: _testFile('''
  setUp(() => throw StateError('setUp failed'));
  patrol('$setUpThrowsTestName', (\$) async {});
'''),
      ),
    ];

bool _endsRun(String output) => output.contains(allTestsExecuted);

const allTestsExecuted =
    'All tests were executed. Press "r" to start again or "q" to quit';

void main(List<String> args) async {
  _verifyWorkingDirectory();

  const afterBuildCompletedTimeout = Duration(minutes: 5, seconds: 30);
  const inactivityTimeout = Duration(minutes: 15);

  var isFirstTestPassed = false;
  var isReloaded = false;
  var skipStage = -1;
  var skipStageOutputStart = 0;
  Timer? inactivityTimer;
  final output = StringBuffer();

  final exampleAppDirectory = io.Directory(join('..', 'e2e_app'));
  final exampleTestFile = io.File(
    join(exampleAppDirectory.path, 'patrol_test', 'example_test.dart'),
  );

  final process = await io.Process.start(
    'patrol',
    [
      'develop',
      ...['--target', 'patrol_test/example_test.dart'],
      ...['--no-open-devtools'],
      ...args,
      '--verbose',
    ],
    runInShell: true,
    workingDirectory: exampleAppDirectory.path,
  );

  process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((msg) => print('[patrol develop] $msg'));

  process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((
    data,
  ) {
    print('[patrol develop] $data');
    output.write(data);
    final stringOutput = output.toString();

    if (isFirstTestPassed == false && stringOutput.contains(allTestsExecuted)) {
      isFirstTestPassed = true;
    }

    final isReadyToRestart =
        isFirstTestPassed &&
        isReloaded == false &&
        stringOutput.contains('Hot Restart: attached to the app');

    if (isReadyToRestart) {
      exampleTestFile.writeAsStringSync(exampleTestWithFailingContents);
      process.stdin.add('R'.codeUnits);
      isReloaded = true;
    }

    final isRestartedTestFailed =
        isFirstTestPassed &&
        isReloaded &&
        stringOutput.contains('When the exception was thrown');

    void startSkipStage(int stage) {
      skipStage = stage;
      skipStageOutputStart = stringOutput.length;
      exampleTestFile.writeAsStringSync(skipStages[stage].contents);
      process.stdin.add('R'.codeUnits);
    }

    if (isRestartedTestFailed && skipStage == -1) {
      print(
        'exampleTestWithFailingContents was successfully restarted as example_test and it has failed as expected',
      );
      startSkipStage(0);
    } else if (skipStage >= 0) {
      final stageOutput = stringOutput.substring(skipStageOutputStart);
      if (stageOutput.contains(skippedSetUpMarker)) {
        print(
          'A skipped test ran its setUp with ${skipStages[skipStage].name}',
        );
        print('Exiting with exit code 1');
        io.exit(1);
      }
      if (skipStages[skipStage].done(stageOutput)) {
        print('The run reported its end with ${skipStages[skipStage].name}');
        if (skipStage == skipStages.length - 1) {
          print('Exiting with exit code 0');
          // TODO: kill `patrol develop` process and its children
          io.exit(0);
        }
        startSkipStage(skipStage + 1);
      }
    }

    inactivityTimer?.cancel();

    if (stringOutput.contains('Completed building')) {
      inactivityTimer = Timer(afterBuildCompletedTimeout, () {
        print(
          '${afterBuildCompletedTimeout.inSeconds} seconds of inactivity, something went wrong...',
        );
        print('isFirstTestPassed: $isFirstTestPassed');
        print('isReloaded: $isReloaded');
        print('skipStage: $skipStage');
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
