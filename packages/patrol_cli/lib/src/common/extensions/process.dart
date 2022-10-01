import 'dart:async';
import 'dart:io' show Process, ProcessResult, systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';

extension ProcessResultX on ProcessResult {
  /// A shortcut to avoid typing `as String` every time.
  ///
  /// If [stdout] is not a String, this will crash.
  String get stdOut => stdout as String;

  /// A shortcut to avoid typing `as String` every time.
  ///
  /// If [stderr] is not a String, this will crash.
  String get stdErr => stderr as String;
}

extension ProcessListeners on Process {
  StreamSubscription<List<int>> listenStdOut(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return stdout.listen(
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
    return stderr.listen(
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

extension ProcessDisposers on Process {
  void disposed(DisposeScope disposeScope) {
    disposeScope.addDispose(() async => kill());
  }
}
