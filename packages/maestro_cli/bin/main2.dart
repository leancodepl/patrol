import 'dart:async';
import 'dart:io';

const port = 8081;
void main() async {
  print('Forwarding ports...');

  try {
    final process = await Process.start(
      'stdbuf',
      [
        '-i0',
        '-o0',
        '-e0',
        'iproxy',
        '$port:$port',
      ],
      runInShell: true,
    );

    print('process started');
    final completer = Completer<void>();

    final stdOutSub = process.stdout.listen(
      (msg) {
        final lines = systemEncoding
            .decode(msg)
            .split('\n')
            .map((str) => str.trim())
            .toList();

        for (final line in lines) {
          print('iproxy: $line');

          if (line.contains('waiting for connection')) {
            completer.complete();
          }
        }
      },
      onDone: () => print('done'),
    );

    process.stderr.listen(
      (msg) {
        //print('rawMsg: $msg');

        final lines = systemEncoding
            .decode(msg)
            .split('\n')
            .map((str) => str.trim())
            .toList();

        for (final line in lines) {
          print('iproxy: $line');
        }
      },
      onDone: () => print('Done'),
    );

    //await process.exitCode;

    await completer.future;
  } catch (err) {
    print('Failed to forward ports');
    rethrow;
  }

  print('Forwarded ports');
}
