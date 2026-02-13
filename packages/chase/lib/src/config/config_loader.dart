import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'chase_config.dart';
import 'secrets.dart';

/// Loads and parses chase.yaml configuration.
class ConfigLoader {
  const ConfigLoader({this.secretResolver = const SecretResolver()});

  final SecretResolver secretResolver;

  /// Finds and loads chase.yaml from [directory] or its ancestors.
  Future<ChaseConfig> load({String? directory}) async {
    final configFile = _findConfigFile(directory ?? Directory.current.path);
    if (configFile == null) {
      throw ConfigNotFoundException(
        'chase.yaml not found. Run `chase init` to create one.',
      );
    }

    final content = await configFile.readAsString();
    final yaml = loadYaml(content) as YamlMap;
    return _parseConfig(yaml);
  }

  /// Checks if a chase.yaml file exists in [directory] or its ancestors.
  bool exists({String? directory}) {
    return _findConfigFile(directory ?? Directory.current.path) != null;
  }

  File? _findConfigFile(String directory) {
    var current = directory;
    while (true) {
      final file = File(p.join(current, 'chase.yaml'));
      if (file.existsSync()) return file;
      final parent = p.dirname(current);
      if (parent == current) return null;
      current = parent;
    }
  }

  ChaseConfig _parseConfig(YamlMap yaml) {
    final version = yaml['version'] as int? ?? 1;

    final projectYaml = yaml['project'] as YamlMap?;
    final apiKeysYaml = yaml['api_keys'] as YamlMap?;
    final agentYaml = yaml['agent'] as YamlMap?;
    final marathonYaml = yaml['marathon'] as YamlMap?;
    final gitYaml = yaml['git'] as YamlMap?;

    return ChaseConfig(
      version: version,
      project: _parseProject(projectYaml),
      apiKeys: _parseApiKeys(apiKeysYaml),
      agent: _parseAgent(agentYaml),
      marathon: _parseMarathon(marathonYaml),
      git: _parseGit(gitYaml),
    );
  }

  ProjectConfig _parseProject(YamlMap? yaml) {
    if (yaml == null) return const ProjectConfig();
    return ProjectConfig(
      testDirectory:
          yaml['test_directory'] as String? ?? 'integration_test',
      baseBranch: yaml['base_branch'] as String? ?? 'main',
      exclude: _toStringList(yaml['exclude']) ??
          const ['**/*.g.dart', '**/*.freezed.dart'],
    );
  }

  ApiKeysConfig _parseApiKeys(YamlMap? yaml) {
    if (yaml == null) {
      throw ConfigValidationException(
        'api_keys.claude is required in chase.yaml',
      );
    }

    final claudeKey = secretResolver.resolve(yaml['claude'] as String? ?? '');
    if (claudeKey.isEmpty) {
      throw ConfigValidationException(
        'api_keys.claude is required. Set CHASE_CLAUDE_API_KEY or provide it directly.',
      );
    }

    return ApiKeysConfig(
      claude: claudeKey,
      marathon: _resolveOptional(yaml['marathon'] as String?),
      github: _resolveOptional(yaml['github'] as String?),
    );
  }

  AgentConfig _parseAgent(YamlMap? yaml) {
    if (yaml == null) return const AgentConfig();
    return AgentConfig(
      model: yaml['model'] as String? ?? 'claude-sonnet-4-20250514',
      maxIterations: yaml['max_iterations'] as int? ?? 10,
      temperature: (yaml['temperature'] as num?)?.toDouble() ?? 0.0,
      maxCostPerRun: (yaml['max_cost_per_run'] as num?)?.toDouble() ?? 0.50,
      allowedCommands: _toStringList(yaml['allowed_commands']) ??
          const [
            'dart analyze',
            'dart format',
            'patrol build android',
            'patrol build ios',
          ],
      customInstructions: yaml['custom_instructions'] as String?,
    );
  }

  MarathonConfig _parseMarathon(YamlMap? yaml) {
    if (yaml == null) return const MarathonConfig();
    return MarathonConfig(
      platform: yaml['platform'] as String? ?? 'android',
      isolated: yaml['isolated'] as bool? ?? true,
      timeout: yaml['timeout'] as String? ?? '30m',
    );
  }

  GitConfig _parseGit(YamlMap? yaml) {
    if (yaml == null) return const GitConfig();
    return GitConfig(
      branchPrefix: yaml['branch_prefix'] as String? ?? 'chase/',
      commitPrefix: yaml['commit_prefix'] as String? ?? '[chase]',
      autoPush: yaml['auto_push'] as bool? ?? true,
      autoCreatePr: yaml['auto_create_pr'] as bool? ?? true,
    );
  }

  String? _resolveOptional(String? value) {
    if (value == null || value.isEmpty) return null;
    final resolved = secretResolver.resolve(value);
    return resolved.isEmpty ? null : resolved;
  }

  List<String>? _toStringList(dynamic value) {
    if (value == null) return null;
    if (value is YamlList) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }
}

class ConfigNotFoundException implements Exception {
  const ConfigNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ConfigValidationException implements Exception {
  const ConfigValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
