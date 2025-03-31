import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/commands/dart_define_utils.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/macos/macos_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';

class DevelopCommand extends PatrolCommand {
  DevelopCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestBundler testBundler,
    required DartDefinesReader dartDefinesReader,
    required CompatibilityChecker compatibilityChecker,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required MacOSTestBackend macosTestBackend,
    required FlutterTool flutterTool,
    required Analytics analytics,
    required Logger logger,
  })  : _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testBundler = testBundler,
        _dartDefinesReader = dartDefinesReader,
        _compatibilityChecker = compatibilityChecker,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _iosTestBackend = iosTestBackend,
        _macosTestBackend = macosTestBackend,
        _flutterTool = flutterTool,
        _analytics = analytics,
        _logger = logger {
    usesTargetOption();
    usesDeviceOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesDartDefineFromFileOption();
    usesLabelOption();
    usesWaitOption();
    usesPortOptions();
    usesTagsOption();
    usesHideTestSteps();
    usesClearTestSteps();

    usesUninstallOption();

    usesAndroidOptions();
    usesIOSOptions();

    argParser.addFlag(
      'open-devtools',
      help: 'Automatically open Patrol extension in DevTools when ready.',
    );
  }

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final CompatibilityChecker _compatibilityChecker;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final MacOSTestBackend _macosTestBackend;
  final FlutterTool _flutterTool;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'develop';

  @override
  String get description => 'Develop integration tests with Hot Restart.';

  @override
  Future<int> run() async {
    unawaited(
      _analytics.sendCommand(
        FlutterVersion.fromCLI(flutterCommand),
        name,
      ),
    );

    final targets = stringsArg('target');
    if (targets.isEmpty) {
      throwToolExit('No target provided with --target');
    } else if (targets.length > 1) {
      throwToolExit('Only one target can be provided with --target');
    }

    final config = _pubspecReader.read();

    final target = _testFinder.findTest(targets.first, config.testFileSuffix);
    _logger.detail('Received test target: $target');

    if (boolArg('release')) {
      throwToolExit('Cannot use release build mode with develop');
    }

    final entrypoint = _testBundler.bundledTestFile;
    if (boolArg('generate-bundle')) {
      _testBundler.createDevelopTestBundle(target);
    }

    final androidFlavor = stringArg('flavor') ?? config.android.flavor;
    final iosFlavor = stringArg('flavor') ?? config.ios.flavor;
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }

    final devices = await _deviceFinder.find(
      stringsArg('device'),
      flutterCommand: flutterCommand,
    );
    final device = devices.single;

    await _compatibilityChecker.checkVersionsCompatibility(
      flutterCommand: flutterCommand,
      targetPlatform: device.targetPlatform,
    );

    // `flutter logs` doesn't work on macOS, so we don't support it for now
    // https://github.com/leancodepl/patrol/issues/1974
    if (device.targetPlatform == TargetPlatform.macOS) {
      throwToolExit('macOS is not supported with develop');
    }

    _logger.detail('Received device: ${device.resolvedName}');

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;

    final displayLabel = boolArg('label');
    final uninstall = boolArg('uninstall');

    String? iOSInstalledAppsEnvVariable;
    if (device.targetPlatform == TargetPlatform.iOS) {
      iOSInstalledAppsEnvVariable =
          await _iosTestBackend.getInstalledAppsEnvVariable(device.id);
    }

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_MACOS_APP_BUNDLE_ID': config.macos.bundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      // develop-specific
      ...{
        'PATROL_HOT_RESTART': 'true',
        'PATROL_IOS_INSTALLED_APPS': iOSInstalledAppsEnvVariable,
      },
      'PATROL_TEST_SERVER_PORT': super.testServerPort.toString(),
      'PATROL_APP_SERVER_PORT': super.appServerPort.toString(),
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
    );

    final macosOpts = MacOSAppOptions(
      flutter: flutterOpts,
      scheme: buildMode.createScheme(iosFlavor),
      configuration: buildMode.createConfiguration(iosFlavor),
      appServerPort: super.appServerPort,
      testServerPort: super.testServerPort,
    );

    await _build(androidOpts, iosOpts, macosOpts, device);
    await _preExecute(androidOpts, iosOpts, device, uninstall);
    await _execute(
      flutterOpts,
      androidOpts,
      iosOpts,
      macosOpts,
      uninstall: uninstall,
      device: device,
      openDevtools: boolArg('open-devtools'),
      showFlutterLogs: false,
      hideTestSteps: boolArg('hide-test-steps'),
      clearTestSteps: boolArg('clear-test-steps'),
    );

    return 0; // for now, all exit codes are 0
  }

  Future<void> _build(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
    MacOSAppOptions macosOpts,
    Device device,
  ) async {
    Future<void> Function() buildAction;
    buildAction = switch (device.targetPlatform) {
      TargetPlatform.android => () => _androidTestBackend.build(androidOpts),
      TargetPlatform.iOS => () => _iosTestBackend.build(iosOpts),
      TargetPlatform.macOS => () => _macosTestBackend.build(macosOpts),
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

  /// Uninstall the apps before running the tests.
  Future<void> _preExecute(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts,
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

  Future<void> _execute(
    FlutterAppOptions flutterOpts,
    AndroidAppOptions android,
    IOSAppOptions iosOpts,
    MacOSAppOptions macos, {
    required bool uninstall,
    required Device device,
    required bool openDevtools,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
  }) async {
    Future<void> Function() action;
    Future<void> Function()? finalizer;
    String? appId;

    switch (device.targetPlatform) {
      case TargetPlatform.android:
        appId = android.packageName;
        action = () => _androidTestBackend.execute(
              android,
              device,
              interruptible: true,
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
        appId = macos.bundleId;
        action = () async =>
            _macosTestBackend.execute(macos, device, interruptible: true);
      case TargetPlatform.iOS:
        appId = iosOpts.bundleId;
        action = () async => _iosTestBackend.execute(
              iosOpts,
              device,
              interruptible: true,
              showFlutterLogs: showFlutterLogs,
              hideTestSteps: hideTestSteps,
              clearTestSteps: clearTestSteps,
            );
        final bundleId = iosOpts.bundleId;
        if (bundleId != null && uninstall) {
          finalizer = () => _iosTestBackend.uninstall(
                appId: bundleId,
                flavor: iosOpts.flutter.flavor,
                device: device,
              );
        }
    }

    try {
      final future = action();
      await _flutterTool.attachForHotRestart(
        flutterCommand: flutterCommand,
        deviceId: device.id,
        target: flutterOpts.target,
        appId: appId,
        dartDefines: flutterOpts.dartDefines,
        openDevtools: openDevtools,
        attachUsingUrl: device.targetPlatform == TargetPlatform.macOS,
        onQuit: finalizer,
      );

      await future;
    } catch (err, st) {
      _logger
        ..err('$err')
        ..detail('$st')
        ..err(defaultFailureMessage);
      rethrow;
    } finally {
      try {
        await finalizer?.call();
      } catch (err) {
        _logger.err('Failed to call finalizer: $err');
        rethrow;
      }
    }
  }
}
