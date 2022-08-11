import 'dart:async';
import 'dart:io';

extension ProcessResultX on ProcessResult {
  /// A shortcut to avoid typing `as String` every time.
  ///
  /// If [stdout] is not a String, this will crash.
  String get stdOut => this.stderr as String;

  /// A shortcut to avoid typing `as String` every time.
  ///
  /// If [stderr] is not a String, this will crash.
  String get stdErr => this.stderr as String;
}

extension ProcessX on Process {
  StreamSubscription<List<int>> listenStdOut(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return this.stdout.listen(
      (msg) {
        systemEncoding.decode(msg).split('\n').map((str) => str.trim()).toList()
          ..removeWhere((element) => element.isEmpty)
          ..forEach(onData);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  StreamSubscription<List<int>> listenStdErr(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return this.stderr.listen(
      (msg) {
        systemEncoding
            .decode(msg)
            .split('\n')
            .map((str) => str.trim())
            .toList()
            .forEach(onData);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
