import 'dart:async';
import 'dart:convert' show Encoding, LineSplitter, utf8;
import 'dart:io' show Process, ProcessResult, ProcessStartMode, systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:process/process.dart';

class LoggingLocalProcessManager extends LocalProcessManager {
  const LoggingLocalProcessManager({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  Future<Process> start(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) {
    if (_logger.level == Level.verbose) {
      final cmd = '\$ ${command.map((e) => e.toString()).join(' ')}';
      _logger.detail(cyan.wrap(cmd));
    }
    return super.start(
      command,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );
  }

  @override
  Future<ProcessResult> run(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) {
    if (_logger.level == Level.verbose) {
      final cmd = '\$ ${command.map((e) => e.toString()).join(' ')}';
      _logger.detail(cyan.wrap(cmd));
    }
    return super.run(
      command,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
  }
}

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
