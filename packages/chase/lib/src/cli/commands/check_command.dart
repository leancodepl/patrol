import '../../config/chase_config.dart';
import '../../runner/local_validator.dart';
import '../../utils/process_runner.dart';
import '../common/base_command.dart';
import '../common/exit_codes.dart';

/// Local validation command: runs dart analyze on generated tests.
class CheckCommand extends BaseCommand {
  CheckCommand({super.logger});

  @override
  String get name => 'check';

  @override
  String get description => 'Validate generated tests with dart analyze.';

  @override
  Future<int> run() async {
    ChaseConfig config;
    try {
      config = await requireConfig();
    } on ConfigRequiredException {
      return ExitCodes.noConfig;
    }

    logger.header('Validating Tests');

    final validator = LocalValidator(
      processRunner: const ProcessRunner(),
      testDirectory: config.project.testDirectory,
    );

    final progress = logger.progress('Running dart analyze');
    final result = await validator.validate();

    if (result.isValid) {
      progress.complete('All tests pass analysis');
      logger.success('No issues found.');
      return ExitCodes.success;
    } else {
      progress.fail('Analysis found issues');
      logger.error('');
      for (final issue in result.issues) {
        logger.error('  $issue');
      }
      logger.error('');
      logger.error('${result.issues.length} issue(s) found.');
      return ExitCodes.validationFailed;
    }
  }
}
