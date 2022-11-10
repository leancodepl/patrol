import 'package:patrol/patrol.dart';

/// Provides functionality to run actions as the host system (your computer).
class HostAutomator {
  /// Creates a new [HostAutomator].
  const HostAutomator({required PatrolBinding binding}) : _binding = binding;

  final PatrolBinding _binding;

  /// Shortcut for [PatrolBinding.takeFlutterScreenshot].
  Future<void> takeScreenshot({
    String name = 'screenshot_1',
    String path = 'screenshots',
  }) async {
    await _binding.takeFlutterScreenshot(name: name, path: path);
  }
}
