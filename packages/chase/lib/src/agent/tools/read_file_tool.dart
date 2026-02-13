import 'dart:io';

import 'package:path/path.dart' as p;

import 'agent_tool.dart';

/// Reads source and test files within the project.
class ReadFileTool extends AgentTool {
  ReadFileTool({required this.projectRoot});

  final String projectRoot;

  @override
  String get name => 'read_file';

  @override
  String get description =>
      'Read the contents of a file in the project. '
      'Path must be relative to the project root.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'path': {
            'type': 'string',
            'description': 'Relative path to the file from project root.',
          },
        },
        'required': ['path'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final relativePath = input['path'] as String;
    final absolutePath = p.normalize(p.join(projectRoot, relativePath));

    // Security: prevent path traversal
    if (!p.isWithin(projectRoot, absolutePath)) {
      return 'Error: Path escapes project root. Access denied.';
    }

    // Security: reject symlinks that escape the project
    final resolved = File(absolutePath).resolveSymbolicLinksSync();
    if (!p.isWithin(projectRoot, resolved)) {
      return 'Error: Symlink target escapes project root. Access denied.';
    }

    final file = File(absolutePath);
    if (!file.existsSync()) {
      return 'Error: File not found: $relativePath';
    }

    try {
      final content = await file.readAsString();
      // Limit output to prevent blowing up the context window
      if (content.length > 50000) {
        return '${content.substring(0, 50000)}\n\n[... truncated, file is ${content.length} characters ...]';
      }
      return content;
    } on Exception catch (e) {
      return 'Error reading file: $e';
    }
  }
}
