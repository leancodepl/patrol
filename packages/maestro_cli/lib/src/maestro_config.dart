import 'package:toml/toml.dart';

class MaestroConfig {
  const MaestroConfig({
    required this.artifactPath,
    required this.driveConfig,
  });

  factory MaestroConfig.fromToml(String toml) {
    final config = TomlDocument.parse(toml).toMap();

    final dynamic artifactPath = config['artifact_path'];
    final dynamic driveConfig = config['drive'];

    if (artifactPath is! String) {
      throw ArgumentError('`artifact_path` field is not a string');
    }

    if (driveConfig is! Map<String, dynamic>) {
      throw ArgumentError('`drive` field is not a map');
    }

    return MaestroConfig(
      artifactPath: artifactPath,
      driveConfig: DriveConfig.fromMap(driveConfig),
    );
  }

  factory MaestroConfig.defaultConfig() {
    return MaestroConfig(
      artifactPath: r'$HOME/.maestro',
      driveConfig: DriveConfig.defaultConfig(),
    );
  }

  /// Directory to which artifacts will be downloaded.
  ///
  /// If the directory does not exist, it will be created.
  final String artifactPath;
  final DriveConfig driveConfig;

  String toToml() {
    final config = {
      'artifact_path': artifactPath,
      'drive': driveConfig.toMap(),
    };

    return TomlDocument.fromMap(config).toString();
  }
}

class DriveConfig {
  const DriveConfig({
    required this.host,
    required this.port,
    required this.target,
    required this.driver,
  });

  factory DriveConfig.fromMap(Map<String, dynamic> toml) {
    final dynamic host = toml['host'];
    final dynamic port = toml['port'];
    final dynamic target = toml['target'];
    final dynamic driver = toml['driver'];

    if (host is! String) {
      throw ArgumentError('`host` field is not a string');
    }

    if (port is! int) {
      throw ArgumentError('`port` field is not an int');
    }

    if (target is! String) {
      throw ArgumentError('`target` field is not a string');
    }

    if (driver is! String) {
      throw ArgumentError('`driver` field is not a string');
    }

    return DriveConfig(host: host, port: port, target: target, driver: driver);
  }

  factory DriveConfig.defaultConfig() {
    return const DriveConfig(
      host: 'localhost',
      port: 8081,
      target: 'integration_test/app_test.dart',
      driver: 'test_driver/integration_test.dart',
    );
  }

  final String host;
  final int port;
  final String target;
  final String driver;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'host': host,
      'port': port,
      'target': target,
      'driver': driver,
    };
  }
}
