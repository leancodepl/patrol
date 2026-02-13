import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import 'context_models.dart';

/// Maps existing Patrol tests to their source files via import analysis.
class TestMapper {
  const TestMapper({
    required this.projectRoot,
    required this.testDirectory,
  });

  final String projectRoot;
  final String testDirectory;

  /// Finds all existing Patrol tests and maps them to source files.
  Future<List<ExistingTest>> mapTests() async {
    final testDir = Directory(p.join(projectRoot, testDirectory));
    if (!testDir.existsSync()) return [];

    final glob = Glob('**/*_test.dart');
    final tests = <ExistingTest>[];

    await for (final entity in glob.list(root: testDir.path)) {
      if (entity is File) {
        final file = entity as File;
        final content = await file.readAsString();
        final relativePath = p.relative(file.path, from: projectRoot);
        final sourceFile = _findSourceFile(content);

        tests.add(
          ExistingTest(
            path: relativePath,
            sourceFilePath: sourceFile,
            content: content,
          ),
        );
      }
    }

    return tests;
  }

  /// Finds a test file that corresponds to a given source file path.
  Future<String?> findTestFor(String sourceFilePath) async {
    final tests = await mapTests();
    for (final test in tests) {
      if (test.sourceFilePath == sourceFilePath) {
        return test.path;
      }
    }

    // Try conventional naming: lib/src/screens/home_screen.dart
    //   → integration_test/home_screen_test.dart
    final baseName = p.basenameWithoutExtension(sourceFilePath);
    final conventionalPath = p.join(testDirectory, '${baseName}_test.dart');
    final conventionalFile = File(p.join(projectRoot, conventionalPath));
    if (conventionalFile.existsSync()) return conventionalPath;

    return null;
  }

  /// Extracts source file path from test imports.
  String? _findSourceFile(String testContent) {
    // Look for imports of the project's lib/ files
    final importPattern = RegExp(
      r"import\s+'package:(\w+)/(.+\.dart)';",
    );

    for (final match in importPattern.allMatches(testContent)) {
      final importPath = match.group(2)!;
      // Skip test utilities, flutter, etc.
      if (!importPath.contains('test') && !importPath.startsWith('src/')) {
        return 'lib/$importPath';
      }
      if (importPath.startsWith('src/')) {
        return 'lib/$importPath';
      }
    }

    return null;
  }
}
