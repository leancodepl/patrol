import 'dart:io' as io;

import 'package:patrol/patrol.dart';

typedef _LoggerCallback = void Function(String);

// ignore: avoid_print
void _defaultPrintLogger(String message) => print('Patrol (host): $message');

/// Provides functionality to run actions as the host system (your computer).
class HostAutomator {
  /// Creates a new [HostAutomator].
  const HostAutomator({
    required PatrolBinding binding,
    void Function(String) logger = _defaultPrintLogger,
  })  : _binding = binding,
        _logger = logger;

  final PatrolBinding _binding;

  final _LoggerCallback _logger;

  /// Shortcut for [PatrolBinding.takeFlutterScreenshot].
  Future<void> takeScreenshot({
    String name = 'screenshot_1',
    String path = 'screenshots',
  }) async {
    _logger('takeScreenshot(name: $name, path: $path)');
    await _binding.takeFlutterScreenshot(name: name, path: path);
  }

  /// Shortcut for [PatrolBinding.runProcess].
  Future<io.ProcessResult> runProcess(
    String executable, {
    List<String> arguments = const [],
    bool runInShell = false,
  }) async {
    _logger(
      'runProcess(executable: $executable, arguments: $arguments, runInShell: $runInShell)',
    );
    final result = await _binding.runProcess(
      executable: executable,
      arguments: arguments,
      runInShell: runInShell,
    );

    if (result.exitCode != 0) {
      _logger('WARNING: process "$executable" failed');
      _logger('WARNING:  exit code: ${result.exitCode}');
      _logger('WARNING:  pid:       ${result.pid}');
      _logger('WARNING:  stdout:    ${result.stdout}');
      _logger('WARNING:  stderr:    ${result.stderr}');
    }
    return result;
  }
}
