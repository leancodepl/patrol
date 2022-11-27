import 'dart:io' as io;

import 'package:patrol/patrol.dart';

void _defaultPrintLogger(String message) {
  if (const bool.fromEnvironment('PATROL_VERBOSE')) {
    // ignore: avoid_print
    print('Patrol (host): $message');
  }
}

/// Configuration for [HostAutomator].
class HostAutomatorConfig {
  /// Creates a new [HostAutomatorConfig].
  const HostAutomatorConfig({this.logger = _defaultPrintLogger});

  /// Called when a host action is performed.
  final void Function(String) logger;
}

/// Provides functionality to run actions as the host system (your computer).
class HostAutomator {
  /// Creates a new [HostAutomator].
  const HostAutomator({
    required PatrolBinding binding,
    required HostAutomatorConfig config,
  })  : _binding = binding,
        _config = config;

  final PatrolBinding _binding;
  final HostAutomatorConfig _config;

  /// Shortcut for [PatrolBinding.takeFlutterScreenshot].
  Future<void> takeScreenshot({
    String name = 'screenshot_1',
    String path = 'screenshots',
  }) async {
    _config.logger('takeScreenshot(name: $name, path: $path)');
    await _binding.takeFlutterScreenshot(name: name, path: path);
  }

  /// Shortcut for [PatrolBinding.runProcess].
  Future<io.ProcessResult> runProcess(
    String executable, {
    List<String> arguments = const [],
    bool runInShell = false,
  }) async {
    _config.logger(
      'runProcess(executable: $executable, arguments: $arguments, runInShell: $runInShell)',
    );
    final result = await _binding.runProcess(
      executable: executable,
      arguments: arguments,
      runInShell: runInShell,
    );

    if (result.exitCode != 0) {
      _config.logger('WARNING: process "$executable" failed');
      _config.logger('WARNING:   exit code: ${result.exitCode}');
      _config.logger('WARNING:   pid:       ${result.pid}');
      _config.logger('WARNING:   stdout:    ${result.stdout}');
      _config.logger('WARNING:   stderr:    ${result.stderr}');
    }
    return result;
  }
}
