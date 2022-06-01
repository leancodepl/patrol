import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/commands/bootstrap_command.dart';
import 'package:maestro_cli/src/commands/drive_command.dart';
import 'package:maestro_cli/src/logging.dart';

Future<int> maestroCommandRunner(List<String> args) async {
  final runner = MaestroCommandRunner();

  var exitCode = 0;
  try {
    exitCode = await runner.run(args) ?? 0;
  } on UsageException catch (err) {
    log.severe('Error: ${err.message}');
    exitCode = 1;
  }

  return exitCode;
}

class MaestroCommandRunner extends CommandRunner<int> {
  MaestroCommandRunner()
      : super(
          'maestro',
          'Tool for running Flutter-native UI tests with superpowers',
        ) {
    addCommand(BootstrapCommand());
    addCommand(DriveCommand());

    argParser.addFlag('verbose', abbr: 'v', help: 'Increase logging.');
  }

  @override
  Future<int?> run(Iterable<String> args) {
    final results = argParser.parse(args);
    final verbose = results['verbose'] as bool;
    setUpLogger(verbose: verbose);

    return super.run(args);
  }
}
