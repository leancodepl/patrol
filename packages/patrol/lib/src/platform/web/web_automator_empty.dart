import 'package:patrol/src/platform/web/web_automator.dart' as web_automator;
import 'package:patrol/src/platform/web/web_automator_config.dart';

/// An empty implementation of [web_automator.WebAutomator] for unsupported platforms.
///
/// This class provides a default implementation for platforms where the native web automator
/// is not available or supported. Any attempt to use its methods will throw an [UnimplementedError].
class WebAutomator implements web_automator.WebAutomator {
  /// Creates a new [WebAutomator] stub.
  /// [config] is required but not used for any real operations,
  /// we need to stay consistant with native_web_automator.dart
  // ignore: avoid_unused_constructor_parameters
  WebAutomator({required WebAutomatorConfig config});

  /// Throws [UnimplementedError] for any method invocation.
  ///
  /// This override ensures that using any member will result in a clear error indicating
  /// that the AndroidAutomator is not available on the current platform.
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'This method is not available on current platform',
  );
}
