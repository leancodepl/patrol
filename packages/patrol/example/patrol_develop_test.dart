import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' show join;

void main() async {
  var isFirstTestPassed = false;
  var isReloaded = false;
  Timer? inactivityTimer;
  final output = StringBuffer();

  final runningTestFilePath = join('integration_test', 'example_test.dart');
  final testFileToSwapPath = join('integration_test', 'example_test_fake.dart');
  final runningTestFile = File(runningTestFilePath);
  final testFileToSwap = File(testFileToSwapPath);

  final process = await Process.start(
    'patrol',
    ['develop', '--target', 'integration_test/example_test.dart'],
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
      runningTestFile.writeAsStringSync(testFileToSwap.readAsStringSync());
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
    inactivityTimer = Timer(Duration(minutes: 1), () {
      print('isFirstTestPassed: $isFirstTestPassed');
      print('isReloaded: $isReloaded');
      print('Running file:');
      print(runningTestFile.readAsStringSync());
      print('End of the running file');
      print('One minute of inactivity, exiting with exit code 1');
      exit(1);
    });
  });
}
