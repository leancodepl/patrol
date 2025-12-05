import 'dart:convert';

import 'package:patrol/src/platform/platform_automator.dart';

/// Devtools extension that fetches the native UI tree.
class DevtoolsServiceExtensions {
  /// Creates a new [DevtoolsServiceExtensions] based on the given [platform].
  DevtoolsServiceExtensions(this.platform);

  /// The [PlatformAutomator] used to interact with platform-specific automation features.
  final PlatformAutomator platform;

  /// Fetches the native UI tree based on the given [parameters].
  Future<Map<String, dynamic>> getNativeUITree(
    Map<String, String> parameters,
  ) async {
    try {
      final result = await platform.action(
        android: () async {
          final response = await platform.android.getNativeViews(null);
          final roots = response.roots.map((e) => e.toJson()).toList();

          return {
            'androidRoots': roots,
            'iOSroots': <Map<String, dynamic>>[],
            'roots': roots,
          };
        },
        ios: () async {
          final response = await platform.ios.getNativeViews(null);
          final roots = response.roots.map((e) => e.toJson()).toList();

          final a = {
            'androidRoots': <Map<String, dynamic>>[],
            'iOSroots': roots,
            'roots': <Map<String, dynamic>>[],
          };
          return a;
        },
      );

      final encoded = jsonEncode(result);
      return <String, String>{'result': encoded};
    } catch (err) {
      return {'error': err.toString()};
    }
  }
}
