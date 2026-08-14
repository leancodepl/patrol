import 'package:patrol/src/platform/macos/macos_automator.dart' as macos_automator;
import 'package:patrol/src/platform/macos/macos_automator_config.dart';

/// An empty implementation of [macos_automator.MacOSAutomator] for unsupported
/// platforms.
///
/// Any attempt to use its methods will throw an [UnimplementedError].
class MacOSAutomator implements macos_automator.MacOSAutomator {
  /// Creates a new [MacOSAutomator] stub.
  ///
  /// [config] is required to stay consistent with the native implementation.
  // ignore: avoid_unused_constructor_parameters
  MacOSAutomator({required MacOSAutomatorConfig config});

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'This method is not available on current platform',
  );
}
