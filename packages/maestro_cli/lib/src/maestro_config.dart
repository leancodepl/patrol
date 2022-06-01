import 'package:toml/toml.dart';

class MaestroConfig {
  const MaestroConfig({
    required this.bootstrapConfig,
    required this.driveConfig,
  });

  factory MaestroConfig.defaultConfig() {
    return MaestroConfig(
      bootstrapConfig: BootstrapConfig.defaultConfig(),
      driveConfig: DriveConfig.defaultConfig(),
    );
  }

  factory MaestroConfig.fromToml(String toml) {
    final bootstrapConfig = BootstrapConfig.fromToml(toml);
    final driveConfig = DriveConfig.fromToml(toml);

    return MaestroConfig(
      bootstrapConfig: bootstrapConfig,
      driveConfig: driveConfig,
    );
  }

  final BootstrapConfig bootstrapConfig;
  final DriveConfig driveConfig;
}

class BootstrapConfig {
  const BootstrapConfig({required this.artifactPath});

  factory BootstrapConfig.fromToml(String toml) {
    final config = TomlDocument.parse(toml).toMap();

    final dynamic artifactPath = config['artifactPath'];

    if (artifactPath is! String) {
      throw ArgumentError('`artifactPath` field is not a string');
    }

    return BootstrapConfig(artifactPath: artifactPath);
  }

  factory BootstrapConfig.defaultConfig() {
    return const BootstrapConfig(artifactPath: r'$HOME/.maestro');
  }

  /// Directory to which artifacts will be downloaded.
  ///
  /// If the directory does not exist, it will be created.
  final String artifactPath;

  String toToml() {
    final config = {'artifactPath': artifactPath};

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

  factory DriveConfig.fromToml(String toml) {
    final config = TomlDocument.parse(toml).toMap();

    final dynamic host = config['host'];
    final dynamic port = config['port'];
    final dynamic target = config['target'];
    final dynamic driver = config['driver'];

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
      driver: 'test_driver/integration_test.dartt',
    );
  }

  final String host;
  final int port;
  final String target;
  final String driver;

  String toToml() {
    final config = {
      'host': host,
      'port': port,
      'target': target,
      'driver': driver,
    };

    return TomlDocument.fromMap(config).toString();
  }
}
