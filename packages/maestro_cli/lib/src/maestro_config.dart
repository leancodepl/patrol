import 'package:toml/toml.dart';

class MaestroConfig {
  const MaestroConfig({required this.driveConfig});

  factory MaestroConfig.fromToml(String toml) {
    final config = TomlDocument.parse(toml).toMap();

    final dynamic driveConfig = config['drive'];

    if (driveConfig is! Map<String, dynamic>) {
      throw const FormatException('`drive` field is not a map');
    }

    return MaestroConfig(driveConfig: DriveConfig.fromMap(driveConfig));
  }

  factory MaestroConfig.defaultConfig() {
    return MaestroConfig(
      driveConfig: DriveConfig.defaultConfig(),
    );
  }

  final DriveConfig driveConfig;

  String toToml() {
    final config = {
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
    this.flavor,
  });

  factory DriveConfig.fromMap(Map<String, dynamic> toml) {
    final dynamic host = toml['host'];
    final dynamic port = toml['port'];
    final dynamic target = toml['target'];
    final dynamic driver = toml['driver'];
    final dynamic flavor = toml['flavor'];

    if (host is! String) {
      throw const FormatException('`host` field is not a string');
    }

    if (port is! int) {
      throw const FormatException('`port` field is not an int');
    }

    if (target is! String) {
      throw const FormatException('`target` field is not a string');
    }

    if (driver is! String) {
      throw const FormatException('`driver` field is not a string');
    }

    if (flavor != null) {
      if (flavor is! String) {
        throw const FormatException('`flavor` field is not a string');
      }
    }

    return DriveConfig(
      host: host,
      port: port,
      target: target,
      driver: driver,
      flavor: flavor as String?,
    );
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
  final String? flavor;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'host': host,
      'port': port,
      'target': target,
      'driver': driver,
      if (flavor != null) 'flavor': flavor,
    };
  }
}
