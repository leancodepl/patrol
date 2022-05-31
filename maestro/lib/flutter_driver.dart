import 'dart:io';

Future<void> runTests(String driver, String target) async {
  print('Running tests...');

  final res = await Process.run(
    'flutter',
    [
      'drive',
      '--driver',
      driver,
      '--target',
      target,
    ],
  );
  final err = res.stderr as String;

  if (err.isNotEmpty) {
    print(res.stderr);
    throw Error();
  }
}

Future<void> runTestsWithOutput(String driver, String target) async {
  print('Running tests with output...');

  final res = await Process.start(
    'flutter',
    [
      'drive',
      '--driver',
      driver,
      '--target',
      target,
    ],
  );

  final sub = res.stdout.listen((e) => print(systemEncoding.decode(e)));
  await res.exitCode;
  await sub.cancel();
}
