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

      if (maxCliVersion != null) {
        throwToolExit(
          'Patrol version $patrolVersion defined in the project is not compatible with patrol_cli version $cliVersion\n'
          'To resolve this issue, you can:\n'
          '1. Downgrade patrol_cli to a compatible version by running: \n'
          '   ${lightCyan.wrap('dart pub global activate patrol_cli $maxCliVersion')}\n'
          '2. Or upgrade both "patrol_cli" and "patrol" dependency in project to the latest versions.\n\n'
          'Check the compatibility table at: ${lightCyan.wrap('https://patrol.leancode.co/documentation/compatibility-table')}',
        );
      } else {
        throwToolExit(
          'Patrol version $patrolVersion defined in the project is not compatible with patrol_cli version $cliVersion\n'
          'Please upgrade both "patrol_cli" and "patrol" dependency in project to the latest versions.\n\n'
          'Check the compatibility table at: ${lightCyan.wrap('https://patrol.leancode.co/documentation/compatibility-table')}',
        );
      }
    }
  }

  /// Checks version compatibility and displays a warning if incompatible
  Future<void> checkVersionsCompatibilityWithWarning({
    required String? patrolVersion,
  }) async {
    if (patrolVersion == null) {
      return;
    }

    try {
      final cliVersion = Version.parse(constants.version);
      final packageVersion = Version.parse(patrolVersion);

      final isCompatible = areVersionsCompatible(cliVersion, packageVersion);
      if (!isCompatible) {
        // Find the maximum compatible CLI version for this patrol version
        final maxCliVersion = getMaxCompatibleCliVersion(packageVersion);

        if (maxCliVersion != null) {
          _logger.warn(
            '''
Patrol version $packageVersion defined in your project is not compatible with patrol_cli version $cliVersion.
This will cause issues when running 'patrol test'.

To resolve this issue, you can:
1. Downgrade patrol_cli to a compatible version by running: 
   ${lightCyan.wrap('dart pub global activate patrol_cli $maxCliVersion')}
   
2. Or upgrade both "patrol_cli" and "patrol" dependencies to the latest versions.

Check the compatibility table at: ${lightCyan.wrap('https://patrol.leancode.co/documentation/compatibility-table')}
''',
          );
        } else {
          _logger.warn(
            '''
Patrol version $packageVersion defined in your project is not compatible with patrol_cli version $cliVersion.
This will cause issues when running 'patrol test'.

To resolve this issue, please upgrade both "patrol_cli" and "patrol" dependencies to the latest versions.

Check the compatibility table at: ${lightCyan.wrap('https://patrol.leancode.co/documentation/compatibility-table')}
''',
          );
        }
      }
    } catch (e) {
      _logger.detail('Failed to check version compatibility: $e');
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
