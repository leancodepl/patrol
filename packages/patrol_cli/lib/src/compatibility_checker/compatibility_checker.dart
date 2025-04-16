import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/completer.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
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

  /// Generates incompatibility error message with appropriate resolution steps
  String _incompatibilityMessage({
    required Version packageVersion,
    required Version cliVersion,
    required String additionalInfo,
    Version? maxCliVersion,
  }) {
    final resolveSteps = maxCliVersion != null
        ? '''
1. Downgrade patrol_cli to a compatible version by running: 
   dart pub global activate patrol_cli $maxCliVersion
   
2. Or upgrade both "patrol_cli" and "patrol" dependencies to the latest versions.'''
        : 'Please upgrade both "patrol_cli" and "patrol" dependencies to the latest versions.';

    return '''
Patrol version $packageVersion defined in your project is not compatible with patrol_cli version $cliVersion.
$additionalInfo

To resolve this issue:
$resolveSteps

Check the compatibility table at: https://patrol.leancode.co/documentation/compatibility-table
''';
  }

  /// Checks if the version compatibility and throws an error if incompatible
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
            packageCompleter.maybeComplete(line.split(' ').last);
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

    final isCompatible = areVersionsCompatible(cliVersion, patrolVersion);

    if (!isCompatible) {
      // Find the maximum compatible CLI version for this patrol version
      final maxCliVersion = getMaxCompatibleCliVersion(patrolVersion);

      throwToolExit(
        _incompatibilityMessage(
          packageVersion: patrolVersion,
          cliVersion: cliVersion,
          additionalInfo:
              'This will prevent your tests from running correctly.',
          maxCliVersion: maxCliVersion,
        ),
      );
    }
  }

  /// Checks version compatibility and fails the build process if incompatible
  Future<void> checkVersionsCompatibilityForBuild({
    required String? patrolVersion,
  }) async {
    if (patrolVersion == null) {
      return;
    }

    final cliVersion = Version.parse(constants.version);
    final packageVersion = Version.parse(patrolVersion);

    final isCompatible = areVersionsCompatible(cliVersion, packageVersion);
    if (!isCompatible) {
      // Find the maximum compatible CLI version for this patrol version
      final maxCliVersion = getMaxCompatibleCliVersion(packageVersion);

      throwToolExit(
        _incompatibilityMessage(
          packageVersion: packageVersion,
          cliVersion: cliVersion,
          additionalInfo:
              'This will prevent your tests from running correctly.',
          maxCliVersion: maxCliVersion,
        ),
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
  } else if (javaVersion.major != 17 && javaVersion.major != 21) {
    logger.warn(
      'You are using Java $javaVersion which can cause issues on Android.\n'
      'If you encounter any issues, try changing your Java version to 17 or 21.',
    );
  }
}
