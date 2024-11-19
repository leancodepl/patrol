import 'dart:async';
import 'dart:io' show Process;

import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/completer.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

/// Provides functionality to build, install, run, and uninstall Android apps.
///
/// This class must be stateless.
class AndroidTestBackend {
  AndroidTestBackend({
    required Adb adb,
    required ProcessManager processManager,
    required Platform platform,
    required Directory rootDirectory,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _adb = adb,
        _processManager = processManager,
        _rootDirectory = rootDirectory,
        _platform = platform,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final Adb _adb;
  final ProcessManager _processManager;
  final Platform _platform;
  final Directory _rootDirectory;
  final DisposeScope _disposeScope;
  final Logger _logger;
  late final String? javaPath;

  Future<void> build(AndroidAppOptions options) async {
    await buildApkConfigOnly(options.flutter.command);
    await loadJavaPathFromFlutterDoctor(options.flutter.command);

    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task('Building $subject');

      Process process;
      int exitCode;

      // :app:assembleDebug

      process = await _processManager.start(
        options.toGradleAssembleInvocation(isWindows: _platform.isWindows),
        runInShell: true,
        workingDirectory: _rootDirectory.childDirectory('android').path,
        environment: javaPath != null
            ? {
                'JAVA_HOME': javaPath!,
              }
            : {},
      )
        ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      exitCode = await process.exitCode;
      if (exitCode == exitCodeInterrupted) {
        const cause = 'Gradle build interrupted';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      } else if (exitCode != 0) {
        final cause = 'Gradle build failed with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      }

      // :app:assembleDebugAndroidTest

      process = await _processManager.start(
        options.toGradleAssembleTestInvocation(isWindows: _platform.isWindows),
        runInShell: true,
        workingDirectory: _rootDirectory.childDirectory('android').path,
        environment: javaPath != null
            ? {
                'JAVA_HOME': javaPath!,
              }
            : {},
      )
        ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      exitCode = await process.exitCode;
      if (exitCode == 0) {
        task.complete('Completed building $subject');
      } else if (exitCode == exitCodeInterrupted) {
        const cause = 'Gradle build interrupted';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      } else {
        final cause = 'Gradle build failed with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throw Exception(cause);
      }
    });
  }

  /// Load the Java path from the output of `flutter doctor`.
  /// If this will be null, then the Java path will not be set and patrol
  /// tries to use the Java path from the PATH environment variable.
  Future<void> loadJavaPathFromFlutterDoctor(
    FlutterCommand flutterCommand,
  ) async {
    final javaCompleterPath = Completer<String?>();

    await _disposeScope.run((scope) async {
      final process = await _processManager.start(
        [
          flutterCommand.executable,
          ...flutterCommand.arguments,
          'doctor',
          '--verbose',
        ],
        runInShell: true,
      )
        ..disposedBy(scope);

      process.listenStdOut(
        (line) async {
          if (line.contains('• Java binary at:') &&
              javaCompleterPath.isCompleted == false) {
            var path = line.replaceAll('• Java binary at:', '').trim();
            // If the path is /usr/bin/java, then it's not the real path,
            // but symlink, so we're not setting JAVA_HOME path.
            // Otherwise, we remove the `/bin/java` part, to get a proper
            // JAVA_HOME path.
            if (path != '/usr/bin/java') {
              path = path.replaceAll(
                _platform.isWindows ? r'\bin\java' : '/bin/java',
                '',
              );
              javaCompleterPath.maybeComplete(path);
            } else {
              javaCompleterPath.maybeComplete(null);
            }
          }
        },
        onDone: () => javaCompleterPath.maybeComplete(null),
        onError: (error) => javaCompleterPath.maybeComplete(null),
      ).disposedBy(scope);
    });

    javaPath = await javaCompleterPath.future;
  }

  /// Execute `flutter build apk --config-only` to generate the gradlew file.
  ///
  /// This fix issue: https://github.com/leancodepl/patrol/issues/1668
  Future<void> buildApkConfigOnly(
    FlutterCommand flutterCommand,
  ) async {
    await _processManager.start(
      [
        flutterCommand.executable,
        ...flutterCommand.arguments,
        'build',
        'apk',
        '--config-only',
        '-t',
        'integration_test/test_bundle.dart',
      ],
      runInShell: true,
    );
  }

  /// Executes the tests of the given [options] on the given [device].
  ///
  /// [build] must be called before this method.
  ///
  /// If [interruptible] is true, then no exception is thrown on SIGINT. This is
  /// used for Hot Restart.
  Future<void> execute(
    AndroidAppOptions options,
    Device device, {
    String? flavor,
    bool interruptible = false,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
  }) async {
    await _disposeScope.run((scope) async {
      // Read patrol logs from logcat
      final processLogcat = await _adb.logcat(
        device: device.id,
        arguments: {
          '-T': '1',
        },
        filter: 'PatrolServer:I Patrol:I flutter:I *:S',
      )
        ..disposedBy(scope);

      var flavorPath = '';
      if (flavor != null) {
        flavorPath = 'flavors/$flavor/';
      }
      final path =
          'file://${_rootDirectory.path}/build/app/reports/androidTests/connected/${flavorPath}index.html';
      final reportPath =
          _platform.isWindows ? path.replaceAll(r'\', '/') : path;

      final patrolLogReader = PatrolLogReader(
        listenStdOut: processLogcat.listenStdOut,
        scope: scope,
        log: _logger.info,
        reportPath: reportPath,
        showFlutterLogs: showFlutterLogs,
        hideTestSteps: hideTestSteps,
        clearTestSteps: clearTestSteps,
      )
        ..listen()
        ..startTimer();

      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Executing tests of $subject');

      final process = await _processManager.start(
        options.toGradleConnectedTestInvocation(isWindows: _platform.isWindows),
        runInShell: true,
        environment: {
          'ANDROID_SERIAL': device.id,
          ...javaPath != null
              ? {
                  'JAVA_HOME': javaPath!,
                }
              : {},
        },
        workingDirectory: _rootDirectory.childDirectory('android').path,
      )
        ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) {
        const prefix = 'There were failing tests. ';
        if (l.contains(prefix)) {
          final msg = l.substring(prefix.length + 2);
          _logger.detail('\t$msg');
        } else {
          _logger.detail('\t$l');
        }
      }).disposedBy(scope);

      final exitCode = await process.exitCode;
      patrolLogReader.stopTimer();
      processLogcat.kill();

      // Don't print the summary in develop
      if (!interruptible) {
        _logger.info(patrolLogReader.summary);
      }

      if (exitCode == 0) {
        task.complete('Completed executing $subject');
      } else if (exitCode != 0 && interruptible) {
        task.complete('App shut down on request');
      } else if (exitCode == exitCodeInterrupted) {
        const cause = 'Gradle test execution interrupted';
        task.fail('Failed to execute tests of $subject ($cause)');
        throw Exception(cause);
      } else {
        final cause = 'Gradle test execution failed with code $exitCode';
        task.fail('Failed to execute tests of $subject ($cause)');
        throw Exception(cause);
      }
    });
  }

  Future<void> uninstall(String appId, Device device) async {
    _logger.detail('Uninstalling $appId from ${device.name}');
    await _adb.uninstall(appId, device: device.id);
    _logger.detail('Uninstalling $appId.test from ${device.name}');
    await _adb.uninstall('$appId.test', device: device.id);
  }
}
