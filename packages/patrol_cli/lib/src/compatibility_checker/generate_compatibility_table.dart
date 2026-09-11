import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:version/version.dart';
import 'version_compatibility.dart';

/// Generates a compatibility table in MDX format and saves it to both
/// docs/documentation/compatibility-table.mdx and docs/compatibility-table.mdx
Future<void> generateCompatibilityTable() async {
  final logger = Logger();

  final buffer = StringBuffer()
    ..writeln('---')
    ..writeln('title: Compatibility table')
    ..writeln('---')
    ..writeln()
    ..writeln('The following table describes which versions of `patrol`')
    ..writeln('and `patrol_cli` are compatible with each other.')
    ..writeln('The simplest way to ensure that both packages are compatible')
    ..writeln('is by always using the latest version. However,')
    ..writeln("if for some reason that isn't possible, you can refer to")
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
  final sortedList = [...versionCompatibilityList]
    ..sort((a, b) {
      return b.patrolCliBottomRangeVersion.compareTo(
        a.patrolCliBottomRangeVersion,
      );
    });

  // Build table rows
  final tableRows = sortedList.map((entry) {
    String formatVersion(Version bottom, Version? top) {
      if (top == null) {
        return '$bottom+';
      }
      return bottom == top ? bottom.toString() : '$bottom - $top';
    }

    final cliVersion = formatVersion(
      entry.patrolCliBottomRangeVersion,
      entry.patrolCliTopRangeVersion,
    );

    final patrolVersion = formatVersion(
      entry.patrolBottomRangeVersion,
      entry.patrolTopRangeVersion,
    );

    return '| $cliVersion | $patrolVersion | ${entry.minFlutterVersion} |';
  });

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
    )
    ..write(_optInFeaturesSection);

  // Get the root directory of the project
  final currentDir = Directory.current;
  final rootDir = currentDir.path.endsWith('patrol_cli')
      ? path.dirname(path.dirname(currentDir.path))
      : currentDir.path;

  final tableContent = buffer.toString();

  // Create and write to docs/documentation/compatibility-table.mdx
  final docsDir = Directory(path.join(rootDir, 'docs', 'documentation'))
    ..createSync(recursive: true);
  final docsDirFile = File(path.join(docsDir.path, 'compatibility-table.mdx'))
    ..writeAsStringSync(tableContent);

  logger
    ..info('Generated compatibility table in:')
    ..info('- ${docsDirFile.path}');
}

void main() {
  generateCompatibilityTable();
}

/// Opt-in features ship as a matching pair of `patrol` and `patrol_cli`
/// changes, so they need a higher minimum than the open range in the table
/// above. Enabling one on a version that lacks it fails the build rather than
/// the compatibility check, so it can't be expressed as a table row — keep this
/// list up to date by hand when such a feature lands.
const _optInFeaturesSection = r'''

## Opt-in features

The table above is about general compatibility — it's what `patrol_cli` checks
before a run, and it covers the default, runtime-discovery flow.

Some features are opt-in and ship as a matching pair of `patrol` and `patrol_cli`
changes, so they need a higher minimum than the table's open range. Enabling one
on a version that doesn't have it fails the build (or silently does nothing)
rather than failing the compatibility check, so those minimums are listed
separately here:

| Feature | Minimum `patrol_cli` | Minimum `patrol` |
|---------|----------------------|------------------|
| [Build-time test discovery](/documentation/ci/build-time-test-discovery) — one native class per test file, `PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BASE` runner macro | 4.8.0 | 4.10.0 |
| Build-time test discovery — first release, `PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN`/`_END` runner macro | 4.7.0 | 4.9.0 |
| [Native screenshots](/cli-commands/test#screenshots) — `screenshot_on_failure`, `$.takeNativeScreenshot()` | 4.8.0 | 4.10.0 |

The two build-time discovery rows are alternatives, not a range: the runner macro
changed in the second one, so `patrol_cli` 4.8.0 and newer no longer accept the
`STATIC_BEGIN`/`_END` form. Use the newest pair.
''';
