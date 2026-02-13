import '../../agent/chase_agent.dart';
import '../../analyzer/diff_analyzer.dart';
import '../../config/chase_config.dart';
import '../../context/context_builder.dart';
import '../../git/git_client.dart';
import '../../git/pr_manager.dart';
import '../../runner/local_validator.dart';
import '../../runner/marathon_client.dart';
import '../../runner/patrol_builder.dart';
import '../../runner/result_reporter.dart';
import '../../utils/cost_tracker.dart';
import '../../utils/process_runner.dart';
import '../common/base_command.dart';
import '../common/exit_codes.dart';

/// Full pipeline: generate + check + run + create PR.
class FullCommand extends BaseCommand {
  FullCommand({super.logger}) {
    argParser
      ..addOption(
        'base',
        abbr: 'b',
        help: 'Base branch for diff (overrides chase.yaml).',
      )
      ..addFlag(
        'skip-marathon',
        help: 'Skip Marathon Cloud submission.',
        negatable: false,
      )
      ..addFlag(
        'skip-pr',
        help: 'Skip PR creation.',
        negatable: false,
      );
  }

  @override
  String get name => 'full';

  @override
  String get description =>
      'Full pipeline: generate tests, validate, run on Marathon Cloud, and create PR.';

  @override
  Future<int> run() async {
    ChaseConfig config;
    try {
      config = await requireConfig();
    } on ConfigRequiredException {
      return ExitCodes.noConfig;
    }

    final baseBranch =
        argResults!['base'] as String? ?? config.project.baseBranch;
    final skipMarathon = argResults!['skip-marathon'] as bool;
    final skipPr = argResults!['skip-pr'] as bool;

    final processRunner = ProcessRunner();
    final gitClient = GitClient(processRunner: processRunner);
    final costTracker = CostTracker();

    // Step 1: Analyze diff
    logger.header('Step 1: Analyzing Changes');
    final diffOutput = await gitClient.diff(baseBranch);
    if (diffOutput.isEmpty) {
      logger.info('No changes detected. Nothing to do.');
      return ExitCodes.success;
    }

    final diffAnalyzer = DiffAnalyzer(excludePatterns: config.project.exclude);
    final diffResult = diffAnalyzer.analyze(diffOutput);

    if (diffResult.files.isEmpty) {
      logger.info('All changes excluded. Nothing to do.');
      return ExitCodes.success;
    }

    logger.success(
      'Found ${diffResult.files.length} changed file(s)',
    );

    // Step 2: Build context
    logger.header('Step 2: Building Context');
    final contextBuilder = ContextBuilder(
      projectRoot: gitClient.projectRoot,
      testDirectory: config.project.testDirectory,
    );
    final context = await contextBuilder.build(diffResult);
    logger.success('Context ready');

    // Step 3: Generate tests
    logger.header('Step 3: AI Test Generation');
    final agent = ChaseAgent(
      config: config,
      costTracker: costTracker,
      logger: logger,
    );

    final genResult = await agent.generate(context: context);
    if (genResult.generatedFiles.isEmpty) {
      logger.warn('No tests generated. Stopping.');
      return ExitCodes.agentFailed;
    }

    logger.testFileTable(genResult.generatedFiles);

    // Step 4: Validate
    logger.header('Step 4: Validation');
    final validator = LocalValidator(
      processRunner: processRunner,
      testDirectory: config.project.testDirectory,
    );
    final validationResult = await validator.validate();

    if (!validationResult.isValid) {
      logger.warn('Validation found issues:');
      for (final issue in validationResult.issues) {
        logger.error('  $issue');
      }
      // Continue anyway — tests might still be runnable
    } else {
      logger.success('Validation passed');
    }

    // Step 5: Marathon Cloud (optional)
    if (!skipMarathon) {
      logger.header('Step 5: Marathon Cloud');
      final marathonApiKey = config.apiKeys.marathon;
      if (marathonApiKey == null || marathonApiKey.isEmpty) {
        logger.warn(
          'Marathon API key not set. Skipping Marathon Cloud.',
        );
      } else {
        final builder = PatrolBuilder(processRunner: processRunner);
        final buildResult = await builder.build(
          platform: config.marathon.platform,
        );

        if (buildResult.success) {
          final marathon = MarathonClient(
            processRunner: processRunner,
            apiKey: marathonApiKey,
          );
          final runResult = await marathon.run(
            platform: config.marathon.platform,
            applicationPath: buildResult.applicationPath!,
            testApplicationPath: buildResult.testApplicationPath!,
            isolated: config.marathon.isolated,
            timeout: config.marathon.timeout,
          );
          final reporter = ResultReporter(logger: logger);
          reporter.reportMarathonResults(runResult);
        } else {
          logger.warn('Build failed: ${buildResult.error}');
        }
      }
    }

    // Step 6: Create PR (optional)
    if (!skipPr) {
      logger.header('Step 6: Creating PR');
      final githubToken = config.apiKeys.github;
      if (githubToken == null || githubToken.isEmpty) {
        logger.warn('GitHub token not set. Skipping PR creation.');
      } else {
        final prManager = PrManager(
          gitClient: gitClient,
          config: config,
          logger: logger,
        );

        final prResult = await prManager.createTestPr(
          generatedFiles: genResult.generatedFiles,
          summary: genResult.summary,
          costSummary: costTracker.summary,
        );

        if (prResult != null) {
          logger.success('PR created: $prResult');
        } else {
          logger.warn('Failed to create PR.');
        }
      }
    }

    // Summary
    logger.costSummary(
      apiCalls: costTracker.apiCalls,
      inputTokens: costTracker.inputTokens,
      outputTokens: costTracker.outputTokens,
      estimatedCost: costTracker.estimatedCost,
    );

    logger.success('Full pipeline complete!');
    return ExitCodes.success;
  }
}
