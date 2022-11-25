import 'package:patrol/patrol.dart';

// ignore: avoid_print
void _defaultPrintLogger(String message) => print('Patrol (host): $message');

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
}
