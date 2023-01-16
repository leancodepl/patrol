import 'dart:io' show Process, ProcessStartMode;

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
    _logger.detail(command.map((e) => e.toString()).join(' '));
    return super.start(
      command,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );
  }
}
