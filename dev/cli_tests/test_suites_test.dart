import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:path/path.dart';

void main(List<String> args) async {
  _verifyWorkingDirectory();

  const afterBuildCompletedTimeout = Duration(minutes: 2);
  var isResultCorrect = false;
  const inactivityTimeout = Duration(minutes: 15);
  Timer? inactivityTimer;
  final output = StringBuffer();

  final exampleAppDirectory = io.Directory(join('..', 'e2e_app'));
  final exampleTestFile = io.File(
    join(
      exampleAppDirectory.path,
      'integration_test/internal',
      'test_suites_test.dart',
    ),
  );

  final process = await io.Process.start(
    'patrol',
    [
      'develop',
      ...['--target', 'integration_test/internal/test_suites_test.dart'],
      ...['--no-open-devtools'],
      ...args,
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

    final isTestFinished = stringOutput.contains('All tests passed!');

    if (isTestFinished) {
      isResultCorrect = _isOutputCorrect(stringOutput);
    }

    if (isResultCorrect && isTestFinished) {
      print(
        'all tests have been run in correct order',
      );
      print('Exiting with exit code 0');
      // TODO: kill `patrol develop` process and its children
      io.exit(0);
    } else if (isTestFinished && !isResultCorrect) {
      print(
        'all tests have passed but not correct order',
      );
      print('Exiting with exit code 1');
      io.exit(1);
    }

    inactivityTimer?.cancel();

    if (stringOutput.contains('Completed building')) {
      inactivityTimer = Timer(afterBuildCompletedTimeout, () {
        print(
          '${afterBuildCompletedTimeout.inSeconds} seconds of inactivity, something went wrong...',
        );
        print(exampleTestFile.readAsStringSync());

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

bool _isOutputCorrect(String output) {
  final numbers = RegExp(r'(?<=\s)(\d+)(?=\s|$)')
      .allMatches(output)
      .map((match) => int.parse(match.group(1)!))
      .where((number) => number >= 1 && number <= 31)
      .toList();

  final expectedNumbers = List.generate(31, (index) => index + 1);

  return listsAreEqual(numbers, expectedNumbers);
}

bool listsAreEqual(List<int> list1, List<int> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  for (var i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}
