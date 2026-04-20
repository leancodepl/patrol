// TODO: manage immutable classes
// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

class PatrolPubspecConfig with EquatableMixin {
  PatrolPubspecConfig({
    required this.flutterPackageName,
    required this.android,
    required this.ios,
    required this.macos,
    this.testDirectory = 'patrol_test',
    this.testFileSuffix = '_test.dart',
    this.addToApp = false,
  });

  PatrolPubspecConfig.empty({required String flutterPackageName})
    : this(
        flutterPackageName: flutterPackageName,
        android: AndroidPubspecConfig.empty(),
        ios: IOSPubspecConfig.empty(),
        macos: MacOSPubspecConfig.empty(),
      );

  final String flutterPackageName;
  AndroidPubspecConfig android;
  IOSPubspecConfig ios;
  MacOSPubspecConfig macos;
  String testDirectory;
  String testFileSuffix;
  bool addToApp;

  @override
  List<Object?> get props => [
    android,
    ios,
    macos,
    testDirectory,
    testFileSuffix,
    addToApp,
  ];
}

class AndroidPubspecConfig with EquatableMixin {
  AndroidPubspecConfig({
    this.packageName,
    this.appName,
    this.flavor,
    this.nativeProjectPath,
  });

  AndroidPubspecConfig.empty()
    : this(
        packageName: null,
        appName: null,
        flavor: null,
        nativeProjectPath: null,
      );

  String? packageName;
  String? appName;
  String? flavor;

  /// Path (relative to pubspec.yaml) to an external native Android project used
  /// in Flutter add-to-app setups. When set, Patrol runs Gradle against this
  /// directory instead of the module's generated `.android/` scaffold.
  String? nativeProjectPath;

  @override
  List<Object?> get props => [packageName, appName, flavor, nativeProjectPath];
}

class IOSPubspecConfig with EquatableMixin {
  IOSPubspecConfig({
    this.bundleId,
    this.appName,
    this.flavor,
    this.nativeProjectPath,
  });

  IOSPubspecConfig.empty()
    : this(
        bundleId: null,
        appName: null,
        flavor: null,
        nativeProjectPath: null,
      );

  String? bundleId;
  String? appName;
  String? flavor;

  /// Path (relative to pubspec.yaml) to an external native iOS project used in
  /// Flutter add-to-app setups. When set, Patrol runs xcodebuild against this
  /// directory instead of the module's generated `.ios/` scaffold.
  String? nativeProjectPath;

  @override
  List<Object?> get props => [bundleId, appName, flavor, nativeProjectPath];
}

class MacOSPubspecConfig with EquatableMixin {
  MacOSPubspecConfig({this.bundleId, this.appName, this.flavor});

  MacOSPubspecConfig.empty()
    : this(bundleId: null, appName: null, flavor: null);

  String? bundleId;
  String? appName;
  String? flavor;

  @override
  List<Object?> get props => [bundleId, appName, flavor];
}

/// Reads Patrol CLI configuration block from pubspec.yaml.
class PubspecReader {
  PubspecReader({required Directory projectRoot})
    : _projectRoot = projectRoot,
      _fs = projectRoot.fileSystem;

  final Directory _projectRoot;
  final FileSystem _fs;

  /// Gets the patrol package version from pubspec.lock
  /// This reads the actual resolved version that's being used in the project.
  String? getPatrolVersion() {
    final filePath = _fs.path.join(_projectRoot.path, 'pubspec.lock');
    final file = _fs.file(filePath);

    if (!file.existsSync()) {
      return null;
    }

    final contents = file.readAsStringSync();
    if (contents.isEmpty) {
      return null;
    }

    try {
      final yaml = loadYaml(contents) as Map?;
      if (yaml == null) {
        return null;
      }

      final packages = yaml['packages'] as Map?;
      if (packages == null) {
        return null;
      }

      final patrol = packages['patrol'] as Map?;
      if (patrol == null) {
        return null;
      }

      final version = patrol['version'];
      if (version == null) {
        return null;
      }

      return version.toString();
    } catch (err) {
      // Handle YAML parsing errors
      return null;
    }
  }

  PatrolPubspecConfig read() {
    final filePath = _fs.path.join(_projectRoot.path, 'pubspec.yaml');
    final file = _fs.file(filePath);

    if (!file.existsSync()) {
      throw FileSystemException("pubspec.yaml doesn't exist", filePath);
    }

    final contents = file.readAsStringSync();
    final yaml = loadYaml(contents) as Map;

    // Auto-detect Flutter module (add-to-app) projects
    final flutter = yaml['flutter'] as Map?;
    final isFlutterModule = flutter != null && flutter.containsKey('module');

    final androidConfig = AndroidPubspecConfig();
    final iosConfig = IOSPubspecConfig();
    final macosConfig = MacOSPubspecConfig();
    final config = PatrolPubspecConfig(
      flutterPackageName: yaml['name'] as String,
      android: androidConfig,
      ios: iosConfig,
      macos: macosConfig,
      addToApp: isFlutterModule,
    );

    final patrol = yaml['patrol'] as Map?;
    if (patrol == null) {
      return config;
    }

    final dynamic addToApp = patrol['add_to_app'];
    if (addToApp != null && addToApp is bool) {
      config.addToApp = addToApp;
    }

    final dynamic appName = patrol['app_name'];
    if (appName != null && appName is String?) {
      androidConfig.appName = appName;
      iosConfig.appName = appName;
      macosConfig.appName = appName;
    }
    final dynamic flavor = patrol['flavor'];
    if (flavor != null && flavor is String?) {
      config.android.flavor = flavor;
      config.ios.flavor = flavor;
    }

    final dynamic testDirectory = patrol['test_directory'];
    if (testDirectory != null && testDirectory is String) {
      config.testDirectory = testDirectory;
    }

    final dynamic testFileSuffix = patrol['test_file_suffix'];
    if (testFileSuffix != null && testFileSuffix is String) {
      config.testFileSuffix = testFileSuffix;
    }

    final android = patrol['android'] as Map?;
    if (android != null) {
      config.android = androidConfig;

      final dynamic packageName = android['package_name'];
      if (packageName != null && packageName is String?) {
        androidConfig.packageName = packageName;
      }
      final dynamic appName = android['app_name'];
      if (appName != null && appName is String?) {
        androidConfig.appName = appName;
      }
      final dynamic flavor = android['flavor'];
      if (flavor != null && flavor is String?) {
        androidConfig.flavor = flavor;
      }
      final dynamic nativeProjectPath = android['native_project_path'];
      if (nativeProjectPath != null && nativeProjectPath is String?) {
        androidConfig.nativeProjectPath = nativeProjectPath;
      }
    }

    final ios = patrol['ios'] as Map?;
    if (ios != null) {
      config.ios = iosConfig;

      final dynamic bundleId = ios['bundle_id'];
      if (bundleId != null && bundleId is String?) {
        iosConfig.bundleId = bundleId;
      }
      final dynamic appName = ios['app_name'];
      if (appName != null && appName is String?) {
        iosConfig.appName = appName;
      }
      final dynamic flavor = ios['flavor'];
      if (flavor != null && flavor is String?) {
        iosConfig.flavor = flavor;
      }
      final dynamic nativeProjectPath = ios['native_project_path'];
      if (nativeProjectPath != null && nativeProjectPath is String?) {
        iosConfig.nativeProjectPath = nativeProjectPath;
      }
    }

    final macos = patrol['macos'] as Map?;
    if (macos != null) {
      config.macos = macosConfig;

      final dynamic bundleId = macos['bundle_id'];
      if (bundleId != null && bundleId is String?) {
        macosConfig.bundleId = bundleId;
      }
      final dynamic appName = macos['app_name'];
      if (appName != null && appName is String?) {
        macosConfig.appName = appName;
      }
      final dynamic flavor = macos['flavor'];
      if (flavor != null && flavor is String?) {
        macosConfig.flavor = flavor;
      }
    }

    return config;
  }
}
