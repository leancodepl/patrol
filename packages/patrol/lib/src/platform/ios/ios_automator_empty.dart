import 'package:patrol/src/platform/ios/ios_automator.dart' as ios_automator;
import 'package:patrol/src/platform/ios/ios_automator_config.dart';

/// An empty implementation of [ios_automator.IOSAutomator] for unsupported platforms.
///
/// This class provides a default implementation for platforms where the native iOS automator
/// is not available or supported. Any attempt to use its methods will throw an [UnimplementedError].
class IOSAutomator implements ios_automator.IOSAutomator {
  /// Creates a new [IOSAutomator] stub.
  /// [config] is required but not used for any real operations,
  /// we need to stay consistant with native_ios_automator.dart
  // ignore: avoid_unused_constructor_parameters
  IOSAutomator({required IOSAutomatorConfig config});

  /// Throws [UnimplementedError] for any method invocation.
  ///
  /// This override ensures that using any member will result in a clear error indicating
  /// that the AndroidAutomator is not available on the current platform.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'This method is not available on current platform',
  );
}
