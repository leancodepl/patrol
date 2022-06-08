import 'package:maestro_cli/src/features/drive/drive_config.dart';
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
