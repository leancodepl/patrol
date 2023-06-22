import 'dart:convert';
import 'dart:io';

void main() async {
  var isReloaded = false;

  Future<void> swapTestFiles() async {
    const correctTestFilePath = 'integration_test/example_test.dart';
    const fakeTestFilePath = 'integration_test/example_test_fake.dart';

    final correctTestFile = File(correctTestFilePath);
    final fakeTestFile = File(fakeTestFilePath);

    if (correctTestFile.existsSync() && correctTestFile.existsSync()) {
      correctTestFile.deleteSync();
      fakeTestFile.renameSync(correctTestFilePath);
    } else {
      print('One or both files do not exist.');
    }
  }

  final process = await Process.start(
    'patrol',
    ['develop', '--target', 'integration_test/example_test.dart'],
  );

  process.stderr.transform(utf8.decoder).listen(print);

  final subscription = process.stdout.transform(utf8.decoder).listen((data) {
    print(data);

    if (isReloaded && data.contains('All tests passed!')) {
      sleep(Duration(seconds: 2));
      print('killing');
    }

    if (data
        .contains('Hot Restart: attached to the app (press "r" to restart)')) {
      sleep(Duration(seconds: 2));
      swapTestFiles(); // await
      print("Pressing 'r' and then Enter key");
      process.stdin.writeln('r\n');
      //process.stdin.add('R'.codeUnits);
      isReloaded = true;
    }
  });

  // if (isReloaded) {
  //   await subscription.cancel();
  //   process.kill();
  // }

  // Wait for the command to complete
  final exitCode = await process.exitCode;
  print('Command exited with code $exitCode exitCode');
}
