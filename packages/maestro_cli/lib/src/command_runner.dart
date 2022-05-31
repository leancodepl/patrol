import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:maestro_cli/src/commands/bootstrap_command.dart';
import 'package:maestro_cli/src/commands/drive_command.dart';

Future<int> maestroCommandRunner(List<String> args) async {
  final logger = Logger('maestr');

  Logger.root.onRecord.listen((event) {
    // ignore: avoid_print
    print(event.message);
  });

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
    logger.warning('Error: ${err.message}');

    exitCode = 1;
  }

  return exitCode;
}
