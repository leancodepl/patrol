import 'package:args/command_runner.dart';

class BootstrapCommand extends Command<int> {
  @override
  String get name => 'bootstrap';

  @override
  String get description =>
      'Prepares maestro by downloading artifacts and creating default config.';

  @override
  Future<int> run() async {
    print('boostrap running!');

    return 0;
  }
}
