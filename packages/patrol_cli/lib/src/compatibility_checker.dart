import 'dart:async';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:process/process.dart';
import 'package:version/version.dart';

class CompatibilityChecker {
  CompatibilityChecker({
    required Directory projectRoot,
    required ProcessManager processManager,
    required Logger logger,
  })  : _projectRoot = projectRoot,
        _processManager = processManager,
        _disposeScope = DisposeScope(),
        _logger = logger;

  final Directory _projectRoot;
  final ProcessManager _processManager;
  final DisposeScope _disposeScope;
  final Logger _logger;

  Future<void> checkVersionsCompatibility({
    required FlutterCommand flutterCommand,
  }) async {
    if (io.Platform.isAndroid) {
      await _checkJavaVersion(
        _disposeScope,
        _processManager,
        _projectRoot,
        _logger,
      );
    }

    String? packageVersion;
    final packageCompleter = Completer<String?>();

    await _disposeScope.run((scope) async {
      final process = await _processManager.start(
        [
          flutterCommand.executable,
          ...flutterCommand.arguments,
          '--suppress-analytics',
          '--no-version-check',
          'pub',
          'deps',
          '--style=list',
        ],
        workingDirectory: _projectRoot.path,
        runInShell: true,
      )
        ..disposedBy(scope);

      process.listenStdOut(
        (line) async {
          if (line.startsWith('- patrol ')) {
            packageCompleter.complete(line.split(' ').last);
          }
        },
        onDone: () {
          if (!packageCompleter.isCompleted) {
            throwToolExit(
              'Failed to read patrol version. Make sure you have patrol '
              'dependency in your pubspec.yaml file',
            );
          }
        },
      ).disposedBy(scope);
    });

    packageVersion = await packageCompleter.future;

    final cliVersion = Version.parse(constants.version);
    final patrolVersion = Version.parse(packageVersion!);

    final isCompatible = cliVersion.isCompatibleWith(patrolVersion);

    if (!isCompatible) {
      throwToolExit(
        'Patrol version $patrolVersion defined in the project is not compatible with patrol_cli version $cliVersion\n'
        'Please upgrade both "patrol_cli" and "patrol" dependency in project to the latest versions.',
      );
    }
  }
}

Future<void> _checkJavaVersion(
  DisposeScope disposeScope,
  ProcessManager processManager,
  Directory projectRoot,
  Logger logger,
) async {
  Version? javaVersion;
  final javaCompleter = Completer<Version?>();

  await disposeScope.run((scope) async {
    final process = await processManager.start(
      ['javac', '--version'],
      workingDirectory: projectRoot.path,
      runInShell: true,
    )
      ..disposedBy(scope);

    process.listenStdOut((line) async {
      if (line.startsWith('javac')) {
        javaCompleter.complete(Version.parse(line.split(' ').last));
      }
    }).disposedBy(scope);
  });

  javaVersion = await javaCompleter.future;
  if (javaVersion == null) {
    throwToolExit(
      'Failed to read Java version. Make sure you have Java installed and added to PATH',
    );
  } else if (javaVersion.major != 17) {
    logger.warn(
      'You are using Java $javaVersion which can cause issues on Android.\n'
      'If you encounter any issues, try changing your Java version to 17.',
    );
  }
}

extension _VersionComparator on Version {
  /// Checks if the current Patrol CLI version is compatible with the given Patrol package version.
  bool isCompatibleWith(Version patrolVersion) {
    final cliVersionRange = toRange(_cliVersionRange);
    final versionRange = patrolVersion.toRange(_patrolVersionRange);

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
      if (isInRange(versionRange)) {
        return versionRange;
      }
    }
    return null;
  }

  bool isInRange(_VersionRange versionRange) {
    return this >= versionRange.min &&
        (hasNoUpperBound(versionRange) || this <= versionRange.max);
  }

  bool hasNoUpperBound(_VersionRange versionRange) {
    return versionRange.max == null;
  }
}

final _cliVersionRange = [
  _VersionRange(
    min: Version.parse('2.3.0'),
  ),
];

final _patrolVersionRange = [
  _VersionRange(
    min: Version.parse('3.0.0'),
  ),
];

final cliToPatrolMap = Map.fromIterables(
  _cliVersionRange,
  _patrolVersionRange,
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
