import 'package:meta/meta.dart';

import '../analyzer/change_classifier.dart';
import '../analyzer/diff_models.dart';

/// Complete context assembled for the AI agent.
@immutable
class AgentContext {
  const AgentContext({
    required this.projectInfo,
    required this.diffResult,
    required this.prioritizedChanges,
    required this.existingTests,
    required this.sourceFiles,
    this.patrolVersion,
  });

  final ProjectInfo projectInfo;
  final DiffResult diffResult;
  final List<PrioritizedChange> prioritizedChanges;
  final List<ExistingTest> existingTests;
  final Map<String, String> sourceFiles; // path → content
  final String? patrolVersion;
}

/// Information about the Flutter project.
@immutable
class ProjectInfo {
  const ProjectInfo({
    required this.name,
    required this.rootPath,
    this.stateManagement,
    this.router,
    this.dependencies = const [],
  });

  final String name;
  final String rootPath;
  final String? stateManagement;
  final String? router;
  final List<String> dependencies;
}

/// A prioritized change for the AI agent to consider.
@immutable
class PrioritizedChange {
  const PrioritizedChange({
    required this.file,
    required this.category,
    required this.score,
    this.sourceContent,
    this.existingTestPath,
    this.existingTestContent,
  });

  final FileDiff file;
  final ChangeCategory category;
  final double score;
  final String? sourceContent;
  final String? existingTestPath;
  final String? existingTestContent;
}

/// Information about an existing Patrol test.
@immutable
class ExistingTest {
  const ExistingTest({
    required this.path,
    required this.sourceFilePath,
    this.content,
  });

  final String path;
  final String? sourceFilePath;
  final String? content;
}
