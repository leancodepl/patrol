import 'package:patrol/src/platform/platform_automator.dart';

/// Devtools extension that fetches the native UI tree.
class DevtoolsServiceExtensions {
  /// Creates a new [DevtoolsServiceExtensions] based on the given [platform].
  DevtoolsServiceExtensions(this.platform);

  /// The [PlatformAutomator] used to interact with platform-specific automation features.
  final PlatformAutomator platform;

  /// Fetches the native UI tree based on the given [parameters].
  Future<Map<String, dynamic>> getNativeUITree(Map<String, String> parameters) {
    return platform.action(
      android: () async =>
          (await platform.android.getNativeViews(null)).toJson(),
      ios: () async => (await platform.ios.getNativeViews(null)).toJson(),
    );
  }
}
