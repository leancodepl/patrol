import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/logging.dart';
import 'package:maestro_cli/src/common/paths.dart';
import 'package:maestro_cli/src/maestro_config.dart';

class BootstrapCommand extends Command<int> {
  @override
  String get name => 'bootstrap';

  @override
  String get description =>
      'Download artifacts and create default config file.';

  @override
  Future<int> run() async {
    log.info('Downloading artifacts to $artifactsPath ...');
    await Future<void>.delayed(const Duration(seconds: 1));

    log.info('Writing default config file...');
    final contents = MaestroConfig.defaultConfig().toToml();
    File('maestro.toml').writeAsStringSync(contents);

    return 0;
  }
}
