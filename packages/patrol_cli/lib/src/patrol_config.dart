import 'package:patrol_cli/src/features/drive/drive_config.dart';
import 'package:toml/toml.dart';

class PatrolConfig {
  const PatrolConfig({required this.driveConfig});

  factory PatrolConfig.fromToml(String toml) {
    final config = TomlDocument.parse(toml).toMap();

    final dynamic driveConfig = config['drive'];

    if (driveConfig is! Map<String, dynamic>) {
      throw const FormatException('`drive` field is not a map');
    }

    return PatrolConfig(driveConfig: DriveConfig.fromMap(driveConfig));
  }

  factory PatrolConfig.defaultConfig() {
    return PatrolConfig(
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
