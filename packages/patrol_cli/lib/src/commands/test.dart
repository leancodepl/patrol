import 'dart:async';

import 'package:ansi_styles/extension.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/app_options.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:patrol_cli/src/test_runner.dart';
import 'package:usage/usage.dart';

// Note: this class is a bit sphagetti because I didn't model classes to handle
// multiple targets. This problem will go away when #1004 is done.
part 'test.freezed.dart';

@freezed
class TestCommandConfig with _$TestCommandConfig {
  const factory TestCommandConfig({
    required List<Device> devices,
    required BuildMode buildMode,
    required List<String> targets,
    required Map<String, String> dartDefines,
    required int repeat,
    required bool displayLabel,
    required bool uninstall,
    // Android-only options
    required String? packageName,
    required String? androidFlavor,
    // iOS-only options
    required String? bundleId,
    required String? iosFlavor,
  }) = _TestCommandConfig;
}

class TestCommand extends PatrolCommand {
  TestCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestRunner testRunner,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required DisposeScope parentDisposeScope,
    required Analytics analytics,
    required Logger logger,
  })  : _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testRunner = testRunner,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _iosTestBackend = iosTestBackend,
        _analytics = analytics,
        _logger = logger {
    _testRunner.disposedBy(parentDisposeScope);

    usesTargetOption();
    usesDeviceOption();
    usesBuildModeOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesLabelOption();
    usesWaitOption();

    usesUninstallOption();
    usesRepeatOption();

    usesAndroidOptions();
    usesIOSOptions();
  }

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestRunner _testRunner;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;

  final Analytics _analytics;
  final Logger _logger;

  @override
  String get name => 'test';

  @override
  String get description => 'Run integration tests.';

  @override
  Future<int> run() async {
    unawaited(_analytics.sendEvent('command', name));

    final target = stringsArg('target');
    final targets = target.isNotEmpty
        ? _testFinder.findTests(target)
        : _testFinder.findAllTests();

    _logger.detail('Received ${targets.length} test target(s)');
    for (final t in targets) {
      _logger.detail('Received test target: $t');
    }

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
    _logger.detail('Received ${devices.length} device(s) to run on');
    for (final device in devices) {
      _logger.detail('Received device: ${device.resolvedName}');
    }

    final packageName = stringArg('package-name') ?? config.android.packageName;
    final bundleId = stringArg('bundle-id') ?? config.ios.bundleId;

    final wait = intArg('wait') ?? defaultWait;
    final repeatCount = intArg('repeat') ?? defaultRepeatCount;
    final displayLabel = boolArg('label');
    final uninstall = boolArg('uninstall');

    _logger.info('Every test target will be run $repeatCount time(s)');

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(args: stringsArg('dart-define')),
    };
    final internalDartDefines = {
      'PATROL_WAIT': wait.toString(),
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_ANDROID_APP_NAME': config.android.appName,
      'PATROL_IOS_APP_NAME': config.ios.appName,
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

    final testConfig = TestCommandConfig(
      devices: devices,
      targets: targets,
      buildMode: buildMode,
      dartDefines: dartDefines,
      repeat: repeatCount,
      displayLabel: displayLabel,
      uninstall: uninstall,
      // Android-specific options
      packageName: packageName,
      androidFlavor: androidFlavor,
      // iOS-specific options
      bundleId: bundleId,
      iosFlavor: iosFlavor,
    );

    testConfig.targets.forEach(_testRunner.addTarget);
    testConfig.devices.forEach(_testRunner.addDevice);
    _testRunner
      ..repeats = testConfig.repeat
      ..builder = _builderFor(testConfig)
      ..executor = _executorFor(testConfig);

    final results = await _testRunner.run();

    _TestResultsPresenter(_logger).printSummary(results);

    final exitCode = results.allSuccessful ? 0 : 1;

    return exitCode;
  }

  Future<void> Function(String, Device) _builderFor(TestCommandConfig config) {
    return (target, device) async {
      Future<void> Function() action;

      final flutterOpts = FlutterAppOptions(
        target: target,
        flavor: config.androidFlavor,
        buildMode: config.buildMode,
        dartDefines: {
          ...config.dartDefines,
          if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
        },
      );

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(flutter: flutterOpts);
          action = () => _androidTestBackend.build(options);
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            flutter: flutterOpts,
            scheme: flutterOpts.buildMode.createScheme(config.iosFlavor),
            configuration:
                flutterOpts.buildMode.createConfiguration(config.iosFlavor),
            simulator: !device.real,
          );
          action = () => _iosTestBackend.build(options);
      }

      try {
        await action();
      } catch (err, st) {
        _logger
          ..err('$err')
          ..detail('$st')
          ..err(defaultFailureMessage);
        rethrow;
      }
    };
  }

  Future<void> Function(String, Device) _executorFor(TestCommandConfig config) {
    return (target, device) async {
      Future<void> Function() action;
      Future<void> Function()? finalizer;

      final flutterOpts = FlutterAppOptions(
        target: target,
        flavor: config.androidFlavor,
        buildMode: config.buildMode,
        dartDefines: {
          ...config.dartDefines,
          if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
        },
      );

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(flutter: flutterOpts);
          action = () => _androidTestBackend.execute(options, device);
          final package = config.packageName;
          if (package != null && config.uninstall) {
            finalizer = () => _androidTestBackend.uninstall(package, device);
          }
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            flutter: flutterOpts,
            scheme: flutterOpts.buildMode.createScheme(config.iosFlavor),
            configuration:
                flutterOpts.buildMode.createConfiguration(config.iosFlavor),
            simulator: !device.real,
          );
          action = () async => _iosTestBackend.execute(options, device);
          final bundle = config.bundleId;
          if (bundle != null && config.uninstall) {
            finalizer = () => _iosTestBackend.uninstall(bundle, device);
          }
      }

      try {
        await action();
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
    };
  }
}

class _TestResultsPresenter {
  _TestResultsPresenter(this._logger);

  final Logger _logger;

  void printSummary(RunResults results) {
    if (results.targetRunResults.isEmpty) {
      _logger.warn('No run results found');
    }

    for (final res in results.targetRunResults) {
      final device = res.device.resolvedName;
      if (res.allRunsPassed) {
        _logger.write(
          '${' PASS '.bgGreen.black.bold} ${res.targetName} on $device\n',
        );
      } else if (res.allRunsFailed) {
        _logger.write(
          '${' FAIL '.bgRed.white.bold} ${res.targetName} on $device\n',
        );
      } else if (res.canceled) {
        _logger.write(
          '${' CANC '.bgGray.white.bold} ${res.targetName} on $device\n',
        );
      } else {
        _logger.write(
          '${' FLAK '.bgYellow.black.bold} ${res.targetName} on $device\n',
        );
      }
    }
  }
}
