import 'package:patrol/src/platform/platform_automator.dart';

/// Devtools extension that fetches the native UI tree.
class DevtoolsServiceExtensions {
  /// Creates a new [DevtoolsServiceExtensions] based on the given [platform].
  DevtoolsServiceExtensions(this.platform);

  /// The [PlatformAutomator] used to interact with platform-specific automation features.
  final PlatformAutomator platform;

  /// Fetches the native UI tree based on the given [parameters].
  Future<Map<String, dynamic>> getNativeUITree(Map<String, String> parameters) {
    final useNativeViewHierarchy =
        parameters['useNativeViewHierarchy'] == 'yes';

    return platform.actionSafe(
      android: (android) => android.getNativeUITree(
        useNativeViewHierarchy: useNativeViewHierarchy,
      ),
      ios: (ios) =>
          ios.getNativeUITree(useNativeViewHierarchy: useNativeViewHierarchy),
      web: (web) =>
          web.getNativeUITree(useNativeViewHierarchy: useNativeViewHierarchy),
      macos: (macos) =>
          macos.getNativeUITree(useNativeViewHierarchy: useNativeViewHierarchy),
    );
  }
}
