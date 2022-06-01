import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/maestro_config.dart';
import 'package:maestro_cli/src/paths.dart';

class BootstrapCommand extends Command<int> {
  @override
  String get name => 'bootstrap';

  @override
  String get description => 'Downloading artifacts and creates default config.';

  @override
  Future<int> run() async {
    final homePath = getHomePath();
    final pubCachePath = getApkInstallPath();
    print('boostrap running!');
    print('home directory: $homePath');
    print('pub cache: $pubCachePath');

    final currentDirectory = Directory.current.path;
    final contents = MaestroConfig.defaultConfig().toToml();

    File('maestro.toml').writeAsStringSync(contents);

    return 0;
  }
}
