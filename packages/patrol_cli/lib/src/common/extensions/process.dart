import 'dart:async';
import 'dart:convert' show LineSplitter, utf8;
import 'dart:io' show Process, ProcessResult;

import 'package:dispose_scope/dispose_scope.dart';

extension ProcessListeners on Process {
  StreamSubscription<void> listenStdOut(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }

  StreamSubscription<void> listenStdErr(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          onData,
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
