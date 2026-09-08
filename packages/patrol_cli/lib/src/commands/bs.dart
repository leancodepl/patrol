import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/bs_pull_coverage.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Parent command grouping BrowserStack-specific subcommands.
class BsCommand extends PatrolCommand {
  BsCommand({required Logger logger, required FileSystem fs}) {
    addSubcommand(BsPullCoverageCommand(logger: logger, fs: fs));
  }

  @override
  String get name => 'bs';

  @override
  String get description => 'BrowserStack-specific utilities.';
}
