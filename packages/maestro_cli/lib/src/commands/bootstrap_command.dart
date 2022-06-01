import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/paths.dart';

class BootstrapCommand extends Command<int> {
  @override
  String get name => 'bootstrap';

  @override
  String get description =>
      'Prepares maestro by downloading artifacts and creating default config.';

  @override
  Future<int> run() async {
    final homePath = getHomePath();
    final pubCachePath = getApkInstallPath();

    print('boostrap running!');
    print('home directory: $homePath');
    print('pub cache: $pubCachePath');

    return 0;
  }
}
