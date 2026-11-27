import 'dart:async';
import 'dart:convert';
import 'dart:io' show Process;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart'
    show getObservationUrl;
import 'package:patrol_cli/src/crossplatform/patrol_build_environment.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest.dart';
import 'package:patrol_cli/src/crossplatform/test_manifest_generator.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_config.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_host_server.dart';
import 'package:patrol_cli/src/ios/ios_video_recording_manager.dart';
import 'package:patrol_cli/src/ios/simulator_hinge.dart';
import 'package:patrol_cli/src/ios/xcode_test_codegen.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/patrol_log_reader.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

enum BuildMode {
  debug,
  profile,
  release;

  static const _defaultScheme = 'Runner';

  /// Name of this build mode in the Xcode Build Configuration format.
  ///
  /// Flutter build mode name starts with with a lowercase letter, for example
  /// `debug` or `release`.
  ///
  /// Xcode Build Configuration names starts with an uppercase letter, for
  /// example 'Debug' or 'Release'.
  String get xcodeName => name.replaceFirst(name[0], name[0].toUpperCase());

  // It's the same as xcodeName, but let's keep it for clarity.
  /// Name of this build mode as a part of Gradle task name.
  String get androidName => xcodeName;

  String createScheme(String? flavor) {
    if (flavor == null) {
      return _defaultScheme;
    }
    return flavor;
  }

  String createConfiguration(String? flavor) {
    if (flavor == null) {
      return xcodeName;
    }
    return '$xcodeName-$flavor';
  }
}

class IOSTestBackend {
  IOSTestBackend({
    required this._processManager,
    required this._platform,
    required this._fs,
    required this._rootDirectory,
    required DisposeScope parentDisposeScope,
    required this._logger,
  }) : _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  static const _xcodebuildInterrupted = -15;

  final ProcessManager _processManager;
  final NativePlatform _platform;
  final FileSystem _fs;
  final Directory _rootDirectory;
  final DisposeScope _disposeScope;
  final Logger _logger;

  Future<void> build(IOSAppOptions options) async {
    await _disposeScope.run((scope) async {
      final subject = options.description;
      final task = _logger.task(
        'Building $subject (${options.flutter.buildMode.name})',
      );

      Process process;

      final isRealDevice = !options.simulator;
      final isReleaseMode = options.flutter.buildMode == BuildMode.release;
      if (isRealDevice && !isReleaseMode) {
        throwToolExit(
          'Running on physical iOS devices is possible only in release mode',
        );
      }

      // Reset on every build, so a stale .inc never runs old tests.
      _resetGeneratedInc();
      if (_discoveryModeFile.existsSync()) {
        _discoveryModeFile.deleteSync();
      }
      _verifyRunnerSetup(emitTestManifest: options.emitTestManifest);

      if (options.emitTestManifest) {
        final manifestPath = await TestManifestGenerator(
          processManager: _processManager,
          rootDirectory: _rootDirectory,
          logger: _logger,
        ).generate(options.flutter, scope, targetPlatform: TargetPlatform.iOS);
        if (manifestPath == null) {
          throwToolExit(
            'Build-time test discovery failed; fix the errors above, or pass '
            '--no-emit-test-manifest to use runtime discovery.',
          );
        }
        _generateXcodeTests(manifestPath);
      }

      // flutter build ios --config-only

      var flutterBuildKilled = false;
      process = await _processManager.start(
        options.toFlutterBuildInvocation(options.flutter.buildMode),
        runInShell: true,
      );
      scope.addDispose(() {
        process.kill();
        flutterBuildKilled = true; // `flutter build` has exit code 0 on SIGINT
      });
      process.listenStdOut((l) => _logger.info('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      var exitCode = await process.exitCode;
      final flutterCommand = options.flutter.command;
      if (exitCode != 0) {
        final cause = '`$flutterCommand build ios` exited with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throwToolExit(cause);
      } else if (flutterBuildKilled) {
        final cause = '`$flutterCommand build ios` was interrupted';
        task.fail('Failed to build $subject ($cause)');
        throwToolInterrupted(cause);
      }

      // xcodebuild build-for-testing

      process =
          await _processManager.start(
              options.buildForTestingInvocation(),
              environment: darwinEnvironment,
              runInShell: true,
              workingDirectory: _rootDirectory.childDirectory('ios').path,
            )
            ..disposedBy(scope);
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.err('\t$l')).disposedBy(scope);
      exitCode = await process.exitCode;
      if (exitCode == 0) {
        task.complete('Completed building $subject');
        _discoveryModeFile
          ..createSync(recursive: true)
          ..writeAsStringSync(
            options.emitTestManifest ? _buildTimeMode : _runtimeMode,
          );
      } else if (exitCode == _xcodebuildInterrupted) {
        const cause = 'xcodebuild was interrupted';
        task.fail('Failed to execute tests of $subject ($cause)');
        throwToolInterrupted(cause);
      } else {
        final cause = 'xcodebuild exited with code $exitCode';
        task.fail('Failed to build $subject ($cause)');
        throwToolExit(cause);
      }

      // Xcode 26.4+ includes _Testing_Foundation.framework which is loaded by
      // libXCTestSwiftSupport.dylib at app launch via @rpath. The xctestrun
      // generated by xcodebuild sets TestingEnvironmentVariables correctly but
      // omits __PLATFORMS__/.../Frameworks from UITargetAppEnvironmentVariables,
      // causing the Runner app to crash with "Library missing" at launch.
      // Patch the xctestrun to add the missing framework search path.
      if (options.simulator) {
        final sdkVersion = await getSdkVersion(real: false);
        final xctestRunFile = await xcTestRunPath(
          real: false,
          scheme: options.scheme,
          sdkVersion: sdkVersion,
        );
        await _patchXcTestRunFrameworkPath(xctestRunFile);
      }
    });
  }

  /// Why this project can't use build-time discovery on iOS, or null when it
  /// can: `RunnerUITests.m` has to `#include` the generated tests. Patrol never
  /// edits the file; the caller warns or fails with the lines to add.
  String? discoverySetupProblem() {
    final runner = _runnerFile;
    // A missing target is reported by xcodebuild.
    if (!runner.existsSync() ||
        includesGeneratedTests(runner.readAsStringSync())) {
      return null;
    }
    return "${runner.path} doesn't include the generated tests. Add these lines "
        'right after PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests):\n'
        '\n'
        '${_indented(_generatedIncInclude)}\n'
        '\n'
        'See $_discoveryDocsUrl';
  }

  /// Stops a build that would fail to compile or silently skip the generated
  /// tests.
  void _verifyRunnerSetup({required bool emitTestManifest}) {
    final runner = _runnerFile;
    if (!runner.existsSync()) {
      return;
    }

    if (_removedStaticMacro.hasMatch(runner.readAsStringSync())) {
      throwToolExit(
        '${runner.path} uses the PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN '
        'and _END macros, which were removed in Patrol 5.0. Replace them with:\n'
        '\n'
        '${_indented('PATROL_INTEGRATION_TEST_IOS_RUNNER(RunnerUITests)\n$_generatedIncInclude')}\n'
        '\n'
        'See $_discoveryDocsUrl',
      );
    }

    if (emitTestManifest) {
      final problem = discoverySetupProblem();
      if (problem != null) {
        throwToolExit(
          'Build-time test discovery is on, but $problem\n'
          'Or pass --no-emit-test-manifest to use runtime discovery.',
        );
      }
    }
  }

  static const _generatedIncName = 'PatrolGeneratedTests.inc';

  static const _discoveryDocsUrl =
      'https://patrol.leancode.co/documentation/ci/build-time-test-discovery';

  static const _generatedIncInclude =
      '#if __has_include("$_generatedIncName")\n'
      '#include "$_generatedIncName"\n'
      '#endif';

  static final _removedStaticMacro = RegExp(
    r'^[ \t]*PATROL_INTEGRATION_TEST_IOS_RUNNER_STATIC_BEGIN\b',
    multiLine: true,
  );

  static String _indented(String lines) =>
      lines.split('\n').map((l) => '  $l').join('\n');

  /// Whether [runnerSource] pulls in `PatrolGeneratedTests.inc`.
  @visibleForTesting
  static bool includesGeneratedTests(String runnerSource) => RegExp(
    '^[ \\t]*#[ \\t]*(?:include|import)[ \\t]*[<"]$_generatedIncName[>"]',
    multiLine: true,
  ).hasMatch(runnerSource);

  File get _runnerFile => _rootDirectory
      .childDirectory('ios')
      .childDirectory('RunnerUITests')
      .childFile('RunnerUITests.m');

  /// Maps requested [onlyTests] entries to the generated XCTest selectors below
  /// the target, using the build-time manifest: a Dart test name becomes
  /// `<class>/<method>`, a test file path becomes the bare `<class>` so the whole
  /// file costs one selector. Empty in → empty out (run every generated class).
  /// Used by `patrol test-without-building --only`. Throws when the manifest is
  /// missing or nothing matches.
  List<String> _resolveOnlyTesting(List<String> onlyTests) {
    if (onlyTests.isEmpty) {
      return const [];
    }
    final manifest = hasGeneratedTests
        ? TestManifest.loadFromBuild(_rootDirectory)
        : null;
    if (manifest == null) {
      throwToolExit(
        'The app was built with runtime test discovery, so --only has no '
        'generated tests to select. Run `patrol build ios` without '
        '--no-emit-test-manifest before `patrol test-without-building`.',
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
      ...selection.classNames,
      ...selection.tests.map((name) => name.selector),
    ];
  }

  /// Every generated class, as an `-only-testing` selector, so a run restricted
  /// to Patrol's own tests stays restricted: the generated tests live in per-file
  /// subclasses, and selecting the base class would select nothing. Empty with
  /// runtime discovery (whose tests are all in the base class) and when the
  /// manifest is missing, in which case the whole target runs.
  List<String> _generatedClassSelectors() {
    if (!hasGeneratedTests) {
      return const [];
    }
    final manifest = TestManifest.loadFromBuild(_rootDirectory);
    if (manifest == null) {
      return const [];
    }
    return generatePerFileTestNames(
      manifest.tests,
    ).map((name) => name.className).toSet().toList();
  }

  /// The generated static-XCTest include file, `#include`d by RunnerUITests.m.
  File get _generatedIncFile => _rootDirectory
      .childDirectory('ios')
      .childDirectory('RunnerUITests')
      .childFile(_generatedIncName);

  static const _buildTimeMode = 'build-time';
  static const _runtimeMode = 'runtime';

  /// The discovery mode of the last build, stored with its artifacts, so a run
  /// on another machine that only gets `build/` still knows it.
  File get _discoveryModeFile => _rootDirectory
      .childDirectory('build')
      .childDirectory('ios_integ')
      .childFile('patrol_test_discovery_mode');

  /// Whether the last build generated test classes, i.e. ran with build-time
  /// discovery.
  @visibleForTesting
  bool get hasGeneratedTests {
    final mode = _discoveryModeFile;
    if (mode.existsSync()) {
      return mode.readAsStringSync().trim() == _buildTimeMode;
    }
    // Built by a patrol_cli that didn't record the mode.
    final inc = _generatedIncFile;
    return inc.existsSync() && inc.readAsStringSync().contains('@interface ');
  }

  static const _runtimeDiscoveryInc =
      '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
      '// Built with runtime test discovery: no generated tests.\n';

  /// Leaves a `PatrolGeneratedTests.inc` that declares no tests when the runner
  /// includes it (an unguarded `#include` needs the file to compile), and no
  /// file otherwise.
  void _resetGeneratedInc() {
    final inc = _generatedIncFile;
    final runner = _runnerFile;
    if (!runner.existsSync() ||
        !includesGeneratedTests(runner.readAsStringSync())) {
      if (inc.existsSync()) {
        inc.deleteSync();
      }
      return;
    }
    // An unchanged file keeps its mtime, so Xcode doesn't rebuild the target.
    if (inc.existsSync() && inc.readAsStringSync() == _runtimeDiscoveryInc) {
      return;
    }
    inc
      ..createSync(recursive: true)
      ..writeAsStringSync(_runtimeDiscoveryInc);
  }

  /// Generates static XCTest methods from the manifest into the RunnerUITests
  /// target. The file is `#included` by RunnerUITests.m right after the runner
  /// macro, so it compiles as part of the test target with no project.pbxproj
  /// changes.
  ///
  /// Because the tests are now real, statically-discoverable XCTest methods,
  /// each can be selected individually with
  /// `-only-testing RunnerUITests/RunnerUITests/test_...`, which is what makes
  /// sharding across runners possible.
  void _generateXcodeTests(String manifestPath) {
    final output = _generatedIncFile;
    final count = XcodeTestCodegen(
      _fs,
    ).generate(manifestPath: manifestPath, outputPath: output.path);
    _logger.info('Generated $count static XCTest method(s) → ${output.path}');
  }

  /// Extracts the Dart VM service URL from a device log line. Returns null
  /// unless [line] is the engine's "The Dart VM service is listening on"
  /// message.
  @visibleForTesting
  static String? extractVmServiceUrl(String line) {
    if (!line.contains('Dart VM service') || !line.contains('http')) {
      return null;
    }

    return getObservationUrl(line);
  }

  /// Executes the tests of the given [options] on the given [device].
  ///
  /// [build] must be called before this method.
  ///
  /// If [interruptible] is true, then no exception is thrown on SIGINT. This is
  /// used for Hot Restart.
  Future<void> execute(
    IOSAppOptions options,
    Device device, {
    bool interruptible = false,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    List<String> onlyTests = const [],
    void Function(Entry entry)? onLogEntry,
    void Function(String url)? onVmServiceUrl,
    VideoRecordingConfig? videoConfig,
  }) async {
    // A develop session runs in the base runner class, whatever the mode.
    final onlyTesting = interruptible
        ? const <String>[]
        : onlyTests.isNotEmpty
        ? _resolveOnlyTesting(onlyTests)
        : _generatedClassSelectors();
    await _disposeScope.run((scope) async {
      // Create video recording manager if enabled
      IOSVideoRecordingManager? videoRecordingManager;
      if (videoConfig?.enabled ?? false) {
        videoRecordingManager = IOSVideoRecordingManager(
          processManager: _processManager,
          rootDirectory: _rootDirectory,
          logger: _logger,
          config: videoConfig!,
          device: device,
          scope: scope,
        );
      }

      final hostServer = device.real
          ? null
          : await _startHostServer(device, scope);

      final patrolLogCommand = device.real
          ? ['idevicesyslog', '-u', device.id]
          : [
              'xcrun',
              'simctl',
              'spawn',
              device.id,
              'log',
              'stream',
              '--type',
              'log',
              '--color',
              'none',
            ];

      // Read patrol logs from log stream
      final processLogs =
          await _processManager.start(patrolLogCommand, runInShell: true)
            ..disposedBy(scope);

      final reportPath = resultBundlePath(
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      StreamSubscription<void> listenPatrolLogs(
        void Function(String) onData, {
        Function? onError,
        void Function()? onDone,
        bool? cancelOnError,
      }) => processLogs.listenStdOut(
        (line) {
          final vmServiceUrl = extractVmServiceUrl(line);
          if (vmServiceUrl != null) {
            onVmServiceUrl?.call(vmServiceUrl);
          }

          onData(line);
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

      final patrolLogReader =
          PatrolLogReader(
              listenStdOut: listenPatrolLogs,
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
      final task = _logger.task('Running $subject');

      final sdkVersion = await getSdkVersion(real: device.real);
      final process =
          await _processManager.start(
              options.testWithoutBuildingInvocation(
                device,
                xcTestRunPath: await xcTestRunPath(
                  real: device.real,
                  scheme: options.scheme,
                  sdkVersion: sdkVersion,
                ),
                resultBundlePath: reportPath,
                onlyTesting: onlyTesting,
                staticRunner: !interruptible && hasGeneratedTests,
              ),
              runInShell: true,
              environment: {
                ..._platform.environment,
                'TEST_RUNNER_PATROL_TEST_PORT': options.testServerPort
                    .toString(),
                'TEST_RUNNER_PATROL_APP_PORT': options.appServerPort.toString(),
                if (hostServer != null)
                  'TEST_RUNNER_PATROL_HOST_PORT': hostServer.port.toString(),
                if (interruptible) 'TEST_RUNNER_PATROL_DEVELOP': '1',
              },
              workingDirectory: _rootDirectory.childDirectory('ios').path,
            )
            ..disposedBy(_disposeScope);
      process.listenStdOut((l) => _logger.detail('\t$l')).disposedBy(scope);
      process.listenStdErr((l) => _logger.detail('\t$l')).disposedBy(scope);

      final exitCode = await process.exitCode;
      patrolLogReader.stopTimer();
      processLogs.kill();

      // Cleanup video recording manager
      await videoRecordingManager?.dispose();

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
      } else if (exitCode == _xcodebuildInterrupted) {
        const cause = 'xcodebuild was interrupted';
        task.fail('Failed to execute tests of $subject ($cause)');
        throwToolInterrupted(cause);
      } else {
        final cause = 'xcodebuild exited with code $exitCode';
        task.fail('Failed to execute tests of $subject ($cause)');
        throwToolExit(cause);
      }
    });
  }

  Future<IOSHostServer> _startHostServer(
    Device device,
    DisposeScope scope,
  ) async {
    final hostServer = await IOSHostServer.start(
      hinge: SimulatorHinge(
        deviceId: device.id,
        processManager: _processManager,
        fs: _fs,
        logger: _logger,
      ),
      logger: _logger,
    );
    scope.addDispose(hostServer.close);

    return hostServer;
  }

  /// Uninstalls the app under test and the test runner from [device].
  ///
  /// [flavor] is required to infer the test runner bundle ID.
  Future<void> uninstall({
    required String appId,
    required String? flavor,
    required Device device,
  }) async {
    if (device.real) {
      // uninstall from iOS device
      await _processManager.run([
        'ideviceinstaller',
        ...['--udid', device.id],
        ...['--uninstall', appId],
      ], runInShell: true);
    } else {
      // uninstall from iOS simulator
      await _processManager.run([
        'xcrun',
        'simctl',
        'uninstall',
        device.id,
        appId,
      ], runInShell: true);
    }

    // See rationale: https://github.com/leancodepl/patrol/issues/1094
    final appIdWithoutFlavor = stripFlavorFromAppId(appId, flavor);
    final testApp = '$appIdWithoutFlavor.RunnerUITests.xctrunner';

    if (device.real) {
      // uninstall from iOS device
      await _processManager.run([
        'ideviceinstaller',
        ...['--udid', device.id],
        ...['--uninstall', testApp],
      ], runInShell: true);
    } else {
      // uninstall from iOS simulator
      await _processManager.run([
        'xcrun',
        'simctl',
        'uninstall',
        device.id,
        testApp,
      ], runInShell: true);
    }
  }

  /// Removes [flavor] from the end of [appId].
  ///
  /// Assumes that [appId] and [flavor] are separated by a dot.
  @visibleForTesting
  String stripFlavorFromAppId(String appId, String? flavor) {
    if (flavor == null) {
      return appId;
    }

    final idx = appId.indexOf('.$flavor');

    if (idx == -1) {
      return appId;
    }

    return appId.substring(0, idx);
  }

  /// Patches the xctestrun file to include the platform Developer frameworks
  /// directory in UITargetAppEnvironmentVariables.DYLD_FRAMEWORK_PATH.
  ///
  /// Starting with Xcode 26.4, libXCTestSwiftSupport.dylib (bundled inside
  /// Runner.app) dynamically links _Testing_Foundation.framework via @rpath.
  /// The framework lives under __PLATFORMS__/.../Developer/Library/Frameworks
  /// but xcodebuild only adds that path to TestingEnvironmentVariables (the
  /// test runner), not to UITargetAppEnvironmentVariables (the app under test).
  /// This causes Runner to crash at launch with DYLD "Library missing".
  Future<void> _patchXcTestRunFrameworkPath(String xctestRunPath) async {
    const platformsFrameworks =
        '__PLATFORMS__/iPhoneSimulator.platform/Developer/Library/Frameworks';
    const plistKey =
        'RunnerUITests:UITargetAppEnvironmentVariables:DYLD_FRAMEWORK_PATH';

    // Read the current value.
    final readResult = await _processManager.run([
      '/usr/libexec/PlistBuddy',
      '-c',
      'Print :$plistKey',
      xctestRunPath,
    ], runInShell: true);

    final currentPath = readResult.stdOut.trim();
    if (currentPath.contains('__PLATFORMS__')) {
      _logger.detail('xctestrun already patched with platform frameworks path');
      return;
    }

    // Append the platform frameworks path.
    // Use Add when the key doesn't exist yet, Set when it does.
    final newPath = currentPath.isEmpty
        ? platformsFrameworks
        : '$currentPath:$platformsFrameworks';
    final plistCommand = readResult.exitCode != 0
        ? 'Add :$plistKey string $newPath'
        : 'Set :$plistKey $newPath';
    final setResult = await _processManager.run([
      '/usr/libexec/PlistBuddy',
      '-c',
      plistCommand,
      xctestRunPath,
    ], runInShell: true);

    if (setResult.exitCode == 0) {
      _logger.detail(
        'Patched xctestrun: added platform frameworks to '
        'UITargetAppEnvironmentVariables.DYLD_FRAMEWORK_PATH',
      );
    } else {
      _logger.warn(
        'Failed to patch xctestrun DYLD_FRAMEWORK_PATH: '
        '${setResult.stdErr}',
      );
    }
  }

  // TODO: The path should be joined using platform-specific separator.
  // https://github.com/leancodepl/patrol/issues/1980
  Future<String> xcTestRunPath({
    required bool real,
    required String scheme,
    required String sdkVersion,
    bool absolutePath = true,
  }) async {
    final targetPlatform = real ? 'iphoneos' : 'iphonesimulator';
    final glob = Glob('${scheme}_*$targetPlatform$sdkVersion*.xctestrun');

    var root = 'build/ios_integ/Build/Products';
    if (absolutePath) {
      root = '${_rootDirectory.absolute.path}/$root';
    }
    _logger.detail('Looking for .xctestrun matching ${glob.pattern} at $root');
    final files = await glob.listFileSystem(_fs, root: root).toList();
    if (files.isEmpty) {
      final cause = 'No .xctestrun file was found at $root';
      throwToolExit(cause);
    }

    _logger.detail(
      'Found ${files.length} match(es), the first one will be used',
    );
    for (final file in files) {
      _logger.detail('Found ${file.absolute.path}');
    }

    if (absolutePath) {
      return files.first.absolute.path;
    }
    return files.first.path;
  }

  /// [timestamp] (milliseconds since UNIX epoch) is required for the generation
  /// of unique path for the results bundle.
  String resultBundlePath({required int timestamp}) {
    return _fs
        .file(
          join(_rootDirectory.path, 'build', 'ios_results_$timestamp.xcresult'),
        )
        .absolute
        .path;
  }

  Future<String> getSdkVersion({required bool real}) async {
    // See the versions yourself:
    //
    // $ xcodebuild -showsdks -json | jq '.[] | {sdkVersion, platform} | select(.platform=="iphoneos")'
    // $ xcodebuild -showsdks -json | jq '.[] | {sdkVersion, platform} | select(.platform=="iphonesimulator")'

    final processResult = await _processManager.run([
      'xcodebuild',
      '-showsdks',
      '-json',
    ], runInShell: true);

    String? sdkVersion;
    String? platform;
    final jsonOutput = jsonDecode(processResult.stdOut) as List<dynamic>;
    for (final sdkJson in jsonOutput) {
      final sdk = sdkJson as Map<String, dynamic>;
      if (real && sdk['platform'] == 'iphonesimulator') {
        sdkVersion = sdk['sdkVersion'] as String;
        platform = sdk['platform'] as String;
        break;
      }

      if (!real && sdk['platform'] == 'iphonesimulator') {
        sdkVersion = sdk['sdkVersion'] as String;
        platform = sdk['platform'] as String;
        break;
      }
    }

    if (sdkVersion == null) {
      throw Exception('xcodebuild: could not find SDK version');
    }

    _logger.detail('Assuming SDK version $sdkVersion for $platform');
    return sdkVersion;
  }

  Future<String> getInstalledAppsEnvVariable(String deviceId) async {
    final processResult = await _processManager.run([
      'xcrun',
      'simctl',
      'listapps',
      deviceId,
    ], runInShell: true);

    const lineSplitter = LineSplitter();
    final ids = lineSplitter
        .convert(processResult.stdOut)
        .where((line) => line.contains('CFBundleIdentifier ='))
        .map((e) => e.substring(e.indexOf('"') + 1, e.lastIndexOf('"')))
        .toList();

    return jsonEncode(ids);
  }
}
