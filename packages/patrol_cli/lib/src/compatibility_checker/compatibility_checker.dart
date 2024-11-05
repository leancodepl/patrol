import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/completer.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/compatibility_checker/version_comparator.dart';
import 'package:patrol_cli/src/devices.dart';
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
    required TargetPlatform targetPlatform,
  }) async {
    if (targetPlatform == TargetPlatform.android) {
      await _checkJavaVersion(
        flutterCommand,
        DisposeScope(),
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
    final versionComparator = VersionComparator(
      cliVersionRange: _patrolCliVersionRange,
      packageVersionRange: _patrolVersionRange,
    );

    final isCompatible =
        versionComparator.isCompatible(cliVersion, patrolVersion);

    if (!isCompatible) {
      throwToolExit(
        'Patrol version $patrolVersion defined in the project is not compatible with patrol_cli version $cliVersion\n'
        'Please upgrade both "patrol_cli" and "patrol" dependency in project to the latest versions.',
      );
    }
  }
}

Future<void> _checkJavaVersion(
  FlutterCommand flutterCommand,
  DisposeScope disposeScope,
  ProcessManager processManager,
  Directory projectRoot,
  Logger logger,
) async {
  Version? javaVersion;
  final javaCompleterVersion = Completer<Version?>();

  await disposeScope.run((scope) async {
    final processFlutter = await processManager.start(
      [
        flutterCommand.executable,
        ...flutterCommand.arguments,
        'doctor',
        '--verbose',
      ],
      workingDirectory: projectRoot.path,
      runInShell: true,
    )
      ..disposedBy(scope);

    processFlutter.listenStdOut(
      (line) async {
        if (line.contains('• Java version')) {
          final versionString = line.split(' ').last.replaceAll(')', '');
          javaCompleterVersion.maybeComplete(Version.parse(versionString));
        }
      },
      onDone: () async {
        if (!javaCompleterVersion.isCompleted) {
          final processJava = await processManager.start(
            ['javac', '--version'],
            workingDirectory: projectRoot.path,
            runInShell: true,
          )
            ..disposedBy(scope);

          processJava.listenStdOut(
            (line) async {
              if (line.startsWith('javac')) {
                javaCompleterVersion
                    .maybeComplete(Version.parse(line.split(' ').last));
              }
            },
            onDone: () => javaCompleterVersion.maybeComplete(null),
            onError: (error) => javaCompleterVersion.maybeComplete(null),
          ).disposedBy(scope);
        }
      },
      onError: (error) => javaCompleterVersion.maybeComplete(null),
    ).disposedBy(scope);
  });

  javaVersion = await javaCompleterVersion.future;

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

final _patrolVersionRange = [
  VersionRange(
    min: Version.parse('1.0.9'),
    max: Version.parse('1.1.11'),
  ),
  VersionRange(
    min: Version.parse('2.0.0'),
    max: Version.parse('2.0.0'),
  ),
  VersionRange(
    min: Version.parse('2.0.1'),
    max: Version.parse('2.2.5'),
  ),
  VersionRange(
    min: Version.parse('2.3.0'),
    max: Version.parse('2.3.2'),
  ),
  VersionRange(
    min: Version.parse('3.0.0'),
    max: Version.parse('3.3.0'),
  ),
  VersionRange(
    min: Version.parse('3.4.0'),
    max: Version.parse('3.5.2'),
  ),
  VersionRange(
    min: Version.parse('3.6.0'),
    max: Version.parse('3.10.0'),
  ),
  VersionRange(
    min: Version.parse('3.10.0'),
    max: Version.parse('3.10.0'),
  ),
  VersionRange(
    min: Version.parse('3.11.0'),
    max: Version.parse('3.11.1'),
  ),
  VersionRange(
    min: Version.parse('3.11.2'),
    max: Version.parse('3.11.2'),
  ),
  VersionRange(
    min: Version.parse('3.12.0'),
  ),
];

final _patrolCliVersionRange = [
  VersionRange(
    min: Version.parse('1.1.4'),
    max: Version.parse('1.1.11'),
  ),
  VersionRange(
    min: Version.parse('2.0.0'),
    max: Version.parse('2.0.0'),
  ),
  VersionRange(
    min: Version.parse('2.0.1'),
    max: Version.parse('2.1.5'),
  ),
  VersionRange(
    min: Version.parse('2.2.0'),
    max: Version.parse('2.2.2'),
  ),
  VersionRange(
    min: Version.parse('2.3.0'),
    max: Version.parse('2.5.0'),
  ),
  VersionRange(
    min: Version.parse('2.6.0'),
    max: Version.parse('2.6.4'),
  ),
  VersionRange(
    min: Version.parse('2.6.5'),
    max: Version.parse('3.0.1'),
  ),
  VersionRange(
    min: Version.parse('3.1.0'),
    max: Version.parse('3.1.1'),
  ),
  VersionRange(
    min: Version.parse('3.2.0'),
    max: Version.parse('3.2.0'),
  ),
  VersionRange(
    min: Version.parse('3.2.1'),
    max: Version.parse('3.2.1'),
  ),
  VersionRange(
    min: Version.parse('3.3.0'),
  ),
];
