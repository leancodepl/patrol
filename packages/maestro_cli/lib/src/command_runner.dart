import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/commands/bootstrap_command.dart';
import 'package:maestro_cli/src/commands/drive_command.dart';

Future<int> maestroCommandRunner(List<String> args) async {
  final runner = CommandRunner<int>(
    'maestro',
    'Tool for running Flutter-native UI tests with superpowers',
  )
    ..addCommand(BootstrapCommand())
    ..addCommand(DriveCommand());

  final exitCode = await runner.run(args);
  return exitCode ?? 0;
}
