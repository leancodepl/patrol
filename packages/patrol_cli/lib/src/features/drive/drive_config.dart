class DriveConfig {
  const DriveConfig({
    required this.host,
    required this.port,
    required this.target,
    required this.driver,
    required this.flavor,
    required this.dartDefines,
    required this.packageName,
    required this.bundleId,
  });

  factory DriveConfig.fromMap(Map<String, dynamic> toml) {
    final dynamic host = toml['host'];
    final dynamic port = toml['port'];
    final dynamic target = toml['target'];
    final dynamic driver = toml['driver'];
    final dynamic flavor = toml['flavor'];
    final dynamic dartDefines = toml['dart-defines'];
    final dynamic packageName = toml['packageName'];
    final dynamic bundleId = toml['bundleId'];

    if (port != null && host is! String) {
      throw const FormatException('`host` field is not a string');
    }

    if (port != null && port is! String) {
      throw const FormatException('`port` field is not an string');
    }

    if (target != null && target is! String) {
      throw const FormatException('`target` field is not a string');
    }

    if (driver != null && driver is! String) {
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

    if (packageName != null && packageName is! String) {
      throw const FormatException('`packageName` field is not a string');
    }

    if (bundleId != null && bundleId is! String) {
      throw const FormatException('`bundleId` field is not a string');
    }

    return DriveConfig(
      host: host as String?,
      port: port as String?,
      target: target as String?,
      driver: driver as String?,
      flavor: flavor as String?,
      dartDefines: (dartDefines as Map<String, dynamic>?)
          ?.map((key, dynamic value) => MapEntry(key, value.toString())),
      packageName: packageName as String?,
      bundleId: bundleId as String?,
    );
  }

  factory DriveConfig.defaultConfig() {
    return const DriveConfig(
      host: null,
      port: null,
      target: 'integration_test/app_test.dart',
      driver: 'test_driver/integration_test.dart',
      flavor: null,
      dartDefines: {},
      packageName: null,
      bundleId: null,
    );
  }

  final String? host;
  final String? port;
  final String? target;
  final String? driver;
  final String? flavor;
  final Map<String, String>? dartDefines;
  final String? packageName;
  final String? bundleId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (target != null) 'target': target,
      if (driver != null) 'driver': driver,
      if (flavor != null) 'flavor': flavor,
      if (dartDefines != null) 'dartDefines': dartDefines,
    };
  }
}
