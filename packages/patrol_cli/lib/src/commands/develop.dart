import 'dart:async';

import 'package:patrol_cli/src/analytics/analytics.dart';
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/crossplatform/flutter_tool.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
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
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required FlutterTool flutterTool,
    required Analytics analytics,
    required Logger logger,
  })  : _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testBundler = testBundler,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _iosTestBackend = iosTestBackend,
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

    usesUninstallOption();

    usesAndroidOptions();
    usesIOSOptions();
  }

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestBundler _testBundler;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final FlutterTool _flutterTool;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'develop';

  @override
  String get description => 'Develop integration tests with Hot Restart.';

  @override
  Future<int> run() async {
    unawaited(_analytics.sendCommand(name));

    final targets = stringsArg('target');
    if (targets.isEmpty) {
      throwToolExit('No target provided with --target');
    } else if (targets.length > 1) {
      throwToolExit('Only one target can be provided with --target');
    }

    final target = _testFinder.findTest(targets.first);
    _logger.detail('Received test target: $target');

    if (boolArg('release')) {
      throwToolExit('Cannot use release build mode with develop');
    }

    final entrypoint = _testBundler.createDevelopTestBundle(target);
    _logger.detail('Generated entrypoint ${entrypoint.path}');

    final config = _pubspecReader.read();
    final androidFlavor = stringArg('flavor') ?? config.android.flavor;
    final iosFlavor = stringArg('flavor') ?? config.ios.flavor;
    if (androidFlavor != null) {
      _logger.detail('Received Android flavor: $androidFlavor');
    }
    if (iosFlavor != null) {
      _logger.detail('Received iOS flavor: $iosFlavor');
    }

    final devices = await _deviceFinder.find(stringsArg('device'));
    final device = devices.single;
    _logger.detail('Received device: ${device.resolvedName}');

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;

    final displayLabel = boolArg('label');
    final uninstall = boolArg('uninstall');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': defaultWait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
      'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
      'PATROL_TEST_LABEL_ENABLED': displayLabel.toString(),
      // develop-specific
      ...{'PATROL_HOT_RESTART': 'true'},
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

    final dartDefineFromFilePath = stringArg('dart-define-from-file') ?? '';
    if (dartDefineFromFilePath.isNotEmpty) {
      _logger.detail(
        'Received path for --dart-define-from-file: $dartDefineFromFilePath',
      );
    }
    final dartDefineFromFile =
        _dartDefinesReader.fromConfigFile(path: dartDefineFromFilePath);

    final flutterOpts = FlutterAppOptions(
      target: entrypoint.path,
      flavor: androidFlavor,
      buildMode: buildMode,
      dartDefines: dartDefines,
      dartDefineFromFile: dartDefineFromFile,
    );

    final androidOpts = AndroidAppOptions(
      flutter: flutterOpts,
      packageName: packageName,
    );

    final iosOpts = IOSAppOptions(
      flutter: flutterOpts,
      bundleId: bundleId,
      scheme: buildMode.createScheme(iosFlavor),
      configuration: buildMode.createConfiguration(iosFlavor),
      simulator: !device.real,
    );

    await _build(androidOpts, iosOpts, device: device);
    await _execute(
      flutterOpts,
      androidOpts,
      iosOpts,
      uninstall: uninstall,
      device: device,
    );

    return 0; // for now, all exit codes are 0
  }

  Future<void> _build(
    AndroidAppOptions androidOpts,
    IOSAppOptions iosOpts, {
    required Device device,
  }) async {
    Future<void> Function() buildAction;
    switch (device.targetPlatform) {
      case TargetPlatform.android:
        buildAction = () => _androidTestBackend.build(androidOpts);
        break;
      case TargetPlatform.iOS:
        buildAction = () => _iosTestBackend.build(iosOpts);
    }

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

  Future<void> _execute(
    FlutterAppOptions flutterOpts,
    AndroidAppOptions android,
    IOSAppOptions ios, {
    required bool uninstall,
    required Device device,
  }) async {
    Future<void> Function() action;
    Future<void> Function()? finalizer;
    String? appId;

    switch (device.targetPlatform) {
      case TargetPlatform.android:
        appId = android.packageName;
        action = () =>
            _androidTestBackend.execute(android, device, interruptible: true);
        final package = android.packageName;
        if (package != null && uninstall) {
          finalizer = () => _androidTestBackend.uninstall(package, device);
        }
        break;
      case TargetPlatform.iOS:
        appId = ios.bundleId;
        action = () async =>
            _iosTestBackend.execute(ios, device, interruptible: true);
        final bundle = ios.bundleId;
        if (bundle != null && uninstall) {
          finalizer = () => _iosTestBackend.uninstall(bundle, device);
        }
    }

    try {
      final future = action();

      await _flutterTool.attachForHotRestart(
        deviceId: device.id,
        target: flutterOpts.target,
        appId: appId,
        dartDefines: flutterOpts.dartDefines,
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
