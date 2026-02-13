import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'commands/check_command.dart';
import 'commands/full_command.dart';
import 'commands/generate_command.dart';
import 'commands/init_command.dart';
import 'commands/run_command.dart';
import 'commands/status_command.dart';
import 'common/cli_logger.dart';
import 'common/exit_codes.dart';

/// Main command runner for the Chase CLI.
class ChaseCommandRunner extends CommandRunner<int> {
  ChaseCommandRunner({CliLogger? logger})
      : _logger = logger ?? CliLogger(),
        super(
          'chase',
          'AI-powered Patrol test generation for Flutter',
        ) {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose output.',
      negatable: false,
    );
    argParser.addFlag(
      'version',
      help: 'Print the current version.',
      negatable: false,
    );

    addCommand(InitCommand(logger: _logger));
    addCommand(GenerateCommand(logger: _logger));
    addCommand(RunCommand(logger: _logger));
    addCommand(CheckCommand(logger: _logger));
    addCommand(StatusCommand(logger: _logger));
    addCommand(FullCommand(logger: _logger));
  }

  final CliLogger _logger;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final results = parse(args);
      return await runCommand(results) ?? ExitCodes.success;
    } on FormatException catch (e) {
      _logger.error(e.message);
      _logger.info('');
      _logger.info(usage);
      return ExitCodes.usage;
    } on UsageException catch (e) {
      _logger.error(e.message);
      _logger.info('');
      _logger.info(e.usage);
      return ExitCodes.usage;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] as bool) {
      _logger.info('chase 0.1.0');
      return ExitCodes.success;
    }

    return super.runCommand(topLevelResults);
  }
}
