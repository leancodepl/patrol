import 'package:patrol/src/platform/android/android_automator.dart'
    as android_automator;
import 'package:patrol/src/platform/android/android_automator_config.dart';

/// An empty implementation of [android_automator.AndroidAutomator] for unsupported platforms.
///
/// This class provides a default implementation for platforms where the native Android automator
/// is not available or not supported. Any attempt to call its methods will result in an
/// [UnimplementedError].
class AndroidAutomator extends android_automator.AndroidAutomator {
  /// Creates a new [AndroidAutomator] stub.
  /// [config] is required but not used for any real operations,
  /// we need to stay consistant with native_android_automator.dart
  // ignore: avoid_unused_constructor_parameters
  AndroidAutomator({required AndroidAutomatorConfig config});

  /// Throws [UnimplementedError] for any method invocation.
  ///
  /// This override ensures that using any member will result in a clear error indicating
  /// that the AndroidAutomator is not available on the current platform.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'This method is not available on current platform',
  );
}
