import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:version/version.dart';
import 'version_compatibility.dart';

/// Generates a compatibility table in MDX format and saves it to docs/documentation/compatibility-table.mdx
Future<void> generateCompatibilityTable() async {
  final buffer = StringBuffer();
  buffer.writeln('---');
  buffer.writeln('title: Compatibility table');
  buffer.writeln('---');
  buffer.writeln();
  buffer.writeln('The following table describes which versions of `patrol`');
  buffer.writeln('and `patrol_cli` are compatible with each other.');
  buffer
      .writeln('The simplest way to ensure that both packages are compatible');
  buffer.writeln('is by always using the latest version. However,');
  buffer.writeln('if for some reason that isn\'t possible, you can refer to');
  buffer.writeln('the table below to assess which version you should use.');
  buffer.writeln();
  buffer.writeln(
      'This table shows the compatible versions between patrol_cli and patrol packages.');
  buffer.writeln();
  buffer.writeln(
      '| patrol_cli version | patrol version | Minimum Flutter version |');
  buffer.writeln(
      '|-------------------|----------------|------------------------|');

  // Sort list by patrol_cli version in descending order
  final sortedList = [...versionCompatibilityList];
  sortedList.sort((a, b) {
    final aVersion =
        Version.parse(a.patrolCliVersion.split(' - ')[0].replaceAll('+', ''));
    final bVersion =
        Version.parse(b.patrolCliVersion.split(' - ')[0].replaceAll('+', ''));
    return bVersion.compareTo(aVersion);
  });

  for (final entry in sortedList) {
    buffer.writeln(
      '| ${entry.patrolCliVersion} | ${entry.patrolVersion} | ${entry.minFlutterVersion} |',
    );
  }

  buffer.writeln();
  buffer.writeln('## Notes');
  buffer.writeln();
  buffer.writeln(
      '- Versions marked with `+` indicate compatibility with all later versions');
  buffer.writeln(
      '- Ranges (e.g., `2.0.0 - 2.1.0`) indicate compatibility with all versions in that range');
  buffer.writeln(
      '- The minimum Flutter version is required for both packages to work correctly');

  // Get the root directory of the project
  final currentDir = Directory.current;
  final rootDir = currentDir.path.endsWith('patrol_cli')
      ? path.dirname(path.dirname(currentDir.path))
      : currentDir.path;

  // Create docs/documentation directory if it doesn't exist
  final docsDir = Directory(path.join(rootDir, 'docs', 'documentation'));
  if (!await docsDir.exists()) {
    await docsDir.create(recursive: true);
  }

  // Save to docs/documentation/compatibility-table.mdx
  final outputFile = File(path.join(docsDir.path, 'compatibility-table.mdx'));
  await outputFile.writeAsString(buffer.toString());
}

void main() async {
  await generateCompatibilityTable();
  print('Compatibility table generated successfully!');
}
