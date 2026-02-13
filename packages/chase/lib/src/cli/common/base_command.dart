import 'package:args/command_runner.dart';

import '../../config/chase_config.dart';
import '../../config/config_loader.dart';
import 'cli_logger.dart';
import 'exit_codes.dart';

/// Base class for Chase commands with shared config loading.
abstract class BaseCommand extends Command<int> {
  BaseCommand({CliLogger? logger, ConfigLoader? configLoader})
      : logger = logger ?? CliLogger(),
        _configLoader = configLoader ?? const ConfigLoader();

  final CliLogger logger;
  final ConfigLoader _configLoader;

  ChaseConfig? _config;

  /// Loads the Chase config. Returns null and logs error if not found.
  Future<ChaseConfig?> loadConfig() async {
    if (_config != null) return _config;
    try {
      _config = await _configLoader.load();
      return _config;
    } on ConfigNotFoundException catch (e) {
      logger.error(e.message);
      return null;
    } on ConfigValidationException catch (e) {
      logger.error('Config error: $e');
      return null;
    }
  }

  /// Loads config or exits with error code.
  Future<ChaseConfig> requireConfig() async {
    final config = await loadConfig();
    if (config == null) {
      throw ConfigRequiredException();
    }
    return config;
  }
}

class ConfigRequiredException implements Exception {
  int get exitCode => ExitCodes.noConfig;
}
