import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/commands/bootstrap_command.dart';
import 'package:maestro_cli/src/commands/drive_command.dart';
import 'package:maestro_cli/src/logging.dart';

Future<int> maestroCommandRunner(List<String> args) async {
  final runner = CommandRunner<int>(
    'maestro',
    'Tool for running Flutter-native UI tests with superpowers',
  )
    ..addCommand(BootstrapCommand())
    ..addCommand(DriveCommand());

  var exitCode = 0;
  try {
    exitCode = await runner.run(args) ?? 0;
  } on UsageException catch (err) {
    error('Error: ${err.message}');

    exitCode = 1;
  }

  return exitCode;
}
