import 'dart:io';

import 'package:path/path.dart' as p;

/// Utilities for finding Android APK paths.
class ApkPaths {
  /// Returns the path to the app APK.
  ///
  /// [flavor] is the flavor of the app (optional).
  /// [buildMode] is the build mode (e.g., 'Debug', 'Release').
  static String appApkPath({String? flavor, required String buildMode}) {
    final baseApkPath = p.join('build', 'app', 'outputs', 'apk');

    final String apkDir;
    final String apkName;

    if (flavor != null) {
      apkDir = p.join(baseApkPath, flavor, buildMode.toLowerCase());
      apkName = 'app-$flavor-${buildMode.toLowerCase()}.apk';
    } else {
      apkDir = p.join(baseApkPath, buildMode.toLowerCase());
      apkName = 'app-${buildMode.toLowerCase()}.apk';
    }

    return p.join(apkDir, apkName);
  }

  /// Returns the path to the test (instrumentation) APK.
  ///
  /// [flavor] is the flavor of the app (optional).
  /// [buildMode] is the build mode (e.g., 'Debug', 'Release').
  static String testApkPath({String? flavor, required String buildMode}) {
    final baseApkPath = p.join('build', 'app', 'outputs', 'apk');

    final String apkDir;
    final String apkName;

    if (flavor != null) {
      apkDir = p.join(
        baseApkPath,
        'androidTest',
        flavor,
        buildMode.toLowerCase(),
      );
      apkName = 'app-$flavor-${buildMode.toLowerCase()}-androidTest.apk';
    } else {
      apkDir = p.join(baseApkPath, 'androidTest', buildMode.toLowerCase());
      apkName = 'app-${buildMode.toLowerCase()}-androidTest.apk';
    }

    return p.join(apkDir, apkName);
  }

  /// Returns the app APK as a [File], throwing if it doesn't exist.
  static File findAppApk({String? flavor, required String buildMode}) {
    final path = appApkPath(flavor: flavor, buildMode: buildMode);
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('Could not find app APK at: $path');
    }
    return file;
  }

  /// Returns the test APK as a [File], throwing if it doesn't exist.
  static File findTestApk({String? flavor, required String buildMode}) {
    final path = testApkPath(flavor: flavor, buildMode: buildMode);
    final file = File(path);
    if (!file.existsSync()) {
      throw FileSystemException('Could not find test APK at: $path');
    }
    return file;
  }
}
