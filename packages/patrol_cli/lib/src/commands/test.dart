import 'dart:async';

import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/dart_define_utils.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/coverage/coverage_mode.dart';
import 'package:patrol_cli/src/coverage/coverage_tool.dart';
import 'package:patrol_cli/src/coverage/web_coverage_tool.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/test_discovery_mode.dart';
import 'package:patrol_cli/src/crossplatform/video_recording_config.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/reuse_build/android_kernel_swapper.dart';
import 'package:patrol_cli/src/reuse_build/build_reuse.dart';
import 'package:patrol_cli/src/reuse_build/native_fingerprint.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';

class TestCommand extends PatrolCommand {
  TestCommand({
    required this._deviceFinder,
    required this._testFinderFactory,
    required this._testBundler,
    required this._dartDefinesReader,
    required this._compatibilityChecker,
    required this._pubspecReader,
    required this._androidTestBackend,
    required this._iosTestBackend,
    required MacOSTestBackend macOSTestBackend,
    required this._webTestBackend,
    required this._coverageTool,
    required this._webCoverageTool,
    required BuildReuseTools buildReuseTools,
    required this._analytics,
    required this._logger,
  }) : _macosTestBackend = macOSTestBackend,
       _reuse = buildReuseTools {
    usesTargetOption();
    usesDeviceOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesDartDefineFromFileOption();
    usesLabelOption();
    usesPortOptions();
    usesTagsOption();
    usesExcludeTagsOption();
    useCoverageOptions();
    usesShowFlutterLogs();
    usesHideTestSteps();
    usesClearTestSteps();
    usesCheckCompatibilityOption();
    usesBuildNameOption();
    usesBuildNumberOption();

    usesUninstallOption();

    usesAppNameOption();
    usesAndroidOptions();
    usesIOSOptions();
    usesVideoRecordingOptions();
    usesEmitTestManifestOption();

    usesWeb();
    usesReuseBuildOptions();
  }

  final DeviceFinder _deviceFinder;
  final TestFinderFactory _testFinderFactory;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final CompatibilityChecker _compatibilityChecker;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final MacOSTestBackend _macosTestBackend;
  final WebTestBackend _webTestBackend;
  final CoverageTool _coverageTool;
  final WebCoverageTool _webCoverageTool;
  final BuildReuseTools _reuse;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'test';

  @override
  String get description => 'Run integration tests.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(FlutterVersion.fromCLI(flutterCommand), name),
    );

    final config = _pubspecReader.read();
    final testDirectory = config.testDirectory;
    final testFileSuffix = config.testFileSuffix;

    final testFinder = _testFinderFactory.create(testDirectory);
    final excludes = stringsArg('exclude').toSet();

    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? testFinder.findTests(target, testFileSuffix, excludes)
        : testFinder.findAllTests(
            excludes: excludes,
            testFileSuffix: testFileSuffix,
          );

    _logger.detail('Received ${targets.length} test target(s)');
    for (final t in targets) {
      _logger.detail('Received test target: $t');
    }

    final tags = stringArg('tags');
    final excludeTags = stringArg('exclude-tags');
    if (tags != null) {
      _logger.detail('Received tag(s): $tags');
    }
    if (excludeTags != null) {
      _logger.detail('Received exclude tag(s): $excludeTags');
    }

    final androidFlavor = stringArg('flavor') ?? config.android.flavor;
    final iosFlavor = stringArg('flavor') ?? config.ios.flavor;
    final macosFlavor = stringArg('flavor') ?? config.macos.flavor;
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }
    if (macosFlavor != null) {
      _logger.detail('Received macOS flavor: $macosFlavor');
    }

    final buildName = stringArg('build-name');
    if (buildName != null) {
      _logger.detail('Received build name: $buildName');
    }

    final buildNumber = stringArg('build-number');
    if (buildNumber != null) {
      _logger.detail('Received build number: $buildNumber');
    }

    final wantDevices = stringsArg('device');
    final bundledDevice = switch (wantDevices) {
      [final name] => Device.bundledForTest(name),
      _ => null,
    };

    final devices = bundledDevice != null
        ? [bundledDevice]
        : await _deviceFinder.find(wantDevices, flutterCommand: flutterCommand);

    _logger.detail('Received ${devices.length} device(s) to run on');
    for (final device in devices) {
      _logger.detail('Received device: ${device.name} (${device.id})');
    }

    if (devices.length > 1) {
      // TODO: Throw an error when running on more than 1 device
      _logger.warn('''
Running on multiple devices is deprecated and will be removed in the future.
See https://github.com/leancodepl/patrol/issues/1316 to learn more.
''');
    }

    final device = devices.single;
    final isWeb = device.targetPlatform == TargetPlatform.web;

    final emitTestManifest = resolveEmitTestManifest(
      targetPlatform: device.targetPlatform,
      flag: optionalBoolArg('emit-test-manifest'),
      pubspecValue: config.emitTestManifest,
      testDirectory: config.projectTestDirectory,
      logger: _logger,
      setupProblem: device.targetPlatform == TargetPlatform.iOS
          ? _iosTestBackend.discoverySetupProblem()
          : null,
    );

    // Validate that flavors are not used with web platform
    if (isWeb && stringArg('flavor') != null) {
      _logger.err(
        'Flavors are not supported for web platform. Please remove the --flavor flag.',
      );
      return 1;
    }

    final entrypoint = _testBundler.getBundledTestFile(
      testDirectory,
      web: isWeb,
    );
    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(
        testDirectory,
        targets,
        tags,
        excludeTags,
        web: isWeb,
      );
    }

    if (boolArg('check-compatibility')) {
      await _compatibilityChecker.checkVersionsCompatibility(
        flutterCommand: flutterCommand,
        targetPlatform: device.targetPlatform,
      );
    }

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;
    final macosBundleId = stringArg('bundle-id') ?? config.macos.bundleId;
    final appName = stringArg('app-name');
    final androidAppName = appName ?? config.android.appName;
    final iosAppName = appName ?? config.ios.appName;
    final macosAppName = appName ?? config.macos.appName;

    final displayLabel = boolArg('label');
    final uninstall = boolArg('uninstall');
    final noTreeShakeIcons = boolArg('no-tree-shake-icons');
    final coverageEnabled = boolArg('coverage');

    final coverageMode = switch ((coverageEnabled, isWeb)) {
      (false, _) => CoverageMode.none,
      (true, false) => CoverageMode.vm,
      (true, true) => CoverageMode.web,
    };

    if (coverageMode != CoverageMode.none && buildMode.name != 'debug') {
      _logger.err(
        'Coverage requires a debug build. '
        'Please remove the --${buildMode.name} flag.',
      );
      return 1;
    }

    final coverageWorkspace = boolArg('coverage-workspace');
    final ignoreGlobs = stringsArg('coverage-ignore').map(Glob.new).toSet();
    final coveragePackagesRegExps = stringsArg('coverage-package');
    final coveragePackages = switch ((
      coveragePackagesRegExps.length,
      coverageWorkspace,
    )) {
      // No --coverage-package and no --coverage-workspace: fall back to
      // the current package only.
      (0, false) => {RegExp(config.flutterPackageName)},
      // --coverage-workspace alone: rely entirely on workspace members.
      (0, true) => const <RegExp>{},
      _ => coveragePackagesRegExps.map(RegExp.new).toSet(),
    };

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_MACOS_APP_BUNDLE_ID': macosBundleId,
      'PATROL_ANDROID_APP_NAME': androidAppName,
      'PATROL_IOS_APP_NAME': iosAppName,
      'PATROL_MACOS_APP_NAME': macosAppName,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      'PATROL_TEST_DIRECTORY': config.testDirectory,
      'PATROL_SCREENSHOT_ON_FAILURE': config.screenshotOnFailure.toString(),
      if (device.targetPlatform != TargetPlatform.web) ...{
        'PATROL_TEST_SERVER_PORT': super.testServerPort.toString(),
        'PATROL_APP_SERVER_PORT': super.appServerPort.toString(),
      },
      'COVERAGE_ENABLED': (coverageMode == CoverageMode.vm).toString(),
    }.withNullsRemoved();

    final dartDefines = {...customDartDefines, ...internalDartDefines};

    _logger.detail(
      'Received ${dartDefines.length} --dart-define(s) '
      '(${customDartDefines.length} custom, ${internalDartDefines.length} internal)',
    );
    for (final dartDefine in customDartDefines.entries) {
      _logger.detail('Received custom --dart-define: ${dartDefine.key}');
    }
    for (final dartDefine in internalDartDefines.entries) {
      _logger.detail(
        'Received internal --dart-define: ${dartDefine.key}=${dartDefine.value}',
      );
    }

    final dartDefineFromFilePaths = stringsArg('dart-define-from-file');

    final mergedDartDefines = mergeDartDefines(
      dartDefineFromFilePaths,
      dartDefines,
      _dartDefinesReader,
    );

    final flavor = switch (device.targetPlatform) {
      TargetPlatform.android => androidFlavor,
      TargetPlatform.iOS => iosFlavor,
      TargetPlatform.macOS => macosFlavor,
      _ => null,
    };

    final flutterOpts = FlutterAppOptions(
      command: flutterCommand,
      target: entrypoint.path,
      flavor: flavor,
      buildMode: buildMode,
      dartDefines: mergedDartDefines,
      dartDefineFromFilePaths: dartDefineFromFilePaths,
      buildName: buildName,
      buildNumber: buildNumber,
      noTreeShakeIcons: noTreeShakeIcons,
    );

    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
      uninstall: uninstall,
      emitTestManifest: emitTestManifest,
    );

    final iosOpts = IOSAppOptions(
      flutter: flutterOpts,
      bundleId: bundleId,
      scheme: buildMode.createScheme(iosFlavor),
      configuration: buildMode.createConfiguration(iosFlavor),
      simulator: !device.real,
      osVersion: stringArg('ios') ?? 'latest',
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
      fullIsolation: boolArg('full-isolation'),
      clearIOSPermissions: boolArg('clear-permissions'),
      screenshotOnFailure: config.screenshotOnFailure,
      emitTestManifest: emitTestManifest,
    );

    final macosOpts = MacOSAppOptions(
      flutter: flutterOpts,
      scheme: buildMode.createScheme(macosFlavor),
      configuration: buildMode.createConfiguration(macosFlavor),
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    final webCoverageDataDir = coverageMode == CoverageMode.web
        ? (await _webCoverageTool.prepareDataDirectory()).path
        : null;

    final webOpts = WebAppOptions(
      flutter: flutterOpts,
      resultsDir: stringArg('web-results-dir'),
      reportDir: stringArg('web-report-dir'),
      retries: intArg('web-retries'),
      video: stringArg('web-video'),
      timeout: intArg('web-timeout'),
      workers: intArg('web-workers'),
      reporter: stringArg('web-reporter'),
      locale: stringArg('web-locale'),
      timezone: stringArg('web-timezone'),
      colorScheme: stringArg('web-color-scheme'),
      geolocation: stringArg('web-geolocation'),
      permissions: stringArg('web-permissions'),
      userAgent: stringArg('web-user-agent'),
      viewport: stringArg('web-viewport'),
      globalTimeout: intArg('web-global-timeout'),
      shard: stringArg('web-shard'),
      headless: optionalBoolArg('web-headless'),
      webPort: intArg('web-port'),
      serverTimeout: intArg('web-server-timeout'),
      browserArgs: stringArg('web-browser-args'),
      channel: stringArg('web-channel'),
      executablePath: stringArg('web-executable-path'),
      slowMo: intArg('web-slow-mo'),
      chromiumSandbox: optionalBoolArg('web-chromium-sandbox'),
      downloadsPath: stringArg('web-downloads-path'),
      ignoreDefaultArgs: stringArg('web-ignore-default-args'),
      proxy: stringArg('web-proxy'),
      browserTimeout: intArg('web-browser-timeout'),
      tracesDir: stringArg('web-traces-dir'),
      bypassCsp: optionalBoolArg('web-bypass-csp'),
      ignoreHttpsErrors: optionalBoolArg('web-ignore-https-errors'),
      offline: optionalBoolArg('web-offline'),
      httpCredentials: stringArg('web-http-credentials'),
      extraHttpHeaders: stringArg('web-extra-http-headers'),
      screenshot: stringArg('web-screenshot'),
      trace: stringArg('web-trace'),
      storageState: stringArg('web-storage-state'),
      acceptDownloads: optionalBoolArg('web-accept-downloads'),
      coverageDir: webCoverageDataDir,
    );

    final reuseFrom = stringArg('reuse-build-from');
    final reuseBuild = boolArg('reuse-build') || reuseFrom != null;
    _ReusePlan? reusePlan;
    if (reuseBuild) {
      reusePlan = await _planReuse(
        device: device,
        flutterOpts: flutterOpts,
        androidOpts: androidOpts,
        iosOpts: iosOpts,
        reuseFrom: reuseFrom,
      );
    }

    // No need to build web app for testing. It's done in the execute method.
    if (device.targetPlatform != TargetPlatform.web &&
        reusePlan?.artifacts == null) {
      await _build(androidOpts, iosOpts, macosOpts, webOpts, device);
    }

    await _preExecute(androidOpts, iosOpts, macosOpts, device, uninstall);

    if (coverageMode == CoverageMode.vm) {
      unawaited(
        _coverageTool.run(
          device: device,
          platform: device.targetPlatform,
          logger: _logger,
          ignoreGlobs: ignoreGlobs,
          flutterCommand: flutterCommand,
          includeWorkspacePackages: coverageWorkspace,
          packagesRegExps: coveragePackages,
        ),
      );
    }

    final allPassed = await _execute(
      flutterOpts,
      androidOpts,
      iosOpts,
      macosOpts,
      webOpts,
      uninstall: uninstall,
      device: device,
      showFlutterLogs: boolArg('show-flutter-logs'),
      hideTestSteps: boolArg('hide-test-steps'),
      clearTestSteps: boolArg('clear-test-steps'),
      testDirectory: testDirectory,
      screenshotsOutputDir:
          stringArg('screenshots-output-dir') ?? '$testDirectory/screenshots',
      reusedBuild: reusePlan?.artifacts,
    );

    // Recorded only now, from the inputs as the build left them: the build
    // itself can rewrite some (Podfile.lock, Package.resolved), and Gradle's
    // connected test task packages the APKs again.
    if (reusePlan case _ReusePlan(:final inputs, recordBuild: true)) {
      final built = _locateBuilt(inputs, iosOpts);
      if (built != null) {
        _reuse.cache.record(
          inputs,
          fingerprint: await _reuse.cache.fingerprint(inputs, flutterCommand),
          artifacts: built.stamped,
        );
      }
    }

    // Converted after the run, once the runner has written the raw JS coverage.
    // _execute signals failures via its return value, so failed runs still
    // produce a report.
    if (coverageMode == CoverageMode.web) {
      await _webCoverageTool.run(
        flutterPackageName: config.flutterPackageName,
        packagesRegExps: coveragePackages,
        includeWorkspacePackages: coverageWorkspace,
        ignoreGlobs: ignoreGlobs,
      );
    }

    return allPassed ? 0 : 1;
  }

  /// Uninstall the apps before running the tests.
  Future<void> _preExecute(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
    MacOSAppOptions macosOpts,
    Device device,
    bool uninstall,
  ) async {
    if (!uninstall) {
      return;
    }
    _logger.detail('Will uninstall apps before running tests');

    late Future<void> Function()? action;
    switch (device.targetPlatform) {
      case TargetPlatform.android:
        final packageName = androidOpts.packageName;
        if (packageName != null) {
          action = () => _androidTestBackend.uninstall(packageName, device);
        }
      case TargetPlatform.iOS:
        final bundleId = iosOpts.bundleId;
        if (bundleId != null) {
          action = () => _iosTestBackend.uninstall(
            appId: bundleId,
            flavor: iosOpts.flutter.flavor,
            device: device,
          );
        }
      case TargetPlatform.macOS:
      case TargetPlatform.web:
      // No uninstall needed for macOS and web
    }

    try {
      await action?.call();
    } catch (_) {
      // ignore any failures, we don't care
    }
  }

  Future<void> _build(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
    MacOSAppOptions macosOpts,
    WebAppOptions webOpts,
    Device device,
  ) async {
    final buildAction = switch (device.targetPlatform) {
      TargetPlatform.android => () => _androidTestBackend.build(androidOpts),
      TargetPlatform.macOS => () => _macosTestBackend.build(macosOpts),
      TargetPlatform.iOS => () => _iosTestBackend.build(iosOpts),
      TargetPlatform.web => () => _webTestBackend.build(webOpts),
    };

    try {
      await buildAction();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    }
  }

  Future<bool> _execute(
    FlutterAppOptions flutterOpts,
    AndroidAppOptions android,
    IOSAppOptions ios,
    MacOSAppOptions macos,
    WebAppOptions web, {
    required bool uninstall,
    required Device device,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    required String testDirectory,
    required String screenshotsOutputDir,
    _ReusedBuild? reusedBuild,
  }) async {
    Future<void> Function() action;
    Future<void> Function()? finalizer;

    final videoConfig = VideoRecordingConfig(
      enabled: boolArg('record-video'),
      outputDirectory: stringArg('video-output-dir') ?? '$testDirectory/videos',
      size: stringArg('video-size'),
      bitRate: int.tryParse(stringArg('video-bit-rate') ?? ''),
    );

    switch (device.targetPlatform) {
      case TargetPlatform.android:
        final reusedApks = reusedBuild?.apks;
        action = reusedApks != null
            ? () => _androidTestBackend.executeReusedBuild(
                android,
                device,
                apks: reusedApks,
                showFlutterLogs: showFlutterLogs,
                hideTestSteps: hideTestSteps,
                clearTestSteps: clearTestSteps,
                videoConfig: videoConfig,
                screenshotsOutputDir: screenshotsOutputDir,
              )
            : () => _androidTestBackend.execute(
                android,
                device,
                showFlutterLogs: showFlutterLogs,
                hideTestSteps: hideTestSteps,
                flavor: flutterOpts.flavor,
                clearTestSteps: clearTestSteps,
                videoConfig: videoConfig,
                pullScreenshots: true,
                screenshotsOutputDir: screenshotsOutputDir,
              );
        final package = android.packageName;
        if (package != null && uninstall) {
          finalizer = () => _androidTestBackend.uninstall(package, device);
        }
      case TargetPlatform.macOS:
        action = () => _macosTestBackend.execute(macos, device);
      case TargetPlatform.iOS:
        action = () => _iosTestBackend.execute(
          ios,
          device,
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          clearTestSteps: clearTestSteps,
          videoConfig: videoConfig,
          screenshotsOutputDir: screenshotsOutputDir,
          productsRoot: reusedBuild?.products?.path,
        );
        final bundleId = ios.bundleId;
        if (bundleId != null && uninstall) {
          finalizer = () => _iosTestBackend.uninstall(
            appId: bundleId,
            flavor: ios.flutter.flavor,
            device: device,
          );
        }
      case TargetPlatform.web:
        action = () => _webTestBackend.execute(
          web,
          device,
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          clearTestSteps: clearTestSteps,
        );
    }

    var allPassed = true;
    try {
      await action();
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      allPassed = false;
    } finally {
      try {
        await finalizer?.call();
      } catch (err) {
        _logger.err('Failed to call finalizer: $err');
        rethrow;
      }
    }

    return allPassed;
  }

  void usesReuseBuildOptions() {
    argParser
      ..addFlag(
        'reuse-build',
        negatable: false,
        help:
            'Skip the native build when only Dart code changed since the last '
            '--reuse-build run: compile the Dart code and put it into that build. '
            'The first run builds in full. Android and iOS simulators need a '
            'debug build, physical iOS devices a release build. Changes to '
            'native code, plugins, assets declared in pubspec.yaml, the '
            'Flutter version and native build options are detected and '
            'trigger a full build.',
      )
      ..addOption(
        'reuse-build-from',
        help:
            'Like --reuse-build, but use the build in this directory without '
            'checking that it matches the project. Android: a directory with '
            'one app APK and one *-androidTest.apk, e.g. from '
            '`patrol build android --develop`. iOS: a Build/Products '
            'directory with the .xctestrun file.',
        valueHelp: 'path',
      );
  }

  /// Decides whether `--reuse-build` can reuse a native build and, if so, compiles
  /// the Dart code and puts it into a copy of that build.
  Future<_ReusePlan> _planReuse({
    required Device device,
    required FlutterAppOptions flutterOpts,
    required AndroidAppOptions androidOpts,
    required IOSAppOptions iosOpts,
    required String? reuseFrom,
  }) async {
    final platform = switch (device.targetPlatform) {
      TargetPlatform.android => ReusePlatform.android,
      TargetPlatform.iOS when device.real => ReusePlatform.iosDevice,
      TargetPlatform.iOS => ReusePlatform.iosSimulator,
      TargetPlatform.macOS || TargetPlatform.web => throwToolExit(
        '--reuse-build supports Android and iOS only.',
      ),
    };
    // Physical iOS devices run release builds (see IOSTestBackend.build).
    final requiredMode = platform == ReusePlatform.iosDevice
        ? 'release'
        : 'debug';
    if (flutterOpts.buildMode.name != requiredMode) {
      throwToolExit(
        '--reuse-build needs a $requiredMode build on '
        '${platform == ReusePlatform.iosDevice ? 'physical iOS devices' : 'this device'}.',
      );
    }
    // Build-time test discovery generates native test classes, one per Dart
    // test file. Generate them first, as a build would, so they count as
    // native inputs: changing a test's body reuses the build, adding or
    // renaming a test builds in full.
    if (platform.isIOS) {
      await _iosTestBackend.prepareTestDiscovery(iosOpts);
    } else {
      await _androidTestBackend.prepareTestDiscovery(androidOpts);
    }

    final inputs = NativeBuildInputs(
      platform: platform,
      flavor: flutterOpts.flavor,
      buildName: flutterOpts.buildName,
      buildNumber: flutterOpts.buildNumber,
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
      fullIsolation: iosOpts.fullIsolation,
      clearPermissions: iosOpts.clearIOSPermissions,
      screenshotOnFailure: iosOpts.screenshotOnFailure,
      noTreeShakeIcons: flutterOpts.noTreeShakeIcons,
      emitTestManifest: platform.isIOS
          ? iosOpts.emitTestManifest
          : androidOpts.emitTestManifest,
    );

    final _BuiltArtifacts base;
    if (reuseFrom != null) {
      final dir = _reuse.cache.directory.fileSystem.directory(reuseFrom);
      base = switch (platform) {
        ReusePlatform.android => _BuiltArtifacts(
          apks: AndroidApks.fromDirectory(dir),
        ),
        ReusePlatform.iosSimulator ||
        ReusePlatform.iosDevice => _BuiltArtifacts(products: dir),
      };
      _logger.info('Reusing the native build in $reuseFrom');
    } else {
      final fingerprint = await _reuse.cache.fingerprint(
        inputs,
        flutterCommand,
      );
      final built = _locateBuilt(inputs, iosOpts);
      final reason = built == null
          ? 'no build found'
          : _reuse.cache.whyNotReusable(
              inputs,
              fingerprint: fingerprint,
              artifacts: built.stamped,
            );
      if (built == null || reason != null) {
        _logger.info(
          'Building the native app in full ($reason). The next --reuse-build runs '
          'reuse this build.',
        );
        return _ReusePlan(inputs: inputs, recordBuild: true);
      }
      base = built;
      _logger.info('Native inputs unchanged, reusing the last native build');
    }

    final outputDir = _reuse.cache.outputDirectory(inputs);
    final _ReusedBuild artifacts;
    switch (platform) {
      case ReusePlatform.android:
        artifacts = _ReusedBuild(
          apks: await _reuse.androidSwapper.swap(
            base: base.apks!,
            kernel: await _reuse.kernelCompiler.compile(
              flutterOpts,
              platform: platform,
            ),
            outputDir: outputDir,
            javaHome: () => _androidTestBackend.findJavaHome(flutterCommand),
          ),
        );
      case ReusePlatform.iosSimulator:
        artifacts = _ReusedBuild(
          products: await _reuse.iosPatcher.swapKernel(
            products: base.products!,
            configuration: iosOpts.configuration,
            kernel: await _reuse.kernelCompiler.compile(
              flutterOpts,
              platform: platform,
            ),
            outputDir: outputDir.childDirectory('Products'),
          ),
        );
      case ReusePlatform.iosDevice:
        artifacts = _ReusedBuild(
          products: await _reuse.iosPatcher.swapAppFramework(
            products: base.products!,
            configuration: iosOpts.configuration,
            appFramework: await _reuse.kernelCompiler.compileIOSAppFramework(
              flutterOpts,
              configuration: iosOpts.configuration,
            ),
            outputDir: outputDir.childDirectory('Products'),
          ),
        );
    }
    return _ReusePlan(inputs: inputs, artifacts: artifacts);
  }

  /// The native build Gradle or Xcode last wrote for [inputs], or `null`.
  _BuiltArtifacts? _locateBuilt(
    NativeBuildInputs inputs,
    IOSAppOptions iosOpts,
  ) {
    final root = _reuse.cache.directory.parent.parent;
    switch (inputs.platform) {
      case ReusePlatform.android:
        final apks = AndroidApks.locateBuilt(
          root,
          buildMode: 'debug',
          flavor: inputs.flavor,
        );
        return apks == null ? null : _BuiltArtifacts(apks: apks);
      case ReusePlatform.iosSimulator || ReusePlatform.iosDevice:
        final sdk = inputs.platform == ReusePlatform.iosDevice
            ? 'iphoneos'
            : 'iphonesimulator';
        final products = root.fileSystem.directory(
          root.fileSystem.path.join(
            root.path,
            IOSTestBackend.productsDirectoryPath,
          ),
        );
        final configDir = products.childDirectory(
          '${iosOpts.configuration}-$sdk',
        );
        if (!configDir.existsSync()) {
          return null;
        }
        final xctestruns = products.listSync().whereType<File>().where((f) {
          final name = f.basename;
          return name.endsWith('.xctestrun') &&
              name.startsWith('${iosOpts.scheme}_') &&
              name.contains(sdk);
        }).toList();
        if (xctestruns.isEmpty) {
          return null;
        }
        return _BuiltArtifacts(products: products, xctestruns: xctestruns);
    }
  }

  void useCoverageOptions() {
    argParser
      ..addFlag(
        'coverage',
        help:
            'Generate coverage. On the web, reports only covered/uncovered '
            'lines, without the per-line hit counts available on other '
            'platforms.',
      )
      ..addFlag(
        'coverage-workspace',
        help:
            'Include every package declared under the top-level `workspace:` '
            'key of the resolved pubspec.yaml in the coverage report. '
            'Has no effect outside a Pub workspace. Can be combined with '
            '--coverage-package.',
      )
      ..addMultiOption(
        'coverage-ignore',
        help: 'Exclude files from coverage using glob patterns.',
      )
      ..addMultiOption(
        'coverage-package',
        help:
            'A regular expression matching packages names '
            'to include in the coverage report (if coverage is enabled). '
            'If unset, matches the current package name.',
        valueHelp: 'package-name-regexp',
        splitCommas: false,
      );
  }
}

/// What `--reuse-build` decided: reuse a build ([artifacts] set), or build in full
/// and record the build ([recordBuild]).
class _ReusePlan {
  const _ReusePlan({
    required this.inputs,
    this.recordBuild = false,
    this.artifacts,
  });

  final NativeBuildInputs inputs;
  final bool recordBuild;
  final _ReusedBuild? artifacts;
}

/// A build with a freshly compiled kernel, ready to run.
class _ReusedBuild {
  const _ReusedBuild({this.apks, this.products});

  final AndroidApks? apks;
  final Directory? products;
}

/// A native build Gradle or Xcode wrote.
class _BuiltArtifacts {
  const _BuiltArtifacts({this.apks, this.products, this.xctestruns = const []});

  final AndroidApks? apks;
  final Directory? products;
  final List<File> xctestruns;

  /// Files whose modification times tell whether the build changed.
  List<FileSystemEntity> get stamped => [
    if (apks case final apks?) ...[apks.app, apks.test],
    ...xctestruns,
  ];
}
