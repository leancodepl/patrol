import '../../config/chase_config.dart';
import '../../runner/marathon_client.dart';
import '../../utils/process_runner.dart';
import '../common/base_command.dart';
import '../common/exit_codes.dart';

/// Check Marathon Cloud run status.
class StatusCommand extends BaseCommand {
  StatusCommand({super.logger}) {
    argParser.addOption(
      'run-id',
      help: 'Marathon Cloud run ID to check.',
    );
  }

  @override
  String get name => 'status';

  @override
  String get description => 'Check Marathon Cloud run status.';

  @override
  Future<int> run() async {
    ChaseConfig config;
    try {
      config = await requireConfig();
    } on ConfigRequiredException {
      return ExitCodes.noConfig;
    }

    final runId = argResults!['run-id'] as String?;

    final marathonApiKey = config.apiKeys.marathon;
    if (marathonApiKey == null || marathonApiKey.isEmpty) {
      logger.error(
        'Marathon API key not configured. '
        'Set MARATHON_CLOUD_API_KEY or configure api_keys.marathon.',
      );
      return ExitCodes.config;
    }

    final marathon = MarathonClient(
      processRunner: const ProcessRunner(),
      apiKey: marathonApiKey,
    );

    final progress = logger.progress('Checking run status');

    try {
      final status = await marathon.status(runId: runId);
      progress.complete('Status retrieved');
      logger.info('');
      logger.keyValue('Run ID', status.runId);
      logger.keyValue('Status', status.status);
      logger.keyValue('Passed', '${status.passed}');
      logger.keyValue('Failed', '${status.failed}');
      logger.keyValue('Skipped', '${status.skipped}');
      return ExitCodes.success;
    } on Exception catch (e) {
      progress.fail('Failed to get status');
      logger.error('$e');
      return ExitCodes.marathonFailed;
    }
  }
}
