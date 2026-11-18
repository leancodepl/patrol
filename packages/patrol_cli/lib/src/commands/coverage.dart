import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/coverage_pull.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

/// Parent command for coverage collected on device farms.
class CoverageCommand extends PatrolCommand {
  CoverageCommand({required Logger logger, required FileSystem fs}) {
    addSubcommand(CoveragePullCommand(logger: logger, fs: fs));
  }

  @override
  String get name => 'coverage';

  @override
  String get docsName => 'coverage';

  @override
  String get description =>
      'Work with Dart coverage collected on Android device farms.';
}
