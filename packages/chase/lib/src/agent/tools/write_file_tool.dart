import 'dart:io';

import 'package:path/path.dart' as p;

import 'agent_tool.dart';

/// Writes test files, sandboxed to the integration_test directory.
class WriteFileTool extends AgentTool {
  WriteFileTool({
    required this.projectRoot,
    required this.testDirectory,
  });

  final String projectRoot;
  final String testDirectory;

  /// Files written during this session.
  final List<String> writtenFiles = [];

  @override
  String get name => 'write_test_file';

  @override
  String get description =>
      'Write a Patrol integration test file. '
      'Files can only be written to the integration_test/ directory. '
      'Provide the full file content including all imports.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description':
                'Path relative to the project root. Must be within the '
                'integration_test/ directory (e.g., "integration_test/home_screen_test.dart").',
          },
          'content': {
            'type': 'string',
            'description': 'The complete Dart source code for the test file.',
          },
        },
        'required': ['path', 'content'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final relativePath = input['path'] as String;
    final content = input['content'] as String;
    final absolutePath = p.normalize(p.join(projectRoot, relativePath));

    // Security: only allow writes to the test directory
    final testDirPath = p.normalize(p.join(projectRoot, testDirectory));
    if (!p.isWithin(testDirPath, absolutePath)) {
      return 'Error: Files can only be written to $testDirectory/. '
          'Requested path: $relativePath';
    }

    // Security: prevent path traversal
    if (!p.isWithin(projectRoot, absolutePath)) {
      return 'Error: Path escapes project root. Access denied.';
    }

    // Ensure file has .dart extension
    if (!relativePath.endsWith('.dart')) {
      return 'Error: Only .dart files are allowed.';
    }

    try {
      final file = File(absolutePath);
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
      writtenFiles.add(relativePath);
      return 'Successfully wrote ${content.split('\n').length} lines to $relativePath';
    } on Exception catch (e) {
      return 'Error writing file: $e';
    }
  }
}
