import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/logging.dart';
import 'package:maestro_cli/src/maestro_config.dart';
import 'package:maestro_cli/src/paths.dart';

class BootstrapCommand extends Command<int> {
  @override
  String get name => 'bootstrap';

  @override
  String get description =>
      'Download artifacts and create default config file.';

  @override
  Future<int> run() async {
    final artifactPath = getArtifactPath();

    log.info('Downloading artifacts to $artifactPath ...');
    await Future<void>.delayed(const Duration(seconds: 1));

    log.info('Writing default config file...');
    final contents = MaestroConfig.defaultConfig().toToml();
    File('maestro.toml').writeAsStringSync(contents);

    return 0;
  }
}
