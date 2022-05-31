import 'dart:async';
import 'dart:io';

Future<void> installServer() async {
  print('Installing instrumentation server...');

  final res = await Process.run(
    'adb',
    [
      'install',
      Platform.script.resolve('../assets/server.apk').toFilePath(),
    ],
  );
  final err = res.stderr as String;

  if (err.isNotEmpty) {
    print(res.stderr);
    throw Error();
  }

  print('Instrumentation server installed');
}

Future<void> forwardPorts(int port) async {
  final res = await Process.run(
    'adb',
    [
      'forward',
      'tcp:$port',
      'tcp:$port',
    ],
  );
  final err = res.stderr as String;

  if (err.isNotEmpty) {
    print(res.stderr);
    throw Error();
  }
}

Future<void> runServer() async {
  print('Starting instrumentation server...');

  final res = await Process.start(
    'adb',
    [
      'shell',
      'am',
      'instrument',
      '-w',
      'pl.leancode.automatorserver.test/androidx.test.runner.AndroidJUnitRunner',
    ],
  );

  final code = await res.exitCode;
  if (code != 0) {
    print('Instrumentation server exited with code $code');
    throw Error();
  }
}
