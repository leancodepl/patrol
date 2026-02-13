import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

import 'agent_tool.dart';

/// Lists files matching a glob pattern within the project.
class ListFilesTool extends AgentTool {
  ListFilesTool({required this.projectRoot});

  final String projectRoot;

  @override
  String get name => 'list_files';

  @override
  String get description =>
      'List files matching a glob pattern within the project. '
      'Examples: "lib/**/*.dart", "integration_test/**/*_test.dart"';

  @override
  Map<String, dynamic> get inputSchema => {
        'type': 'object',
        'properties': {
          'pattern': {
            'type': 'string',
            'description':
                'Glob pattern to match files (e.g., "lib/**/*.dart").',
          },
        },
        'required': ['pattern'],
      };

  @override
  Future<String> execute(Map<String, dynamic> input) async {
    final pattern = input['pattern'] as String;

    try {
      final glob = Glob(pattern);
      final files = <String>[];

      await for (final entity in glob.list(root: projectRoot)) {
        final relativePath = p.relative(entity.path, from: projectRoot);
        files.add(relativePath);

        // Limit to prevent huge outputs
        if (files.length >= 200) {
          files.add('... (truncated, more files match the pattern)');
          break;
        }
      }

      if (files.isEmpty) {
        return 'No files match the pattern: $pattern';
      }

      files.sort();
      return files.join('\n');
    } on Exception catch (e) {
      return 'Error listing files: $e';
    }
  }
}
