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
    this.testFileSuffix = '_test.dart',
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
  String testFileSuffix;

  @override
  List<Object?> get props => [android, ios, macos, testFileSuffix];
}

class AndroidPubspecConfig with EquatableMixin {
  AndroidPubspecConfig({this.packageName, this.appName, this.flavor});

  AndroidPubspecConfig.empty()
      : this(
          packageName: null,
          appName: null,
          flavor: null,
        );

  String? packageName;
  String? appName;
  String? flavor;

  @override
  List<Object?> get props => [packageName, appName, flavor];
}

class IOSPubspecConfig with EquatableMixin {
  IOSPubspecConfig({this.bundleId, this.appName, this.flavor});

  IOSPubspecConfig.empty()
      : this(
          bundleId: null,
          appName: null,
          flavor: null,
        );

  String? bundleId;
  String? appName;
  String? flavor;

  @override
  List<Object?> get props => [bundleId, appName, flavor];
}

class MacOSPubspecConfig with EquatableMixin {
  MacOSPubspecConfig({this.bundleId, this.appName, this.flavor});

  MacOSPubspecConfig.empty()
      : this(
          bundleId: null,
          appName: null,
          flavor: null,
        );

  String? bundleId;
  String? appName;
  String? flavor;

  @override
  List<Object?> get props => [bundleId, appName, flavor];
}

/// Reads Patrol CLI configuration block from pubspec.yaml.
class PubspecReader {
  PubspecReader({
    required Directory projectRoot,
  })  : _projectRoot = projectRoot,
        _fs = projectRoot.fileSystem;

  final Directory _projectRoot;
  final FileSystem _fs;

  /// Gets the patrol package version from pubspec.yaml dependencies
  String? getPatrolVersion() {
    final filePath = _fs.path.join(_projectRoot.path, 'pubspec.yaml');
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

      // Check both dependencies and dev_dependencies
      final dependencies = yaml['dependencies'] as Map?;
      final devDependencies = yaml['dev_dependencies'] as Map?;

      // Try to find patrol in dependencies first
      final patrol = dependencies?['patrol'] ?? devDependencies?['patrol'];
      if (patrol == null) {
        return null;
      }

      // Handle different dependency formats
      if (patrol is String || patrol is num) {
        // Direct version (e.g., patrol: ^1.0.0, patrol: 3.15.1-dev.1, patrol: 3.15.1+1)
        return patrol.toString().replaceAll(RegExp(r'[\^~]'), '');
      } else if (patrol is Map) {
        // Hosted dependency (e.g., patrol: {version: ^1.0.0})
        // Git dependency (e.g., patrol: {git: {url: ..., ref: ...}})
        if (patrol['version'] != null) {
          return patrol['version'].toString().replaceAll(RegExp(r'[\^~]'), '');
        } else if (patrol['git'] != null && patrol['git'] is Map) {
          final git = patrol['git'] as Map;
          if (git['ref'] != null) {
            return git['ref'].toString();
          }
        }
      }

      return null;
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

    final androidConfig = AndroidPubspecConfig();
    final iosConfig = IOSPubspecConfig();
    final macosConfig = MacOSPubspecConfig();
    final config = PatrolPubspecConfig(
      flutterPackageName: yaml['name'] as String,
      android: androidConfig,
      ios: iosConfig,
      macos: macosConfig,
    );

    final patrol = yaml['patrol'] as Map?;
    if (patrol == null) {
      return config;
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
