import 'dart:async';
import 'dart:convert' show LineSplitter;
import 'dart:io' show Process;

import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/android/android_test_codegen.dart';
import 'package:patrol_cli/src/android/android_video_recording_manager.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/completer.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest_generator.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_config.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_manager.dart';
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
      // Always start from a clean slate: remove any previously generated class
      // so a stale one can't linger after a failed discovery or an opt-out
      // (which would double-run tests alongside the runtime host class).
      final codegen = AndroidTestCodegen(_rootDirectory.fileSystem);
      final androidDir = _rootDirectory.childDirectory('android');
      codegen.deleteGenerated(androidDir);

      if (options.emitTestManifest) {
        final manifestPath = await TestManifestGenerator(
          processManager: _processManager,
          rootDirectory: _rootDirectory,
          logger: _logger,
        ).generate(options.flutter, scope);
        if (manifestPath == null) {
          throwToolExit(
            'Build-time test discovery failed; fix the errors above or disable '
            'emit_test_manifest.',
          );
        }
        final result = codegen.generate(
          manifestPath: manifestPath,
          androidDir: androidDir,
        );
        if (result != null) {
          _logger.info(
            'Generated ${result.testCount} static JUnit test method(s) → '
            '${result.outputPath}',
          );
        } else {
          _logger.warn(
            'Could not locate the androidTest host class; falling back to '
            'runtime test discovery',
          );
        }
      }

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
      // Drain stderr, or the process hangs on Windows when the pipe fills.
      process.listenStdErr((l) => _logger.detail('\t$l')).disposedBy(scope);

      await process.exitCode;
    });
  }

  /// Builds the `onLogEntry` callback handed to [PatrolLogReader], composing
  /// (outermost first): an optional [acceptLogEntries] gate that drops entries
  /// while it returns false, an optional [videoRecordingManager] that starts
  /// and stops recordings on test lifecycle entries, and the caller's
  /// [onLogEntry]. The gate must sit OUTSIDE the recording manager: with
  /// prebuilt APKs, entries emitted by the placeholder test baked into the APK
  /// at build time must neither reach the caller nor start a recording.
  @visibleForTesting
  static void Function(Entry entry)? composeLogEntryCallback({
    void Function(Entry entry)? onLogEntry,
    VideoRecordingManager? videoRecordingManager,
    bool Function()? acceptLogEntries,
  }) {
    final withVideo = videoRecordingManager == null
        ? onLogEntry
        : videoRecordingManager.wrapOnLogEntry(onLogEntry);
    if (acceptLogEntries == null || withVideo == null) {
      return withVideo;
    }
    return (entry) {
      if (acceptLogEntries()) {
        withVideo(entry);
      }
    };
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
              onLogEntry: composeLogEntryCallback(
                onLogEntry: onLogEntry,
                videoRecordingManager: videoRecordingManager,
              ),
            )
            ..listen()
            ..startTimer();

      final subject = '${options.description} on ${device.description}';
      final task = _logger.task('Executing tests of $subject');

      // When static codegen ran, restrict the run to the generated class so the
      // parameterized host class doesn't also perform its runtime-discovery
      // launch (which would run every test a second time).
      final onlyTestClass = options.emitTestManifest
          ? AndroidTestCodegen(
              _rootDirectory.fileSystem,
            ).findGeneratedClassName(_rootDirectory.childDirectory('android'))
          : null;

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

  /// Makes a checkout that was never built ready for `flutter attach`.
  ///
  /// `flutter attach` starts the frontend_server (initial compile) before it
  /// runs the source generators, and passes `-Dflutter.dart_plugin_registrant`
  /// only if `.dart_tool/flutter_build/dart_plugin_registrant.dart` already
  /// exists. On a fresh checkout it doesn't, so every Dart-registered plugin
  /// (e.g. `shared_preferences_android`) throws `MissingPluginException` after
  /// the first Hot Restart. A normal `patrol develop` never hits this because
  /// the Gradle build generates the file first. Here no Gradle runs, so run a
  /// one-off `flutter build bundle --debug` (Dart-only compile, ~20 s) instead;
  /// it also leaves an `app.dill` the attach compiler can initialize from.
  Future<void> prepareSourcesForAttach(FlutterAppOptions options) async {
    final registrant = _rootDirectory
        .childDirectory('.dart_tool')
        .childDirectory('flutter_build')
        .childFile('dart_plugin_registrant.dart');
    if (registrant.existsSync()) {
      _logger.detail('Dart plugin registrant already generated, skipping');
      return;
    }
    await _disposeScope.run((scope) async {
      final task = _logger.task(
        'Preparing sources for attach (flutter build bundle)',
      );
      final process =
          await _processManager.start([
              options.command.executable,
              ...options.command.arguments,
              'build',
              'bundle',
              '--debug',
              if (options.flavor case final flavor?) ...['--flavor', flavor],
              ...['-t', options.target],
              for (final dartDefine in options.dartDefines.entries) ...[
                '--dart-define',
                '${dartDefine.key}=${dartDefine.value}',
              ],
              for (final path in options.dartDefineFromFilePaths) ...[
                '--dart-define-from-file',
                path,
              ],
            ], runInShell: true)
            ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('	: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('	$l')).disposedBy(scope);
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        task.fail('Failed to prepare sources for attach (exit code $exitCode)');
        throw Exception('flutter build bundle failed with code $exitCode');
      }
      task.complete('Prepared sources for attach');
    });
  }

  /// Installs the prebuilt app + androidTest APKs found in [apksDir] onto
  /// [device] with `adb install -r -t`, without Gradle.
  ///
  /// Runs before [executePrebuilt] so that a bad directory or a failed install
  /// surfaces as a [ToolExit] from the setup phase - the way a Gradle build
  /// failure would - instead of leaving `flutter attach` waiting for an app
  /// that was never installed.
  Future<void> installPrebuiltApks({
    required String apksDir,
    required Device device,
  }) async {
    final dir = _rootDirectory.fileSystem.directory(apksDir);
    if (!dir.existsSync()) {
      throwToolExit('Prebuilt APK directory does not exist: $apksDir');
    }
    File? appApk;
    File? testApk;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.apk')) {
        continue;
      }
      if (entity.path.endsWith('-androidTest.apk')) {
        testApk ??= entity;
      } else {
        appApk ??= entity;
      }
    }
    if (appApk == null || testApk == null) {
      throwToolExit(
        'Expected an app APK and a *-androidTest.apk in $apksDir (got '
        'app=${appApk?.path}, test=${testApk?.path}).',
      );
    }

    _logger.detail('Installing app APK: ${appApk.path}');
    await _adbInstall(appApk.path, device);
    _logger.detail('Installing androidTest APK: ${testApk.path}');
    await _adbInstall(testApk.path, device);
  }

  /// Develop-mode counterpart of [execute] for APKs built on another machine
  /// (`patrol develop --use-prebuilt-apks`): starts the Patrol instrumentation
  /// directly with `am instrument -w`, bypassing Gradle entirely. The APKs
  /// must already be installed - see [installPrebuiltApks].
  ///
  /// They must come from a develop-mode build (`patrol build android
  /// --develop`): with `PATROL_HOT_RESTART=true` baked in, the Dart side never
  /// reports `PatrolAppService` readiness, so `PatrolJUnitRunner` blocks in
  /// `waitForPatrolAppService()` and the app process stays alive for
  /// `flutter attach` + Hot Restart. Test-orchestrator extras (e.g.
  /// `clearPackageData`) are not applied - they never were in develop mode.
  Future<void> executePrebuilt(
    AndroidAppOptions options,
    Device device, {
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    void Function(Entry entry)? onLogEntry,
    VideoRecordingConfig? videoConfig,
    bool Function()? acceptLogEntries,
  }) async {
    final packageName = options.packageName;
    if (packageName == null) {
      throwToolExit(
        'Android applicationId is unknown. Set patrol.android.package_name in '
        'pubspec.yaml or pass --package-name.',
      );
    }

    final (instrumentPackage, instrumentRunner) =
        await _resolveInstrumentationComponent(packageName, device);

    await _disposeScope.run((scope) async {
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
        flavor: options.flutter.flavor,
      );
      final reportPath = _platform.isWindows
          ? path.replaceAll(r'\', '/')
          : path;

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

      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: processLogcat.listenStdOut,
              scope: scope,
              log: _logger.info,
              reportPath: reportPath,
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps,
              clearTestSteps: clearTestSteps,
              onLogEntry: composeLogEntryCallback(
                onLogEntry: onLogEntry,
                videoRecordingManager: videoRecordingManager,
                acceptLogEntries: acceptLogEntries,
              ),
            )
            ..listen()
            ..startTimer();

      final subject =
          'prebuilt ${options.description} on ${device.description}';
      final task = _logger.task('Executing tests of $subject (no build)');

      // No `-e class`: AndroidJUnitRunner discovers the (single) Patrol host
      // class in the androidTest APK itself, exactly like Gradle's connected
      // task does. In develop mode this call blocks until the session quits.
      final process =
          await _adb.instrument(
              packageName: instrumentPackage,
              intentClass: instrumentRunner,
              device: device.id,
            )
            ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t: $l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.detail('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      patrolLogReader.stopTimer();
      processLogcat.kill();

      // Stops and saves any in-flight recording (e.g. the session was quit
      // mid-test).
      await videoRecordingManager?.dispose();

      if (exitCode == 0) {
        task.complete('Completed executing $subject');
      } else {
        task.complete('App shut down on request');
      }
    });
  }

  /// Runs already-built tests without rebuilding, via `adb shell am instrument`
  /// (the true no-rebuild path — no Gradle up-to-date check). Requires a prior
  /// `patrol build android --emit-test-manifest`, whose generated JUnit class
  /// makes each Dart test an individually-addressable `<fqcn>#<method>`.
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
    final packageName = options.packageName;
    if (packageName == null) {
      throwToolExit(
        'Android applicationId is unknown. Set patrol.android.package_name in '
        'pubspec.yaml or pass --package-name.',
      );
    }

    final fqcn = AndroidTestCodegen(
      _rootDirectory.fileSystem,
    ).findGeneratedClassName(_rootDirectory.childDirectory('android'));
    if (fqcn == null) {
      throwToolExit(
        'No generated test class found. Run `patrol build android '
        '--emit-test-manifest` (or set patrol.emit_test_manifest in pubspec) '
        'before `patrol test-without-building`.',
      );
    }

    final classArg = _resolveClassArg(fqcn, onlyTests);

    // `patrol build android` only ASSEMBLES the app + androidTest APKs; it does
    // not install them. Install both now so a clean device works with the
    // documented `patrol build` -> `patrol test-without-building` flow.
    await _installApks(options, device, flavor: flavor);

    // Resolve the real instrumentation component from the device so custom
    // testApplicationId / custom runners are honored; falls back to the default.
    final (instrumentPackage, instrumentRunner) =
        await _resolveInstrumentationComponent(packageName, device);

    await _disposeScope.run((scope) async {
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
      final task = _logger.task('Executing tests of $subject (no build)');

      // `am instrument -w` exits 0 even when tests fail, so detect failure from
      // its textual output instead of the exit code.
      var failed = false;
      final process =
          await _adb.instrument(
              packageName: instrumentPackage,
              intentClass: instrumentRunner,
              device: device.id,
              arguments: {'class': classArg},
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

  /// Builds the `-e class` value for `am instrument`: the bare [fqcn] to run the
  /// whole generated class, or a comma-separated `<fqcn>#<method>` list mapped
  /// from the requested [onlyTests] Dart names via the build-time manifest.
  String _resolveClassArg(String fqcn, List<String> onlyTests) {
    if (onlyTests.isEmpty) {
      return fqcn;
    }
    final manifest = TestManifest.loadFromBuild(_rootDirectory);
    if (manifest == null) {
      throwToolExit(
        'No build-time test manifest found. Run `patrol build android '
        '--emit-test-manifest` before `patrol test-without-building`.',
      );
    }
    final tests = manifest.tests;
    final methods = generateAndroidMethodNames(tests);
    final out = <String>[];
    for (var i = 0; i < tests.length; i++) {
      if (onlyTests.contains(tests[i].dartName)) {
        out.add('$fqcn#${methods[i]}');
      }
    }
    if (out.isEmpty) {
      throwToolExit(
        'None of the requested --only test(s) were found in the manifest.\n'
        'Available tests:\n${tests.map((t) => '  ${t.dartName}').join('\n')}',
      );
    }
    return out.join(',');
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
    final buildMode = options.flutter.buildMode.androidName.toLowerCase();
    final apkDir = _rootDirectory
        .childDirectory('build')
        .childDirectory('app')
        .childDirectory('outputs')
        .childDirectory('apk');

    if (!apkDir.existsSync()) {
      throwToolExit(
        'No built APKs found under ${apkDir.path}. Run `patrol build android '
        '--emit-test-manifest` before `patrol test-without-building`.',
      );
    }

    bool matches(File apk) {
      final segments = apk.path.split(RegExp(r'[/\\]'));
      if (!segments.contains(buildMode)) {
        return false;
      }
      // When a flavor is set, its (case-sensitive) directory segment is present
      // in both the app and androidTest APK paths; use it to disambiguate.
      if (flavor != null && !segments.contains(flavor)) {
        return false;
      }
      return true;
    }

    File? appApk;
    File? testApk;
    for (final entity in apkDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.apk')) {
        continue;
      }
      if (!matches(entity)) {
        continue;
      }
      final inAndroidTestDir = entity.path
          .split(RegExp(r'[/\\]'))
          .contains('androidTest');
      if (entity.path.endsWith('-androidTest.apk')) {
        testApk ??= entity;
      } else if (!inAndroidTestDir) {
        appApk ??= entity;
      }
    }

    if (appApk == null || testApk == null) {
      throwToolExit(
        'Could not locate the built app and androidTest APKs under '
        '${apkDir.path}. Run `patrol build android --emit-test-manifest` '
        'before `patrol test-without-building`.',
      );
    }

    _logger.detail('Installing app APK: ${appApk.path}');
    await _adbInstall(appApk.path, device);
    _logger.detail('Installing androidTest APK: ${testApk.path}');
    await _adbInstall(testApk.path, device);
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
  /// `${packageName}.test/pl.leancode.patrol.PatrolJUnitRunner` as the fallback.
  Future<(String, String)> _resolveInstrumentationComponent(
    String packageName,
    Device device,
  ) async {
    final fallback = (
      '$packageName.test',
      'pl.leancode.patrol.PatrolJUnitRunner',
    );

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
    // Prefer an exact applicationId (target) match; fall back to a prefix match
    // to tolerate a flavor's applicationIdSuffix.
    final exact = entries.where((e) => e.target == packageName).toList();
    final prefixed = entries
        .where((e) => e.target != null && e.target!.startsWith(packageName))
        .toList();
    final candidates = exact.isNotEmpty ? exact : prefixed;
    if (candidates.isEmpty) {
      _logger.detail(
        'No instrumentation targeting $packageName found; using default '
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

  Future<void> uninstall(String appId, Device device) async {
    _logger.detail('Uninstalling $appId from ${device.name}');
    await _adb.uninstall(appId, device: device.id);
    _logger.detail('Uninstalling $appId.test from ${device.name}');
    await _adb.uninstall('$appId.test', device: device.id);
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
