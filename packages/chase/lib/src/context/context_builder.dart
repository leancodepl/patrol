import 'dart:io';

import 'package:path/path.dart' as p;

import '../analyzer/diff_models.dart';
import '../analyzer/impact_scorer.dart';
import 'context_models.dart';
import 'project_scanner.dart';
import 'test_mapper.dart';

/// Builds the AI context window from project state and diff results.
class ContextBuilder {
  ContextBuilder({
    required this.projectRoot,
    required this.testDirectory,
  });

  final String projectRoot;
  final String testDirectory;

  /// Builds the full [AgentContext] from a [DiffResult].
  Future<AgentContext> build(DiffResult diffResult) async {
    final scanner = ProjectScanner(projectRoot: projectRoot);
    final mapper = TestMapper(
      projectRoot: projectRoot,
      testDirectory: testDirectory,
    );

    // Scan project info and tests in parallel
    final projectInfoFuture = scanner.scan();
    final patrolVersionFuture = scanner.getPatrolVersion();
    final existingTestsFuture = mapper.mapTests();

    final projectInfo = await projectInfoFuture;
    final patrolVersion = await patrolVersionFuture;
    final existingTests = await existingTestsFuture;

    // Score and prioritize changes
    final scorer = const ImpactScorer();
    final scored = scorer.score(diffResult.files);

    // Build prioritized changes with source content
    final prioritizedChanges = <PrioritizedChange>[];
    final sourceFiles = <String, String>{};

    for (final sc in scored) {
      String? sourceContent;
      String? existingTestPath;
      String? existingTestContent;

      // Read source file content
      final sourceFile = File(p.join(projectRoot, sc.file.path));
      if (sourceFile.existsSync()) {
        sourceContent = await sourceFile.readAsString();
        sourceFiles[sc.file.path] = sourceContent;
      }

      // Find existing test
      existingTestPath = await mapper.findTestFor(sc.file.path);
      if (existingTestPath != null) {
        final testFile = File(p.join(projectRoot, existingTestPath));
        if (testFile.existsSync()) {
          existingTestContent = await testFile.readAsString();
        }
      }

      prioritizedChanges.add(
        PrioritizedChange(
          file: sc.file,
          category: sc.category,
          score: sc.score,
          sourceContent: sourceContent,
          existingTestPath: existingTestPath,
          existingTestContent: existingTestContent,
        ),
      );
    }

    return AgentContext(
      projectInfo: projectInfo,
      diffResult: diffResult,
      prioritizedChanges: prioritizedChanges,
      existingTests: existingTests,
      sourceFiles: sourceFiles,
      patrolVersion: patrolVersion,
    );
  }
}
