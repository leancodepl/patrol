import 'dart:convert';
import 'dart:io';

void main() async {
  var isReloaded = false;

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
