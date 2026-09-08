import 'dart:async';
import 'dart:convert' show LineSplitter;
import 'dart:io' show Process;

import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/android/android_artifacts.dart';
import 'package:patrol_cli/src/android/android_test_codegen.dart';
import 'package:patrol_cli/src/android/android_test_layout.dart';
import 'package:patrol_cli/src/android/android_video_recording_manager.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/completer.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest_generator.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_config.dart';
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

  AndroidTestLayout detectTestLayout() => AndroidTestLayoutDetector(
    _rootDirectory.childDirectory('android'),
  ).detect();

  Future<void> build(AndroidAppOptions options) async {
    await buildApkConfigOnly(options.flutter);
    verifyAndroidSdkResolved();
    await loadJavaPathFromFlutterDoctor(options.flutter.command);
    await detectOrchestratorVersion(options);

    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task('Building $subject');

      Process process;
      int exitCode;

      // Build-time test discovery + static JUnit codegen (experimental,
      // opt-in). Runs a host `flutter test` in discovery mode to obtain a
      // manifest of the Dart test tree, then generates a static JUnit class so
      // each Dart test becomes a real, individually-selectable native @Test
      // (and shows up under its own name in reports, not under the parameterized
      // `runDartTest[...]` wrapper). Failures are non-fatal: the build falls
      // back to the runtime-discovery host class.
      final codegen = AndroidTestCodegen(_rootDirectory.fileSystem);
      final androidDir = _rootDirectory.childDirectory('android');
      // Always start from a clean slate: remove any previously generated class
      // so a stale one can't linger after a failed discovery or an opt-out
      // (which would double-run tests alongside the runtime host class).
      codegen.deleteGenerated(androidDir, testLayout: options.testLayout);

      if (options.emitTestManifest) {
        final manifestPath =
            await TestManifestGenerator(
              processManager: _processManager,
              rootDirectory: _rootDirectory,
              logger: _logger,
            ).generate(
              options.flutter,
              scope,
              targetPlatform: TargetPlatform.android,
            );
        if (manifestPath == null) {
          throwToolExit(
            'Build-time test discovery failed; fix the errors above or disable '
            'emit_test_manifest.',
          );
        }
        final result = codegen.generate(
          manifestPath: manifestPath,
          androidDir: androidDir,
          testLayout: options.testLayout,
        );
        if (result != null) {
          _logger.info(
            'Generated ${result.testCount} static JUnit test method(s) in '
            '${result.fullyQualifiedClassNames.length} class(es) → '
            '${result.directoryPath}',
          );
        } else {
          _logger.warn(
            'Could not locate the Android test host class; falling back to '
            'runtime test discovery',
          );
        }
      }

      // Build the app APK.

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

      // Build the test APK.

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

  /// Verifies that Gradle will be able to locate the Android SDK before it is
  /// invoked.
  ///
  /// [buildApkConfigOnly] runs `flutter build apk --config-only`, which
  /// resolves the Android SDK the same way Flutter does — the `ANDROID_HOME`/
  /// `ANDROID_SDK_ROOT` env vars, `flutter config --android-sdk`, the default
  /// Android Studio location, etc. — and writes the resolved path to
  /// `android/local.properties` as `sdk.dir`. When Flutter can't resolve it,
  /// that entry is missing and the subsequent gradlew invocation hangs with no
  /// clear error. Fail fast with an actionable message instead.
  ///
  /// Must be called after [buildApkConfigOnly]. See
  /// https://github.com/leancodepl/patrol/issues/2364.
  @visibleForTesting
  void verifyAndroidSdkResolved() {
    final localProperties = _rootDirectory
        .childDirectory('android')
        .childFile('local.properties');

    final sdkDir = localProperties.existsSync()
        ? _readSdkDir(localProperties.readAsStringSync())
        : null;

    if (sdkDir == null) {
      throwToolExit(
        "Couldn't locate the Android SDK. Set the ANDROID_HOME environment "
        'variable to your Android SDK path, configure it with '
        '`flutter config --android-sdk <path>`, or run `patrol doctor` to '
        'diagnose your setup.',
      );
    }

    if (!_rootDirectory.fileSystem.directory(sdkDir).existsSync()) {
      throwToolExit(
        'The configured Android SDK directory does not exist: $sdkDir. Fix '
        '`sdk.dir` in android/local.properties (or the ANDROID_HOME '
        'environment variable), or run `patrol doctor` to diagnose your setup.',
      );
    }
  }

  /// Reads the `sdk.dir` value from the contents of a `local.properties` file,
  /// or `null` when it is absent or empty.
  static String? _readSdkDir(String localProperties) {
    for (final line in localProperties.split(RegExp(r'\r?\n'))) {
      final trimmed = line.trim();
      if (trimmed.startsWith('sdk.dir=')) {
        final value = _unescapePropertyValue(
          trimmed.substring('sdk.dir='.length).trim(),
        );
        return value.isEmpty ? null : value;
      }
    }
    return null;
  }

  /// Undoes the `.properties` escaping Flutter applies when writing `sdk.dir`,
  /// e.g. `C\:\\Users\\me\\Android\\sdk` on Windows.
  static String _unescapePropertyValue(String value) {
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final char = value[i];
      if (char == r'\' && i + 1 < value.length) {
        buffer.write(value[++i]);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
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
              options.toGradleTestDependencies(isWindows: _platform.isWindows),
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
      // Drain stderr, or the process hangs on Windows when the pipe fills.
      process.listenStdErr((l) => _logger.detail('\t$l')).disposedBy(scope);

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
    VideoRecordingConfig? videoConfig,
    bool pullScreenshots = false,
    String? screenshotsOutputDir,
  }) async {
    await _disposeScope.run((scope) async {
      // Create video recording manager if enabled
      AndroidVideoRecordingManager? videoRecordingManager;
      if (videoConfig?.enabled ?? false) {
        videoRecordingManager = AndroidVideoRecordingManager(
          processManager: _processManager,
          adb: _adb,
          rootDirectory: _rootDirectory,
          logger: _logger,
          config: videoConfig!,
          device: device,
          scope: scope,
        );
      }

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
        testLayout: options.testLayout,
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
              onLogEntry:
                  videoRecordingManager?.wrapOnLogEntry(onLogEntry) ??
                  onLogEntry,
            )
            ..listen()
            ..startTimer();

      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Executing tests of $subject');

      // When static codegen ran, restrict the run to the generated class so the
      // parameterized host class doesn't also perform its runtime-discovery
      // launch (which would run every test a second time).
      final generatedClasses = options.emitTestManifest
          ? AndroidTestCodegen(
              _rootDirectory.fileSystem,
            ).findGeneratedClassNames(
              _rootDirectory.childDirectory('android'),
              testLayout: options.testLayout,
            )
          : const <String>[];
      final onlyTestClass = generatedClasses.isEmpty
          ? null
          : generatedClasses.join(',');
      final targetAppId = _resolveBuiltApplicationId(options);

      // Start from a clean slate so the screenshots pulled after this run
      // belong to it. Leftovers from an aborted run or from `develop` (which
      // captures but never pulls) would otherwise land in its artifacts.
      if (pullScreenshots) {
        await _adb.remove(
          _deviceScreenshotsDir,
          device: device.id,
          recursive: true,
        );
      }

      final process =
          await _processManager.start(
              options.toGradleConnectedTestInvocation(
                isWindows: _platform.isWindows,
                onlyTestClass: onlyTestClass,
                targetAppId: targetAppId,
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

      // Cleanup video recording manager
      await videoRecordingManager?.dispose();

      // Pull native screenshots (failure and on-demand) off the device.
      // Runs whether tests passed or failed - before the exit-code check below
      // that throws on failure - so failing runs still yield their screenshots.
      if (pullScreenshots && screenshotsOutputDir != null) {
        await pullDeviceScreenshots(device, screenshotsOutputDir);
      }

      // Don't print the summary in develop
      if (!interruptible) {
        _logger.info(patrolLogReader.summary);
        final recordingSummary = videoRecordingManager?.recordingSummary;
        if (recordingSummary != null) {
          _logger.info(recordingSummary);
        }
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

  /// Runs already-built tests without rebuilding, via `adb shell am instrument`
  /// (the true no-rebuild path, no Gradle up-to-date check). Requires a prior
  /// `patrol build android --emit-test-manifest`, whose generated JUnit classes
  /// make each Dart test an individually-addressable `<class>#<method>`.
  ///
  /// [onlyTests] are Dart test names (as shown by discovery); empty runs the
  /// whole generated class. Backs `patrol test-without-building [--only ...]`.
  Future<void> executeWithoutBuilding(
    AndroidAppOptions options,
    Device device, {
    String? flavor,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    List<String> onlyTests = const [],
    void Function(Entry entry)? onLogEntry,
  }) async {
    final generatedClassNames = AndroidTestCodegen(_rootDirectory.fileSystem)
        .findGeneratedClassNames(
          _rootDirectory.childDirectory('android'),
          testLayout: options.testLayout,
        );
    if (generatedClassNames.isEmpty) {
      throwToolExit(
        'No generated test class found. Run `patrol build android '
        '--emit-test-manifest` (or set patrol.emit_test_manifest in pubspec) '
        'before `patrol test-without-building`.',
      );
    }

    final classArg = _resolveClassArg(generatedClassNames, onlyTests);

    // `patrol build android` only ASSEMBLES the app + androidTest APKs; it does
    // not install them. Install both now so a clean device works with the
    // documented `patrol build` -> `patrol test-without-building` flow.
    await _installApks(options, device, flavor: flavor);

    // Resolve the real instrumentation component from the device so custom
    // testApplicationId / custom runners are honored; falls back to the default.
    final (
      instrumentPackage,
      instrumentRunner,
    ) = await _resolveInstrumentationComponent(
      _resolveBuiltTestApplicationId(options),
      device,
    );

    await _disposeScope.run((scope) async {
      final processLogcat =
          await _adb.logcat(
              device: device.id,
              arguments: {'-T': '1'},
              filter: 'PatrolServer:I Patrol:I flutter:I *:S',
            )
            ..disposedBy(scope);

      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: processLogcat.listenStdOut,
              scope: scope,
              log: _logger.info,
              reportPath: null,
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps,
              clearTestSteps: clearTestSteps,
              onLogEntry: onLogEntry,
            )
            ..listen()
            ..startTimer();

      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Executing tests of $subject (no build)');

      // `am instrument -w` exits 0 even when tests fail, so detect failure from
      // its textual output instead of the exit code.
      var failed = false;
      final process =
          await _adb.instrument(
              packageName: instrumentPackage,
              intentClass: instrumentRunner,
              device: device.id,
              arguments: {
                'class': classArg,
                'patrolAppId': _resolveBuiltApplicationId(options),
              },
            )
            ..disposedBy(scope);
      process
          .listenStdOut((l) {
            if (l.contains('FAILURES!!!') ||
                l.contains('INSTRUMENTATION_FAILED') ||
                l.contains('Process crashed')) {
              failed = true;
            }
            _logger.detail('\t: $l');
          })
          .disposedBy(scope);
      process.listenStdErr((l) => _logger.detail('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      patrolLogReader.stopTimer();
      processLogcat.kill();
      _logger.info(patrolLogReader.summary);

      if (exitCode == 0 && !failed) {
        task.complete('Completed executing $subject');
      } else {
        const cause = 'am instrument reported failing tests';
        task.fail('Failed to execute tests of $subject ($cause)');
        throw Exception(cause);
      }
    });
  }

  /// Builds the `-e class` value for `am instrument`: the generated classes
  /// ([generatedClassNames]) to run all of them, or a comma-separated selection mapped from the
  /// requested [onlyTests] entries via the build-time manifest. A Dart test name
  /// becomes `<class>#<method>`, a test file path becomes the bare `<class>` so
  /// the whole file costs one entry.
  String _resolveClassArg(
    List<String> generatedClassNames,
    List<String> onlyTests,
  ) {
    if (onlyTests.isEmpty) {
      return generatedClassNames.join(',');
    }
    final package = generatedClassNames.first.substring(
      0,
      generatedClassNames.first.lastIndexOf('.'),
    );
    final manifest = TestManifest.loadFromBuild(_rootDirectory);
    if (manifest == null) {
      throwToolExit(
        'No build-time test manifest found. Run `patrol build android '
        '--emit-test-manifest` before `patrol test-without-building`.',
      );
    }
    final tests = manifest.tests;
    final selection = resolveOnlySelection(tests, onlyTests);
    if (selection.isEmpty) {
      throwToolExit(
        'None of the requested --only test(s) were found in the manifest.\n'
        'Pass an exact Dart test name or a test file path.\n'
        'Available tests:\n${tests.map((t) => '  ${t.dartName}').join('\n')}',
      );
    }
    if (selection.unmatched.isNotEmpty) {
      _logger.warn(
        'Ignoring --only ${selection.unmatched.join(', ')}: no such Dart test '
        'or test file in the manifest.',
      );
    }
    return [
      ...selection.classNames.map((name) => '$package.$name'),
      ...selection.tests.map((name) => '$package.${name.qualified}'),
    ].join(',');
  }

  /// Installs the app + androidTest APKs produced by `patrol build android`
  /// onto [device] (via `adb install -r -t`, no Gradle). Required before
  /// `am instrument` in the test-without-building flow, because `patrol build` only
  /// assembles the APKs, it does not install them.
  Future<void> _installApks(
    AndroidAppOptions options,
    Device device, {
    String? flavor,
  }) async {
    final artifacts = AndroidArtifactResolver(_rootDirectory);
    final app = artifacts.app(
      buildMode: options.flutter.buildMode,
      flavor: flavor,
    );
    final test = artifacts.test(
      layout: options.testLayout,
      buildMode: options.flutter.buildMode,
      flavor: flavor,
    );

    _logger.detail('Installing app APK: ${app.apk.path}');
    await _adbInstall(app.apk.path, device);
    _logger.detail('Installing test APK: ${test.apk.path}');
    await _adbInstall(test.apk.path, device);
  }

  /// Runs `adb install -r -t <path>` on [device]. `Adb.install` does not pass
  /// the reinstall/allow-test-package flags, so shell out directly.
  Future<void> _adbInstall(String path, Device device) async {
    final result = await _processManager.run([
      'adb',
      ...['-s', device.id],
      'install',
      ...['-r', '-t'],
      path,
    ], runInShell: true);
    if (result.exitCode != 0) {
      throwToolExit(
        'Failed to install $path (adb install exited ${result.exitCode}):\n'
        '${result.stdErr}',
      );
    }
  }

  /// Resolves the `<package>/<runner>` component for `am instrument` by querying
  /// `pm list instrumentation` on [device]. This makes custom `testApplicationId`
  /// and custom runners (e.g. BrowserStack's `BrowserstackPatrolJUnitRunner`)
  /// authoritative while keeping the conventional
  /// `<test applicationId>/pl.leancode.patrol.PatrolJUnitRunner` as the fallback.
  Future<(String, String)> _resolveInstrumentationComponent(
    String testPackageName,
    Device device,
  ) async {
    final fallback = (testPackageName, 'pl.leancode.patrol.PatrolJUnitRunner');

    final result = await _processManager.run([
      'adb',
      ...['-s', device.id],
      'shell',
      ...['pm', 'list', 'instrumentation'],
    ], runInShell: true);

    if (result.exitCode != 0) {
      _logger.detail(
        'Could not query instrumentation (`pm list instrumentation` exited '
        '${result.exitCode}); using default component '
        '${fallback.$1}/${fallback.$2}',
      );
      return fallback;
    }

    final entries = _parseInstrumentation(result.stdOut);
    final candidates = entries
        .where((entry) => entry.package == testPackageName)
        .toList();
    if (candidates.isEmpty) {
      _logger.detail(
        'No instrumentation found in $testPackageName; using default '
        'component ${fallback.$1}/${fallback.$2}',
      );
      return fallback;
    }
    // Among matches, prefer a Patrol runner.
    candidates.sort((a, b) {
      int rank(_Instrumentation e) =>
          e.runner.contains('PatrolJUnitRunner') ? 0 : 1;
      return rank(a).compareTo(rank(b));
    });
    final chosen = candidates.first;
    _logger.detail(
      'Using instrumentation component ${chosen.package}/${chosen.runner} '
      '(target=${chosen.target})',
    );
    return (chosen.package, chosen.runner);
  }

  /// Parses `pm list instrumentation` output lines of the form
  /// `instrumentation:<pkg>/<runner> (target=<applicationId>)`.
  List<_Instrumentation> _parseInstrumentation(String output) {
    final regex = RegExp(
      r'^instrumentation:(\S+?)/(\S+?)\s+\(target=([^)]+)\)',
    );
    final out = <_Instrumentation>[];
    for (final line in const LineSplitter().convert(output)) {
      final match = regex.firstMatch(line.trim());
      if (match == null) {
        continue;
      }
      out.add(
        _Instrumentation(
          package: match.group(1)!,
          runner: match.group(2)!,
          target: match.group(3),
        ),
      );
    }
    return out;
  }

  Future<void> uninstall(AndroidAppOptions options, Device device) async {
    final appId = _resolveBuiltApplicationId(options);
    final testAppId = _resolveBuiltTestApplicationId(options);
    _logger.detail('Uninstalling $appId from ${device.name}');
    await _adb.uninstall(appId, device: device.id);
    _logger.detail('Uninstalling $testAppId from ${device.name}');
    await _adb.uninstall(testAppId, device: device.id);
  }

  /// Where patrol writes native screenshots on the device.
  static const _deviceScreenshotsDir = '/sdcard/Download/screenshots';

  /// Pulls native screenshots from [device] into [outputDir]. Best-effort: never
  /// throws; a missing directory (nothing captured) is not an error.
  @visibleForTesting
  Future<void> pullDeviceScreenshots(Device device, String outputDir) async {
    try {
      final destination = _rootDirectory.childDirectory(outputDir);
      // `adb pull` renames the pulled dir to [destination] only when it doesn't
      // exist; otherwise it nests under it. Start clean so the caller's chosen
      // basename is honored (e.g. `--screenshots-output-dir=my_shots`).
      if (destination.existsSync()) {
        destination.deleteSync(recursive: true);
      }
      destination.parent.createSync(recursive: true);

      final pullResult = await _adb.pull(
        source: _deviceScreenshotsDir,
        destination: destination.path,
        device: device.id,
      );

      if (pullResult.exitCode != 0) {
        _logger.detail('No screenshots to pull from device.');
        return;
      }

      _logger.info('Screenshots saved to ${destination.path}');

      // Remove them so the next run doesn't re-pull stale files.
      try {
        await _adb.remove(
          _deviceScreenshotsDir,
          device: device.id,
          recursive: true,
        );
      } catch (err) {
        _logger.detail('Failed to remove screenshots from device: $err');
      }
    } catch (err) {
      _logger.warn('Failed to pull screenshots from device: $err');
    }
  }

  String _resolveBuiltApplicationId(AndroidAppOptions options) {
    return AndroidArtifactResolver(_rootDirectory)
        .app(
          buildMode: options.flutter.buildMode,
          flavor: options.flutter.flavor,
        )
        .applicationId;
  }

  String _resolveBuiltTestApplicationId(AndroidAppOptions options) {
    return AndroidArtifactResolver(_rootDirectory)
        .test(
          layout: options.testLayout,
          buildMode: options.flutter.buildMode,
          flavor: options.flutter.flavor,
        )
        .applicationId;
  }

  /// Generates the Android test report path based on build mode and flavor.
  ///
  /// This method creates the correct file:// URL for the HTML test report
  /// generated by Gradle.
  static String generateTestReportPath({
    required String rootPath,
    required BuildMode buildMode,
    AndroidTestLayout testLayout = AndroidTestLayout.selfInstrumenting,
    String? flavor,
  }) {
    var buildModeAndFlavorPath = '';
    final buildModeString = buildMode.androidName.toLowerCase();

    if (flavor != null) {
      buildModeAndFlavorPath = '$buildModeString/flavors/$flavor/';
    } else {
      buildModeAndFlavorPath = '$buildModeString/';
    }

    final project = testLayout == AndroidTestLayout.selfInstrumenting
        ? 'patrolTest'
        : 'app';
    return 'file://$rootPath/build/$project/reports/androidTests/connected/${buildModeAndFlavorPath}index.html';
  }
}

/// A single entry parsed from `adb shell pm list instrumentation`.
class _Instrumentation {
  _Instrumentation({
    required this.package,
    required this.runner,
    required this.target,
  });

  /// The instrumentation's own package (the test APK's applicationId).
  final String package;

  /// The fully-qualified runner class.
  final String runner;

  /// The `target` applicationId the instrumentation runs against, or `null`
  /// when the line carried no `(target=...)`.
  final String? target;
}
