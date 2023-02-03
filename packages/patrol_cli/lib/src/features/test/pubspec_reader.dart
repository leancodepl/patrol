import 'package:file/file.dart';
import 'package:path/path.dart' show join;
import 'package:yaml/yaml.dart';

class PatrolPubspecConfig {
  PatrolPubspecConfig({this.android, this.ios});

  AndroidPubspecConfig? android;
  IOSPubspecConfig? ios;
}

class AndroidPubspecConfig {
  AndroidPubspecConfig({this.packageName, this.appName});
  String? packageName;
  String? appName;
}

class IOSPubspecConfig {
  IOSPubspecConfig({this.bundleId, this.appName});

  String? bundleId;
  String? appName;
}

/// Reads Patrol CLI configuration block from pubspec.yaml.
class PubspecReader {
  const PubspecReader({
    required Directory projectRoot,
    required FileSystem fs,
  })  : _projectRoot = projectRoot,
        _fs = fs;

  final Directory _projectRoot;
  final FileSystem _fs;

  PatrolPubspecConfig read() {
    final filePath = join(_projectRoot.path, 'pubspec.yaml');
    final file = _fs.file(filePath);

    if (!file.existsSync()) {
      throw FileSystemException("pubspec.yaml doesn't exist", filePath);
    }

    final contents = file.readAsStringSync();
    final yaml = loadYaml(contents) as Map;

    final config = PatrolPubspecConfig();
    final patrol = yaml['patrol'] as Map?;
    if (patrol != null) {
      final patrol = yaml['patrol'] as Map;
      final android = patrol['android'] as Map?;
      if (android != null) {
        final androidConfig = AndroidPubspecConfig();
        config.android = androidConfig;

        final dynamic packageName = android['package_name'];
        if (packageName != null && packageName is String?) {
          androidConfig.packageName = packageName;
        }
        final dynamic appName = android['app_name'];
        if (appName != null && appName is String?) {
          androidConfig.appName = appName;
        }
      }

      final ios = patrol['ios'] as Map?;
      if (ios != null) {
        final iosConfig = IOSPubspecConfig();
        config.ios = iosConfig;

        final dynamic bundleId = ios['bundle_id'];
        if (bundleId != null && bundleId is String?) {
          iosConfig.bundleId = bundleId;
        }
        final dynamic appName = ios['app_name'];
        if (appName != null && appName is String?) {
          iosConfig.appName = appName;
        }
      }
    }

    return config;
  }
}
