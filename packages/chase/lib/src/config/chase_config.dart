import 'package:meta/meta.dart';

/// Typed configuration model for chase.yaml.
@immutable
class ChaseConfig {
  const ChaseConfig({
    required this.version,
    required this.project,
    required this.apiKeys,
    required this.agent,
    required this.marathon,
    required this.git,
  });

  final int version;
  final ProjectConfig project;
  final ApiKeysConfig apiKeys;
  final AgentConfig agent;
  final MarathonConfig marathon;
  final GitConfig git;
}

@immutable
class ProjectConfig {
  const ProjectConfig({
    this.testDirectory = 'integration_test',
    this.baseBranch = 'main',
    this.exclude = const ['**/*.g.dart', '**/*.freezed.dart'],
  });

  final String testDirectory;
  final String baseBranch;
  final List<String> exclude;
}

@immutable
class ApiKeysConfig {
  const ApiKeysConfig({
    required this.claude,
    this.marathon,
    this.github,
  });

  final String claude;
  final String? marathon;
  final String? github;
}

@immutable
class AgentConfig {
  const AgentConfig({
    this.model = 'claude-sonnet-4-20250514',
    this.maxIterations = 10,
    this.temperature = 0.0,
    this.maxCostPerRun = 0.50,
    this.allowedCommands = const [
      'dart analyze',
      'dart format',
      'patrol build android',
      'patrol build ios',
    ],
    this.customInstructions,
  });

  final String model;
  final int maxIterations;
  final double temperature;
  final double maxCostPerRun;
  final List<String> allowedCommands;
  final String? customInstructions;
}

@immutable
class MarathonConfig {
  const MarathonConfig({
    this.platform = 'android',
    this.isolated = true,
    this.timeout = '30m',
  });

  final String platform;
  final bool isolated;
  final String timeout;
}

@immutable
class GitConfig {
  const GitConfig({
    this.branchPrefix = 'chase/',
    this.commitPrefix = '[chase]',
    this.autoPush = true,
    this.autoCreatePr = true,
  });

  final String branchPrefix;
  final String commitPrefix;
  final bool autoPush;
  final bool autoCreatePr;
}
