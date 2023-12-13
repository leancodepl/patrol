import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/constants.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';
import 'package:version/version.dart';

class CompatibilityChecker {
  CompatibilityChecker({
    required Directory projectRoot,
    required ProcessManager processManager,
  })  : _projectRoot = projectRoot,
        _processManager = processManager,
        _disposeScope = DisposeScope();

  final Directory _projectRoot;
  final ProcessManager _processManager;
  final DisposeScope _disposeScope;

  Future<void> checkVersionsCompatibility() async {
    String? packageVersion;
    final completer = Completer<String?>();

    await _disposeScope.run((scope) async {
      final process = await _processManager.start(
        ['flutter', 'pub', 'deps', '--style=list'],
        workingDirectory: _projectRoot.path,
        runInShell: true,
      )
        ..disposedBy(scope);

      process.listenStdOut((line) async {
        if (line.startsWith('- patrol ')) {
          completer.complete(line.split(' ').last);
        }
      }).disposedBy(scope);
    });

    packageVersion = await completer.future;

    if (packageVersion == null) {
      throwToolExit(
        'Failed to read patrol version. Make sure you have patrol '
        'dependency in your pubspec.yaml file',
      );
    }

    final cliVersion = Version.parse(version);
    final patrolVersion = Version.parse(packageVersion);

    final isCompatible = cliVersion.isCompatibleWith(patrolVersion);

    if (!isCompatible) {
      throwToolExit(
        'Patrol version $patrolVersion defined in the project is not compatible with patrol_cli version $cliVersion\n'
        'Please upgrade patrol_cli and patrol dependency in project to the latest version.',
      );
    }
  }
}

extension VersionComparator on Version {
  /// Checks if the current Patrol CLI version is compatible with the given Patrol package version.
  bool isCompatibleWith(Version patrolVersion) {
    final cliVersionRange = toRange(_cliVersionRangeList);
    final versionRange = patrolVersion.toRange(_patrolVersionRangeList);

    if (versionRange == null || cliVersionRange == null) {
      return false;
    }

    if (cliToPatrolMap[cliVersionRange] == versionRange) {
      return true;
    } else {
      return false;
    }
  }

  _VersionRange? toRange(List<_VersionRange> versionRangeList) {
    for (final versionRange in versionRangeList) {
      if (this >= versionRange.min &&
          (versionRange.max == null || this <= versionRange.max)) {
        return versionRange;
      }
    }
    return null;
  }
}

final _cliVersionRangeList = [
  _VersionRange(
    min: Version.parse('2.3.0'),
  ),
];

final _patrolVersionRangeList = [
  _VersionRange(
    min: Version.parse('3.0.0'),
  ),
];

final cliToPatrolMap = Map.fromIterables(
  _cliVersionRangeList,
  _patrolVersionRangeList,
);

class _VersionRange {
  _VersionRange({
    required this.min,
    // ignore: unused_element
    this.max,
  });

  final Version min;
  final Version? max;
}
