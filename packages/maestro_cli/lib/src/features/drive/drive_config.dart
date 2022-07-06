class DriveConfig {
  const DriveConfig({
    required this.host,
    required this.port,
    required this.target,
    required this.driver,
    this.flavor,
    this.dartDefines,
  });

  factory DriveConfig.fromMap(Map<String, dynamic> toml) {
    final dynamic host = toml['host'];
    final dynamic port = toml['port'];
    final dynamic target = toml['target'];
    final dynamic driver = toml['driver'];
    final dynamic flavor = toml['flavor'];
    final dynamic dartDefines = toml['dart-defines'];

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

    if (dartDefines != null) {
      if (dartDefines is! Map<String, dynamic>) {
        throw const FormatException('`dart-defines` field is not a map');
      }

      for (final dartDefine in dartDefines.entries) {
        if (dartDefine.value is! String) {
          throw const FormatException('`dart-define` value is not a string');
        }
      }
    }

    return DriveConfig(
      host: host,
      port: port,
      target: target,
      driver: driver,
      flavor: flavor as String?,
      dartDefines: (dartDefines as Map<String, dynamic>)
          .map((key, dynamic value) => MapEntry(key, value.toString())),
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
  final Map<String, String>? dartDefines;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'host': host,
      'port': port,
      'target': target,
      'driver': driver,
      if (flavor != null) 'flavor': flavor,
      if (dartDefines != null) 'dartDefines': dartDefines,
    };
  }
}
