import 'dart:io';

import 'package:path/path.dart' as p;

/// Utilities for finding iOS build artifact paths.
class IosPaths {
  /// Base products directory for iOS builds.
  static String productsDir() {
    return p.join('build', 'ios_integ', 'Build', 'Products');
  }

  /// Returns the platform-specific build directory.
  ///
  /// [buildMode] is the build mode (e.g., 'Debug', 'Release').
  /// [simulator] whether targeting simulator (iphonesimulator) or device (iphoneos).
  /// [flavor] optional flavor name.
  ///
  /// Examples:
  /// - No flavor: `Release-iphoneos`
  /// - With flavor 'dev': `Release-dev-iphoneos`
  static String buildDir({
    required String buildMode,
    required bool simulator,
    String? flavor,
  }) {
    final platform = simulator ? 'iphonesimulator' : 'iphoneos';
    final flavorPart = flavor != null ? '-$flavor' : '';
    return p.join(productsDir(), '$buildMode$flavorPart-$platform');
  }

  /// Returns the path to Runner.app (app under test).
  static String appPath({
    required String buildMode,
    required bool simulator,
    String? flavor,
  }) {
    return p.join(
      buildDir(buildMode: buildMode, simulator: simulator, flavor: flavor),
      'Runner.app',
    );
  }

  /// Returns the path to RunnerUITests-Runner.app (test instrumentation app).
  static String testAppPath({
    required String buildMode,
    required bool simulator,
    String? flavor,
  }) {
    return p.join(
      buildDir(buildMode: buildMode, simulator: simulator, flavor: flavor),
      'RunnerUITests-Runner.app',
    );
  }

  /// Finds the xctestrun file in the products directory.
  ///
  /// [runnerPrefix] is typically the scheme name (e.g., 'Runner' or flavor name).
  /// [testPlan] is the test plan name (e.g., 'TestPlan').
  /// [simulator] whether targeting simulator or device.
  ///
  /// Returns the found file or throws if not found.
  static Future<File> findXctestrunFile({
    required String runnerPrefix,
    required String testPlan,
    required bool simulator,
  }) async {
    final platform = simulator ? 'iphonesimulator' : 'iphoneos';
    final xctestrunPattern = '${runnerPrefix}_${testPlan}_$platform';
    final directory = Directory(productsDir());

    await for (final entity in directory.list()) {
      if (entity is File) {
        final name = p.basename(entity.path);
        if (name.contains(xctestrunPattern) && name.endsWith('.xctestrun')) {
          return entity;
        }
      }
    }

    throw FileSystemException(
      'Could not find xctestrun file matching: $xctestrunPattern*.xctestrun',
    );
  }
}
