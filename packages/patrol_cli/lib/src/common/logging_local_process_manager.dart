import 'dart:convert' show Encoding;
import 'dart:io' show Process, ProcessResult, ProcessStartMode, systemEncoding;

import 'package:patrol_cli/src/common/logger.dart';
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
