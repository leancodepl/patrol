import 'dart:async';
import 'dart:convert' show Encoding, LineSplitter, Utf8Decoder;
import 'dart:io' show Process, ProcessResult, ProcessStartMode, systemEncoding;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:platform/platform.dart';
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
        .transform(const Utf8Decoder(allowMalformed: true))
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
        .transform(const Utf8Decoder(allowMalformed: true))
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
    disposeScope.addDispose(kill);
  }
}

/// Shadows `dispose_scope`'s `ProcessDisposed.disposedBy`, which kills only the
/// process itself. Import `dispose_scope` with `hide ProcessDisposed` to use it.
extension ProcessTreeDisposers on Process {
  /// Adds this process to [disposeScope], to be killed together with any
  /// processes it spawned.
  ///
  /// On Windows `runInShell: true` means `cmd.exe /c <command>`, so killing the
  /// process we hold orphans the rest of the tree instead of ending it. There
  /// are no process groups to signal, hence `taskkill /T`. Elsewhere `sh -c`
  /// execs into the command, so our PID is already the real process. (#3209)
  void disposedBy(DisposeScope disposeScope, {Platform? platform}) {
    final isWindows = (platform ?? const LocalPlatform()).isWindows;

    disposeScope.addDispose(() async {
      if (!isWindows) {
        kill();
        return;
      }

      // /F because gradlew.bat and friends ignore the graceful request.
      // taskkill reports refusals (e.g. access denied) through its exit code
      // rather than by throwing, so fall back on those too.
      var killedTree = false;
      try {
        final result = await Process.run('taskkill', [
          ...['/PID', '$pid'],
          '/T',
          '/F',
        ]);
        killedTree = result.exitCode == 0;
      } catch (_) {}

      if (!killedTree) {
        kill();
      }
    });
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
