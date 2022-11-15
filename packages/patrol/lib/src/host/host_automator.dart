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
}
