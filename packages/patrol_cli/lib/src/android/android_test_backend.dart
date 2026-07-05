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
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';
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
  }) : _adb = adb,
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
    await buildApkConfigOnly(options.flutter);
    await loadJavaPathFromFlutterDoctor(options.flutter.command);
    await detectOrchestratorVersion(options);

    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task('Building $subject');

      Process process;
      int exitCode;

      // :app:assembleDebug

      process =
          await _processManager.start(
              options.toGradleAssembleInvocation(
                isWindows: _platform.isWindows,
              ),
              runInShell: true,
              workingDirectory: _rootDirectory.childDirectory('android').path,
              environment: switch (javaPath) {
                final String javaPath => {'JAVA_HOME': javaPath},
                _ => {},
              },
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

      process =
          await _processManager.start(
              options.toGradleAssembleTestInvocation(
                isWindows: _platform.isWindows,
              ),
              runInShell: true,
              workingDirectory: _rootDirectory.childDirectory('android').path,
              environment: switch (javaPath) {
                final String javaPath => {'JAVA_HOME': javaPath},
                _ => {},
              },
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
      final process =
          await _processManager.start([
              flutterCommand.executable,
              ...flutterCommand.arguments,
              'doctor',
              '--verbose',
            ], runInShell: true)
            ..disposedBy(scope);

      process
          .listenStdOut(
            (line) {
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
          )
          .disposedBy(scope);
    });

    javaPath = await javaCompleterPath.future;
  }

  /// Execute `flutter build apk --config-only` to generate the gradlew file.
  ///
  /// This fix issue: https://github.com/leancodepl/patrol/issues/1668
  Future<void> buildApkConfigOnly(FlutterAppOptions options) async {
    await _disposeScope.run((scope) async {
      final process =
          await _processManager.start([
              options.command.executable,
              ...options.command.arguments,
              'build',
              'apk',
              '--config-only',
              if (options.buildName case final buildName?) ...[
                '--build-name',
                buildName,
              ],
              if (options.buildNumber case final buildNumber?) ...[
                '--build-number',
                buildNumber,
              ],
              if (options.noTreeShakeIcons) '--no-tree-shake-icons',
              '-t',
              options.target,
            ], runInShell: true)
            ..disposedBy(scope);

      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw Exception('Failed to build APK config with exit code $exitCode');
      }
    });
  }

  /// Detects the orchestrator version and warns the user if it's 1.5.0.
  /// Related to this regression: https://github.com/android/android-test/issues/2255
  Future<void> detectOrchestratorVersion(AndroidAppOptions options) async {
    await _disposeScope.run((scope) async {
      Process process;

      process =
          await _processManager.start(
              options.toGradleAppDependencies(isWindows: _platform.isWindows),
              runInShell: true,
              workingDirectory: _rootDirectory.childDirectory('android').path,
              environment: switch (javaPath) {
                final javaPath? => {'JAVA_HOME': javaPath},
                _ => {},
              },
            )
            ..disposedBy(scope);
      process
          .listenStdOut((l) {
            if (l.contains('androidx.test:orchestrator:1.5.0')) {
              _logger.warn(
                'Orchestrator version 1.5.0 detected\n'
                'Orchestrator 1.5.0 does not support whitespace in the test name.\n'
                'Please update the orchestrator version to 1.5.1 or higher.\n',
              );
            }
          })
          .disposedBy(scope);

      await process.exitCode;
    });
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
    void Function(Entry entry)? onLogEntry,
  }) async {
    // On emulators, automatically push the console auth token so that the
    // patrol biometric enrollment API can connect to the emulator console
    // without any manual setup step.
    if (!device.real) {
      await _pushEmulatorAuthToken(device.id);
    }

    await _disposeScope.run((scope) async {
      // Read patrol logs from logcat
      final processLogcat =
          await _adb.logcat(
              device: device.id,
              arguments: {'-T': '1'},
              filter: 'PatrolServer:I Patrol:I flutter:I *:S',
            )
            ..disposedBy(scope);

      final path = generateTestReportPath(
        rootPath: _rootDirectory.path,
        buildMode: options.flutter.buildMode,
        flavor: flavor,
      );
      final reportPath = _platform.isWindows
          ? path.replaceAll(r'\', '/')
          : path;

      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: processLogcat.listenStdOut,
              scope: scope,
              log: _logger.info,
              reportPath: reportPath,
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps,
              clearTestSteps: clearTestSteps,
              onLogEntry: onLogEntry,
            )
            ..listen()
            ..startTimer();

      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Executing tests of $subject');

      if (!device.real) {
        // On emulators, run a background helper that handles `enrollBiometricOnEmulator()`
        // calls by sending host-side `adb emu finger touch 1` commands. The in-device
        // telnet path does not advance fingerprint enrollment on Google Play API 36.
        unawaited(_runBiometricEnrollmentHelper(device.id, scope));
      }

      final process =
          await _processManager.start(
              options.toGradleConnectedTestInvocation(
                isWindows: _platform.isWindows,
              ),
              runInShell: true,
              environment: {
                'ANDROID_SERIAL': device.id,
                if (javaPath case final javaPath?) ...{'JAVA_HOME': javaPath},
              },
              workingDirectory: _rootDirectory.childDirectory('android').path,
            )
            ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process
          .listenStdErr((l) {
            const prefix = 'There were failing tests. ';
            if (l.contains(prefix)) {
              final msg = l.substring(prefix.length + 2);
              _logger.detail('\t$msg');
            } else {
              _logger.detail('\t$l');
            }
          })
          .disposedBy(scope);

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

  Future<void> _pushEmulatorAuthToken(String deviceId) async {
    final home =
        _platform.environment['HOME'] ??
        _platform.environment['USERPROFILE'] ??
        '';
    if (home.isEmpty) {
      return;
    }

    final tokenPath = _platform.isWindows
        ? '$home\\.emulator_console_auth_token'
        : '$home/.emulator_console_auth_token';

    final tokenFile = _rootDirectory.fileSystem.file(tokenPath);
    if (!tokenFile.existsSync()) {
      _logger.detail(
        'Emulator auth token not found at $tokenPath — '
        'biometric enrollment will not work on this emulator',
      );
      return;
    }

    _logger.detail('Pushing emulator auth token to $deviceId');
    try {
      final result = await Process.run(
        'adb',
        [
          '-s',
          deviceId,
          'push',
          tokenPath,
          '/data/local/tmp/.emulator_console_auth_token',
        ],
        runInShell: true,
      );
      if (result.exitCode == 0) {
        _logger.detail('Emulator auth token pushed to $deviceId');
      } else {
        _logger.warn(
          'Failed to push emulator auth token to $deviceId: ${result.stderr}',
        );
      }
    } catch (e) {
      _logger.warn('Failed to push emulator auth token to $deviceId: $e');
    }
  }

  /// Sends host-side `adb emu finger touch` commands when Kotlin's
  /// `enrollBiometricOnEmulator` writes the `/data/local/tmp/patrol_biometric_ready`
  /// flag file.  Runs concurrently with the test process for the lifetime of [scope].
  Future<void> _runBiometricEnrollmentHelper(
    String deviceId,
    DisposeScope scope,
  ) async {
    // Clean up any stale flags from a previous run.
    await Process.run(
      'adb',
      ['-s', deviceId, 'shell', 'rm', '-f', '/data/local/tmp/patrol_biometric_ready', '/data/local/tmp/patrol_biometric_done'],
      runInShell: true,
    );

    while (!scope.disposed) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (scope.disposed) {
        return;
      }

      final check = await Process.run(
        'adb',
        [
          '-s', deviceId, 'shell',
          'test -f /data/local/tmp/patrol_biometric_ready && echo yes || echo no',
        ],
        runInShell: true,
      );

      if (check.stdout.toString().trim() != 'yes') {
        continue;
      }

      // Delete the flag before sending touches to avoid re-triggering.
      await Process.run(
        'adb',
        ['-s', deviceId, 'shell', 'rm', '-f', '/data/local/tmp/patrol_biometric_ready'],
        runInShell: true,
      );

      _logger.detail('Biometric enrollment: sending host-side finger touches via adb emu');

      for (var i = 0; i < 30 && !scope.disposed; i++) {
        await Process.run(
          'adb',
          ['-s', deviceId, 'emu', 'finger', 'touch', '1'],
          runInShell: true,
        );
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await Process.run(
          'adb',
          ['-s', deviceId, 'emu', 'finger', 'touch', '-1'],
          runInShell: true,
        );
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Stop early when Kotlin signals that enrollment is complete (Done tapped).
        // Without this, residual touches from the tail of the 30-iteration batch hit
        // the test's BiometricPrompt and auto-authenticate it before the cancel action runs.
        final doneCheck = await Process.run(
          'adb',
          [
            '-s', deviceId, 'shell',
            'test -f /data/local/tmp/patrol_biometric_done && echo yes || echo no',
          ],
          runInShell: true,
        );
        if (doneCheck.stdout.toString().trim() == 'yes') {
          await Process.run(
            'adb',
            ['-s', deviceId, 'shell', 'rm', '-f', '/data/local/tmp/patrol_biometric_done'],
            runInShell: true,
          );
          _logger.detail('Biometric enrollment: done flag detected — stopping finger touches after $i iterations');
          break;
        }
      }
    }
  }

  Future<void> uninstall(String appId, Device device) async {
    _logger.detail('Uninstalling $appId from ${device.name}');
    await _adb.uninstall(appId, device: device.id);
    _logger.detail('Uninstalling $appId.test from ${device.name}');
    await _adb.uninstall('$appId.test', device: device.id);
  }

  /// Generates the Android test report path based on build mode and flavor.
  ///
  /// This method creates the correct file:// URL for the HTML test report
  /// generated by Gradle, following the structure:
  /// - No flavor: `file://{rootPath}/build/app/reports/androidTests/connected/{buildMode}/index.html`
  /// - With flavor: `file://{rootPath}/build/app/reports/androidTests/connected/{buildMode}/flavors/{flavor}/index.html`
  static String generateTestReportPath({
    required String rootPath,
    required BuildMode buildMode,
    String? flavor,
  }) {
    var buildModeAndFlavorPath = '';
    final buildModeString = buildMode.androidName.toLowerCase();

    if (flavor != null) {
      buildModeAndFlavorPath = '$buildModeString/flavors/$flavor/';
    } else {
      buildModeAndFlavorPath = '$buildModeString/';
    }

    return 'file://$rootPath/build/app/reports/androidTests/connected/${buildModeAndFlavorPath}index.html';
  }
}
