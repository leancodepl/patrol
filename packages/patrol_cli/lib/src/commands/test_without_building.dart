import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/build_path_cache_manager.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

class TestWithoutBuildingCommand extends PatrolCommand {
  TestWithoutBuildingCommand({
    required DeviceFinder deviceFinder,
    required CompatibilityChecker compatibilityChecker,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macOSTestBackend,
    required BuildPathCacheManager buildPathCacheManager,
    required Analytics analytics,
    required Logger logger,
  }) : _deviceFinder = deviceFinder,
       _compatibilityChecker = compatibilityChecker,
       _pubspecReader = pubspecReader,
       _androidTestBackend = androidTestBackend,
       _iosTestBackend = iosTestBackend,
       _macosTestBackend = macOSTestBackend,
       _buildPathCacheManager = buildPathCacheManager,
       _analytics = analytics,
       _logger = logger {
    usesDeviceOption();
    usesShowFlutterLogs();
    usesHideTestSteps();
    usesClearTestSteps();
    usesCheckCompatibilityOption();

    usesFlavorOption();
    usesAndroidOptions();
    usesIOSOptions();
  }

  final DeviceFinder _deviceFinder;
  final CompatibilityChecker _compatibilityChecker;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final MacOSTestBackend _macosTestBackend;
  final BuildPathCacheManager _buildPathCacheManager;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'test-without-building';

  @override
  String get description =>
      'Run integration tests without building the app based on cache.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(FlutterVersion.fromCLI(flutterCommand), name),
    );

    final config = _pubspecReader.read();
    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;
    final iosFlavor = stringArg('flavor') ?? config.ios.flavor;

    final uninstall = boolArg('uninstall');

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

    await _preExecute(
      device: device,
      uninstall: uninstall,
      packageName: packageName,
      bundleId: bundleId,
      iOSFlavor: iosFlavor,
    );

    final allPassed = await _execute(
      device: device,
      packageName: packageName!,
      showFlutterLogs: boolArg('show-flutter-logs'),
      hideTestSteps: boolArg('hide-test-steps'),
      clearTestSteps: boolArg('clear-test-steps'),
      uninstall: boolArg('uninstall'),
      iosFlavor: iosFlavor,
    );

    return allPassed ? 0 : 1;
  }

  /// Uninstall the apps before running the tests.
  Future<void> _preExecute({
    required Device device,
    required bool uninstall,
    required String? packageName,
    required String? bundleId,
    required String? iOSFlavor,
  }) async {
    if (!uninstall) {
      return;
    }
    _logger.detail('Will uninstall apps before running tests');

    Future<void> Function()? action;
    switch (device.targetPlatform) {
      case TargetPlatform.android:
        if (packageName != null) {
          action = () => _androidTestBackend.uninstall(packageName, device);
        }

      case TargetPlatform.iOS:
        if (bundleId != null && iOSFlavor != null) {
          action = () => _iosTestBackend.uninstall(
            appId: bundleId,
            flavor: iOSFlavor,
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

  Future<bool> _execute({
    required Device device,
    required String packageName,
    required bool uninstall,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
    required String? iosFlavor,
    String? bundleId,
  }) async {
    Future<void> Function() action;
    Future<void> Function()? finalizer;

    switch (device.targetPlatform) {
      case TargetPlatform.android:
        final paths = _getAndroidAPKPaths();
        action = () async {
          await _androidTestBackend.loadJavaPathFromFlutterDoctor(
            flutterCommand,
          );
          await _androidTestBackend.executeByPath(
            flutterCommand: flutterCommand,
            device: device,
            appAPKPath: paths.appAPKPath,
            testAPKPath: paths.testAPKPath,
            packageName: packageName,
            description: description,
            showFlutterLogs: showFlutterLogs,
            hideTestSteps: hideTestSteps,
            clearTestSteps: clearTestSteps,
          );
        };
        if (uninstall) {
          finalizer = () => _androidTestBackend.uninstall(packageName, device);
        }
      case TargetPlatform.iOS:
        final path = _getIOSXctestrunPath();
        action = () => _iosTestBackend.executeByPath(
          device: device,
          showFlutterLogs: showFlutterLogs,
          hideTestSteps: hideTestSteps,
          clearTestSteps: clearTestSteps,
          xcTestRunPath: path,
          osVersion: stringArg('os') ?? 'latest',
          description: '',
          appServerPort: super.appServerPort,
          testServerPort: super.testServerPort,
        );
        if (bundleId case final bundleId? when uninstall) {
          finalizer = () => _iosTestBackend.uninstall(
            appId: bundleId,
            flavor: iosFlavor,
            device: device,
          );
        }
      case TargetPlatform.macOS:
        final path = _getMacOSXctestrunPath();
        action = () => _macosTestBackend.executeByPath(
          device: device,
          xcTestRunPath: path,
          description: '',
          appServerPort: super.appServerPort,
          testServerPort: super.testServerPort,
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

  _AndroidAPKPaths _getAndroidAPKPaths() {
    final appAPKPath = stringArg('android-app-apk-path');
    final testAPKPath = stringArg('android-test-apk-path');
    if (appAPKPath != null && testAPKPath != null) {
      return (appAPKPath: appAPKPath, testAPKPath: testAPKPath);
    } else if (appAPKPath != null || testAPKPath != null) {
      // TODO: KrzysztofMamak - Provide more specific error message and log
      throw Exception();
    }

    final cache = _buildPathCacheManager.getCurrentCache();

    if (cache?.android case final cache?) {
      return (appAPKPath: cache.apkPath, testAPKPath: cache.testApkPath);
    }

    // TODO: KrzysztofMamak - Provide more specific error message and log
    throw Exception();
  }

  String _getIOSXctestrunPath() {
    final xctestrunPath = stringArg('ios-xctestrun-path');

    if (xctestrunPath != null) {
      return xctestrunPath;
    }

    final cache = _buildPathCacheManager.getCurrentCache();
    if (cache?.ios case final cache?) {
      return cache.xctestrunPath;
    }

    // TODO: KrzysztofMamak - Provide more specific error message and log
    throw Exception();
  }

  String _getMacOSXctestrunPath() {
    final xctestrunPath = stringArg('macos-xctestrun-path');

    if (xctestrunPath != null) {
      return xctestrunPath;
    }

    final cache = _buildPathCacheManager.getCurrentCache();
    if (cache?.macos case final cache?) {
      return cache.xctestrunPath;
    }

    // TODO: KrzysztofMamak - Provide more specific error message and log
    throw Exception();
  }
}

typedef _AndroidAPKPaths = ({String appAPKPath, String testAPKPath});
