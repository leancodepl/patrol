import 'package:equatable/equatable.dart';
import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

class PatrolPubspecConfig with EquatableMixin {
  PatrolPubspecConfig({required this.android, required this.ios});

  PatrolPubspecConfig.empty()
      : this(
          android: AndroidPubspecConfig.empty(),
          ios: IOSPubspecConfig.empty(),
        );

  AndroidPubspecConfig android;
  IOSPubspecConfig ios;

  @override
  List<Object?> get props => [android, ios];
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

/// Reads Patrol CLI configuration block from pubspec.yaml.
class PubspecReader {
  PubspecReader({
    required Directory projectRoot,
  })  : _projectRoot = projectRoot,
        _fs = projectRoot.fileSystem;

  final Directory _projectRoot;
  final FileSystem _fs;

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
    final config = PatrolPubspecConfig(android: androidConfig, ios: iosConfig);

    final patrol = yaml['patrol'] as Map?;
    if (patrol == null) {
      return config;
    }

    final dynamic appName = patrol['app_name'];
    if (appName != null && appName is String?) {
      androidConfig.appName = appName;
      iosConfig.appName = appName;
    }
    final dynamic flavor = patrol['flavor'];
    if (flavor != null && flavor is String?) {
      config.android.flavor = flavor;
      config.ios.flavor = flavor;
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

    return config;
  }
}
