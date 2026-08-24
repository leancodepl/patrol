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

/// Import `dispose_scope` with `hide ProcessDisposed`, so that a `Process`
/// cannot be registered with the single-process `disposedBy` by accident.
extension ProcessTreeDisposers on Process {
  /// Adds this process to [disposeScope], to be killed together with any
  /// processes it spawned.
  ///
  /// The process we hold is often a wrapper - `cmd.exe /c` on Windows, `fvm` or
  /// a `flutter` shell script elsewhere - and its children outlive it. There is
  /// no process group to signal, so the descendants have to be named: `taskkill
  /// /T` walks them on Windows, `pgrep -P` elsewhere.
  void disposedByTree(DisposeScope disposeScope) {
    var exited = false;
    unawaited(exitCode.then((_) => exited = true));

    disposeScope.addDispose(() async {
      // A PID is reused once its process is gone, so killing by PID after that
      // can hit an unrelated process - and `taskkill /T` its whole tree.
      if (exited) {
        return;
      }

      if (!const LocalPlatform().isWindows) {
        // Collected before anything dies; once the parent is gone its children
        // are reparented and `pgrep -P` no longer reports them.
        (await _descendants(pid)).forEach(Process.killPid);
        kill();
        return;
      }

      // /F because gradlew.bat and friends ignore the graceful request.
      // taskkill reports refusals (e.g. access denied) through its exit code,
      // so fall back on those too.
      var killedTree = false;
      try {
        final result = await Process.run('taskkill', [
          ...['/PID', '$pid'],
          '/T',
          '/F',
        ]).timeout(const Duration(seconds: 10));
        killedTree = result.exitCode == 0;
      } catch (_) {}

      if (!killedTree) {
        kill();
      }
    });
  }
}

/// PIDs spawned below [pid], deepest first.
Future<List<int>> _descendants(int pid) async {
  final found = <int>[];
  final pending = <int>[pid];

  while (pending.isNotEmpty) {
    final parent = pending.removeLast();
    final ProcessResult result;
    try {
      result = await Process.run('pgrep', [
        ...['-P', '$parent'],
      ]).timeout(const Duration(seconds: 5));
    } catch (_) {
      continue;
    }
    if (result.exitCode != 0) {
      continue;
    }

    final children = LineSplitter.split(
      result.stdout as String,
    ).map((line) => int.tryParse(line.trim())).nonNulls;
    found.addAll(children);
    pending.addAll(children);
  }

  return found.reversed.toList();
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
