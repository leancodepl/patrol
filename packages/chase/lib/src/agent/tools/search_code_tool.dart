import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import 'agent_tool.dart';

/// Searches for code patterns across the codebase using regex.
class SearchCodeTool extends AgentTool {
  SearchCodeTool({required this.projectRoot});

  final String projectRoot;

  @override
  String get name => 'search_code';

  @override
  String get description =>
      'Search for a regex pattern across Dart files in the project. '
      'Returns matching lines with file paths and line numbers.';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'pattern': {
            'type': 'string',
            'description': 'Regex pattern to search for.',
          },
          'file_pattern': {
            'type': 'string',
            'description':
                'Optional glob pattern to filter files (default: "lib/**/*.dart").',
          },
          'max_results': {
            'type': 'integer',
            'description': 'Maximum number of results to return (default: 50).',
          },
        },
        'required': ['pattern'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final pattern = input['pattern'] as String;
    final filePattern = input['file_pattern'] as String? ?? 'lib/**/*.dart';
    final maxResults = input['max_results'] as int? ?? 50;

    RegExp regex;
    try {
      regex = RegExp(pattern);
    } on FormatException catch (e) {
      return 'Error: Invalid regex pattern: $e';
    }

    final results = <String>[];
    final glob = Glob(filePattern);

    try {
      await for (final entity in glob.list(root: projectRoot)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        final file = entity as File;
        final relativePath = p.relative(file.path, from: projectRoot);
        final content = await file.readAsString();
        final lines = content.split('\n');

        for (var i = 0; i < lines.length; i++) {
          if (regex.hasMatch(lines[i])) {
            results.add('$relativePath:${i + 1}: ${lines[i].trim()}');
            if (results.length >= maxResults) break;
          }
        }

        if (results.length >= maxResults) break;
      }
    } on Exception catch (e) {
      return 'Error searching: $e';
    }

    if (results.isEmpty) {
      return 'No matches found for pattern: $pattern';
    }

    return results.join('\n');
  }
}
