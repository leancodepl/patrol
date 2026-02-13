import 'dart:io';

import 'package:path/path.dart' as p;

import '../common/base_command.dart';
import '../common/exit_codes.dart';

/// Interactive setup command that generates chase.yaml.
class InitCommand extends BaseCommand {
  InitCommand({super.logger}) {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing chase.yaml.',
      negatable: false,
    );
  }

  @override
  String get name => 'init';

  @override
  String get description => 'Initialize Chase configuration (creates chase.yaml).';

  @override
  Future<int> run() async {
    final force = argResults!['force'] as bool;
    final configPath = p.join(Directory.current.path, 'chase.yaml');
    final configFile = File(configPath);

    if (configFile.existsSync() && !force) {
      logger.warn('chase.yaml already exists. Use --force to overwrite.');
      return ExitCodes.config;
    }

    logger.header('Chase Setup');

    final baseBranch = logger.prompt(
      'Base branch for diff comparison',
      defaultValue: 'main',
    );

    final testDirectory = logger.prompt(
      'Integration test directory',
      defaultValue: 'integration_test',
    );

    final model = logger.chooseOne(
      'Claude model to use',
      choices: [
        'claude-sonnet-4-20250514',
        'claude-haiku-4-20250514',
      ],
      defaultValue: 'claude-sonnet-4-20250514',
    );

    final platform = logger.chooseOne(
      'Target platform for Marathon Cloud',
      choices: ['android', 'ios', 'both'],
      defaultValue: 'android',
    );

    final customInstructions = logger.prompt(
      'Custom instructions for AI (e.g., state management, architecture)',
      defaultValue: '',
    );

    final config = _buildConfig(
      baseBranch: baseBranch,
      testDirectory: testDirectory,
      model: model,
      platform: platform,
      customInstructions:
          customInstructions.isEmpty ? null : customInstructions,
    );

    await configFile.writeAsString(config);
    logger.success('Created chase.yaml');
    logger.info('');
    logger.info('Next steps:');
    logger.info('  1. Set CHASE_CLAUDE_API_KEY environment variable');
    logger.info('  2. Run `chase generate` to generate tests');

    return ExitCodes.success;
  }

  String _buildConfig({
    required String baseBranch,
    required String testDirectory,
    required String model,
    required String platform,
    String? customInstructions,
  }) {
    final buffer = StringBuffer()
      ..writeln('version: 1')
      ..writeln()
      ..writeln('project:')
      ..writeln('  test_directory: $testDirectory')
      ..writeln('  base_branch: $baseBranch')
      ..writeln('  exclude:')
      ..writeln('    - "**/*.g.dart"')
      ..writeln('    - "**/*.freezed.dart"')
      ..writeln()
      ..writeln('api_keys:')
      ..writeln('  claude: \${CHASE_CLAUDE_API_KEY}')
      ..writeln('  marathon: \${MARATHON_CLOUD_API_KEY}')
      ..writeln('  github: \${GITHUB_TOKEN}')
      ..writeln()
      ..writeln('agent:')
      ..writeln('  model: $model')
      ..writeln('  max_iterations: 10')
      ..writeln('  temperature: 0.0')
      ..writeln('  max_cost_per_run: 0.50')
      ..writeln('  allowed_commands:')
      ..writeln('    - dart analyze')
      ..writeln('    - dart format')
      ..writeln('    - patrol build android')
      ..writeln('    - patrol build ios');

    if (customInstructions != null) {
      buffer
        ..writeln('  custom_instructions: |')
        ..writeln('    $customInstructions');
    }

    buffer
      ..writeln()
      ..writeln('marathon:')
      ..writeln('  platform: $platform')
      ..writeln('  isolated: true')
      ..writeln('  timeout: 30m')
      ..writeln()
      ..writeln('git:')
      ..writeln('  branch_prefix: "chase/"')
      ..writeln('  commit_prefix: "[chase]"')
      ..writeln('  auto_push: true')
      ..writeln('  auto_create_pr: true');

    return buffer.toString();
  }
}
