import '../../config/chase_config.dart';
import '../../runner/marathon_client.dart';
import '../../runner/patrol_builder.dart';
import '../../runner/result_reporter.dart';
import '../../utils/process_runner.dart';
import '../common/base_command.dart';
import '../common/exit_codes.dart';

/// Build and submit tests to Marathon Cloud.
class RunCommand extends BaseCommand {
  RunCommand({super.logger}) {
    argParser.addOption(
      'platform',
      abbr: 'p',
      help: 'Target platform (overrides chase.yaml).',
      allowed: ['android', 'ios'],
    );
  }

  @override
  String get name => 'run';

  @override
  String get description =>
      'Build tests and submit to Marathon Cloud for execution.';

  @override
  Future<int> run() async {
    ChaseConfig config;
    try {
      config = await requireConfig();
    } on ConfigRequiredException {
      return ExitCodes.noConfig;
    }

    final platform =
        argResults!['platform'] as String? ?? config.marathon.platform;

    final processRunner = ProcessRunner();

    // Step 1: Build test artifacts
    logger.header('Building Tests');
    final buildProgress = logger.progress('Running patrol build $platform');

    final builder = PatrolBuilder(processRunner: processRunner);
    final buildResult = await builder.build(platform: platform);

    if (!buildResult.success) {
      buildProgress.fail('Build failed');
      logger.error(buildResult.error ?? 'Unknown build error');
      return ExitCodes.marathonFailed;
    }
    buildProgress.complete('Build succeeded');

    // Step 2: Submit to Marathon Cloud
    logger.header('Marathon Cloud');
    final marathonProgress = logger.progress('Submitting to Marathon Cloud');

    final marathonApiKey = config.apiKeys.marathon;
    if (marathonApiKey == null || marathonApiKey.isEmpty) {
      marathonProgress.fail('Marathon API key not configured');
      logger.error(
        'Set MARATHON_CLOUD_API_KEY or configure api_keys.marathon in chase.yaml',
      );
      return ExitCodes.config;
    }

    final marathon = MarathonClient(
      processRunner: processRunner,
      apiKey: marathonApiKey,
    );

    final runResult = await marathon.run(
      platform: platform,
      applicationPath: buildResult.applicationPath!,
      testApplicationPath: buildResult.testApplicationPath!,
      isolated: config.marathon.isolated,
      timeout: config.marathon.timeout,
    );

    if (!runResult.success) {
      marathonProgress.fail('Marathon Cloud run failed');
      logger.error(runResult.error ?? 'Unknown Marathon error');
      return ExitCodes.marathonFailed;
    }
    marathonProgress.complete('Tests completed');

    // Step 3: Report results
    final reporter = ResultReporter(logger: logger);
    reporter.reportMarathonResults(runResult);

    return ExitCodes.success;
  }
}
