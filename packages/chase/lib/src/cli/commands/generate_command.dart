import '../../agent/chase_agent.dart';
import '../../analyzer/diff_analyzer.dart';
import '../../config/chase_config.dart';
import '../../context/context_builder.dart';
import '../../git/git_client.dart';
import '../../utils/cost_tracker.dart';
import '../../utils/process_runner.dart';
import '../common/base_command.dart';
import '../common/exit_codes.dart';

/// Core command: analyze diff and generate Patrol tests via AI agent.
class GenerateCommand extends BaseCommand {
  GenerateCommand({super.logger}) {
    argParser
      ..addOption(
        'base',
        abbr: 'b',
        help: 'Base branch for diff (overrides chase.yaml).',
      )
      ..addOption(
        'max-iterations',
        help: 'Maximum agent iterations (overrides chase.yaml).',
      )
      ..addFlag(
        'dry-run',
        help: 'Show what would be generated without writing files.',
        negatable: false,
      );
  }

  @override
  String get name => 'generate';

  @override
  String get description =>
      'Analyze diff and generate Patrol integration tests.';

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
    final maxIterations =
        int.tryParse(argResults!['max-iterations'] as String? ?? '') ??
            config.agent.maxIterations;
    final dryRun = argResults!['dry-run'] as bool;

    final processRunner = ProcessRunner();
    final gitClient = GitClient(processRunner: processRunner);
    final costTracker = CostTracker();

    // Step 1: Analyze diff
    logger.header('Analyzing Changes');
    final diffProgress = logger.progress('Computing diff against $baseBranch');

    final diffOutput = await gitClient.diff(baseBranch);
    if (diffOutput.isEmpty) {
      diffProgress.complete('No changes found');
      logger.info('No changes detected against $baseBranch. Nothing to do.');
      return ExitCodes.success;
    }

    final diffAnalyzer = DiffAnalyzer(excludePatterns: config.project.exclude);
    final diffResult = diffAnalyzer.analyze(diffOutput);
    diffProgress.complete(
      'Found ${diffResult.files.length} changed files',
    );

    for (final file in diffResult.files) {
      logger.detail('  ${file.changeType.name}: ${file.path}');
    }

    if (diffResult.files.isEmpty) {
      logger.info('All changed files were excluded. Nothing to do.');
      return ExitCodes.success;
    }

    // Step 2: Build context
    logger.header('Building Context');
    final contextProgress = logger.progress('Scanning project structure');

    final contextBuilder = ContextBuilder(
      projectRoot: gitClient.projectRoot,
      testDirectory: config.project.testDirectory,
    );
    final context = await contextBuilder.build(diffResult);
    contextProgress.complete('Context ready');

    logger.keyValue('Project', context.projectInfo.name);
    logger.keyValue('Existing tests', '${context.existingTests.length}');
    logger.keyValue(
      'Changed files requiring tests',
      '${context.prioritizedChanges.length}',
    );

    if (dryRun) {
      logger.info('');
      logger.info('Dry run mode — stopping before AI generation.');
      return ExitCodes.success;
    }

    // Step 3: Run AI agent
    logger.header('AI Test Generation');

    final agent = ChaseAgent(
      config: config,
      costTracker: costTracker,
      logger: logger,
    );

    final result = await agent.generate(
      context: context,
      maxIterations: maxIterations,
    );

    // Step 4: Report results
    logger.testFileTable(result.generatedFiles);
    logger.costSummary(
      apiCalls: costTracker.apiCalls,
      inputTokens: costTracker.inputTokens,
      outputTokens: costTracker.outputTokens,
      estimatedCost: costTracker.estimatedCost,
    );

    if (result.generatedFiles.isEmpty) {
      logger.warn('No test files were generated.');
      return ExitCodes.agentFailed;
    }

    logger.success(
      'Generated ${result.generatedFiles.length} test file(s).',
    );

    return ExitCodes.success;
  }
}
