import 'dart:async';

import 'package:glob/glob.dart';
import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/dart_define_utils.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/coverage/coverage_tool.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:patrol_cli/src/web/web_test_backend.dart';

class TestCommand extends PatrolCommand {
  TestCommand({
    required DeviceFinder deviceFinder,
    required TestFinderFactory testFinderFactory,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required CompatibilityChecker compatibilityChecker,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macOSTestBackend,
    required WebTestBackend webTestBackend,
    required CoverageTool coverageTool,
    required Analytics analytics,
    required Logger logger,
  }) : _deviceFinder = deviceFinder,
       _testBundler = testBundler,
       _testFinderFactory = testFinderFactory,
       _dartDefinesReader = dartDefinesReader,
       _compatibilityChecker = compatibilityChecker,
       _pubspecReader = pubspecReader,
       _androidTestBackend = androidTestBackend,
       _iosTestBackend = iosTestBackend,
       _macosTestBackend = macOSTestBackend,
       _webTestBackend = webTestBackend,
       _coverageTool = coverageTool,
       _analytics = analytics,
       _logger = logger {
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

    usesAndroidOptions();
    usesIOSOptions();

    usesWeb();
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

    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? testFinder.findTests(target, testFileSuffix)
        : testFinder.findAllTests(
            excludes: stringsArg('exclude').toSet(),
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

    final devices = await _deviceFinder.find(
      stringsArg('device'),
      flutterCommand: flutterCommand,
    );
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

    final displayLabel = boolArg('label');
    final uninstall = boolArg('uninstall');
    final noTreeShakeIcons = boolArg('no-tree-shake-icons');
    final coverageEnabled = boolArg('coverage');
    final ignoreGlobs = stringsArg('coverage-ignore').map(Glob.new).toSet();
    final coveragePackagesRegExps = stringsArg('coverage-package');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_MACOS_APP_BUNDLE_ID': macosBundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      'PATROL_TEST_DIRECTORY': config.testDirectory,
      if (device.targetPlatform != TargetPlatform.web) ...{
        'PATROL_TEST_SERVER_PORT': super.testServerPort.toString(),
        'PATROL_APP_SERVER_PORT': super.appServerPort.toString(),
      },
      'COVERAGE_ENABLED': coverageEnabled.toString(),
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

    final flutterOpts = FlutterAppOptions(
      command: flutterCommand,
      target: entrypoint.path,
      flavor: androidFlavor,
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
    );

    final macosOpts = MacOSAppOptions(
      flutter: flutterOpts,
      scheme: buildMode.createScheme(macosFlavor),
      configuration: buildMode.createConfiguration(macosFlavor),
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

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
      headless: stringArg('web-headless'),
      browserArgs: stringArg('web-browser-args'),
    );

    // No need to build web app for testing. It's done in the execute method.
    if (device.targetPlatform != TargetPlatform.web) {
      await _build(androidOpts, iosOpts, macosOpts, webOpts, device);
    }

    await _preExecute(androidOpts, iosOpts, macosOpts, device, uninstall);

    if (coverageEnabled) {
      unawaited(
        _coverageTool.run(
          device: device,
          platform: device.targetPlatform,
          logger: _logger,
          ignoreGlobs: ignoreGlobs,
          flutterCommand: flutterCommand,
          packagesRegExps: switch (coveragePackagesRegExps.length) {
            0 => {RegExp(config.flutterPackageName)},
            _ => coveragePackagesRegExps.map(RegExp.new).toSet(),
          },
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
    );

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
  }) async {
    Future<void> Function() action;
    Future<void> Function()? finalizer;

    switch (device.targetPlatform) {
      case TargetPlatform.android:
        action = () => _androidTestBackend.execute(
          android,
          device,
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          flavor: flutterOpts.flavor,
          clearTestSteps: clearTestSteps,
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

  void useCoverageOptions() {
    argParser
      ..addFlag('coverage', help: 'Generate coverage.')
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
