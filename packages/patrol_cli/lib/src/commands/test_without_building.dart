import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class TestWithoutBuildingCommand extends PatrolCommand {
  TestWithoutBuildingCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestBundler testBundler,
    required CompatibilityChecker compatibilityChecker,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macOSTestBackend,
    required Analytics analytics,
    required Logger logger,
  }) : _deviceFinder = deviceFinder,
       _testBundler = testBundler,
       _testFinder = testFinder,
       _compatibilityChecker = compatibilityChecker,
       _pubspecReader = pubspecReader,
       _androidTestBackend = androidTestBackend,
       _iosTestBackend = iosTestBackend,
       _macosTestBackend = macOSTestBackend,
       _analytics = analytics,
       _logger = logger {
    usesGenerateBundleOption();
    usesDeviceOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesPortOptions();
    usesShowFlutterLogs();
    usesHideTestSteps();
    usesClearTestSteps();
    usesCheckCompatibilityOption();

    usesUninstallOption();

    usesAndroidOptions();
    usesIOSOptions();
  }

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestBundler _testBundler;
  final CompatibilityChecker _compatibilityChecker;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final MacOSTestBackend _macosTestBackend;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'test-without-building';

  @override
  String get description => 'Run integration tests without building the app.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(FlutterVersion.fromCLI(flutterCommand), name),
    );

    final config = _pubspecReader.read();
    final testFileSuffix = config.testFileSuffix;

    final targets = _testFinder.findAllTests(
      excludes: {},
      testFileSuffix: testFileSuffix,
    );

    final entrypoint = _testBundler.bundledTestFile;
    if (boolArg('generate-bundle')) {
      _testBundler.createTestBundle(targets, null, null);
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

    if (boolArg('check-compatibility')) {
      await _compatibilityChecker.checkVersionsCompatibility(
        flutterCommand: flutterCommand,
        targetPlatform: device.targetPlatform,
      );
    }

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;

    final uninstall = boolArg('uninstall');

    final flutterOpts = FlutterAppOptions(
      command: flutterCommand,
      target: entrypoint.path,
      flavor: androidFlavor,
      buildMode: buildMode,
      dartDefines: {},
      dartDefineFromFilePaths: [],
      buildName: null,
      buildNumber: null,
    );

    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
      uninstall: false, // no-op
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
    );

    final macosOpts = MacOSAppOptions(
      flutter: flutterOpts,
      scheme: buildMode.createScheme(macosFlavor),
      configuration: buildMode.createConfiguration(macosFlavor),
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    await _preExecute(androidOpts, iosOpts, macosOpts, device, uninstall);

    final allPassed = await _execute(
      flutterOpts,
      androidOpts,
      iosOpts,
      macosOpts,
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
    }

    try {
      await action?.call();
    } catch (_) {
      // ignore any failures, we don't care
    }
  }

  Future<bool> _execute(
    FlutterAppOptions flutterOpts,
    AndroidAppOptions android,
    IOSAppOptions ios,
    MacOSAppOptions macos, {
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
        action = () async {
          await _androidTestBackend.loadJavaPathFromFlutterDoctor(
            flutterCommand,
          );
          await _androidTestBackend.execute(
            android,
            device,
            showFlutterLogs: showFlutterLogs,
            hideTestSteps: hideTestSteps,
            flavor: flutterOpts.flavor,
            clearTestSteps: clearTestSteps,
          );
        };
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
}
