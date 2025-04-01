import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:version/version.dart';
import 'version_compatibility.dart';

final _logger = Logger('compatibility_table');

/// Generates a compatibility table in MDX format and saves it to docs/documentation/compatibility-table.mdx
Future<void> generateCompatibilityTable() async {
  final buffer = StringBuffer()
    ..writeln('---')
    ..writeln('title: Compatibility table')
    ..writeln('---')
    ..writeln()
    ..writeln('The following table describes which versions of `patrol`')
    ..writeln('and `patrol_cli` are compatible with each other.')
    ..writeln('The simplest way to ensure that both packages are compatible')
    ..writeln('is by always using the latest version. However,')
    ..writeln('if for some reason that isn"t possible, you can refer to')
    ..writeln('the table below to assess which version you should use.')
    ..writeln()
    ..writeln(
      'This table shows the compatible versions between patrol_cli and patrol packages.',
    )
    ..writeln()
    ..writeln(
      '| patrol_cli version | patrol version | Minimum Flutter version |',
    )
    ..writeln(
      '|-------------------|----------------|------------------------|',
    );

  // Sort list by patrol_cli version in descending order
  final sortedList = [...versionCompatibilityList]..sort((a, b) {
      final aVersion =
          Version.parse(a.patrolCliVersion.split(' - ')[0].replaceAll('+', ''));
      final bVersion =
          Version.parse(b.patrolCliVersion.split(' - ')[0].replaceAll('+', ''));
      return bVersion.compareTo(aVersion);
    });

  // Build table rows
  final tableRows = sortedList.map(
    (entry) =>
        '| ${entry.patrolCliVersion} | ${entry.patrolVersion} | ${entry.minFlutterVersion} |',
  );

  // Add table rows and notes section
  buffer
    ..writeAll(tableRows, '\n')
    ..writeln()
    ..writeln()
    ..writeln('## Notes')
    ..writeln()
    ..writeln(
      '- Versions marked with `+` indicate compatibility with all later versions',
    )
    ..writeln(
      '- Ranges (e.g., `2.0.0 - 2.1.0`) indicate compatibility with all versions in that range',
    )
    ..writeln(
      '- The minimum Flutter version is required for both packages to work correctly',
    );

  // Get the root directory of the project
  final currentDir = Directory.current;
  final rootDir = currentDir.path.endsWith('patrol_cli')
      ? path.dirname(path.dirname(currentDir.path))
      : currentDir.path;

  // Create docs/documentation directory if it doesn't exist
  final docsDir = Directory(path.join(rootDir, 'docs', 'documentation'))
    ..createSync(recursive: true);

  // Save to docs/documentation/compatibility-table.mdx
  File(path.join(docsDir.path, 'compatibility-table.mdx'))
      .writeAsStringSync(buffer.toString());
}

void main() {
  generateCompatibilityTable();
  _logger.info('Compatibility table generated successfully!');
}
