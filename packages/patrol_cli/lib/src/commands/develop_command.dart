import 'dart:async';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/common/extensions/core.dart';
import 'package:patrol_cli/src/features/devices/device.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:patrol_cli/src/features/run_commons/test_runner.dart';
import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';
import 'package:patrol_cli/src/features/test/pubspec_reader.dart';
import 'package:patrol_cli/src/features/test/test_backend.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

part 'develop_command.freezed.dart';

@freezed
class DevelopCommandConfig with _$DevelopCommandConfig {
  const factory DevelopCommandConfig({
    required Device device,
    required String target,
    required Map<String, String> dartDefines,
    required bool displayLabel,
    required bool uninstall,
    // Android-only options
    required String? packageName,
    required String? androidFlavor,
    // iOS-only options
    required String? bundleId,
    required String? iosFlavor,
    required String scheme,
    required String xcconfigFile,
    required String configuration,
  }) = _DevelopCommandConfig;
}

class DevelopCommand extends PatrolCommand<DevelopCommandConfig> {
  DevelopCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestRunner testRunner,
    required DartDefinesReader dartDefinesReader,
    required PubspecReader pubspecReader,
    required AndroidTestBackend androidTestBackend,
    required IOSTestBackend iosTestBackend,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testRunner = testRunner,
        _dartDefinesReader = dartDefinesReader,
        _pubspecReader = pubspecReader,
        _androidTestBackend = androidTestBackend,
        _iosTestBackend = iosTestBackend,
        _logger = logger {
    _testRunner.disposedBy(parentDisposeScope);

    usesTargetOption();
    usesDeviceOption();
    usesFlavorOption();
    usesDartDefineOption();
    usesLabelOption();
    usesWaitOption();

    usesUninstallOption();

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

  final Logger _logger;

  @override
  String get name => 'develop';

  @override
  String get description => 'Develop integration tests with Hot Restart.';

  @override
  bool get hidden => true;

  @override
  Future<int> run() async {
    final targetArg = stringsArg('target');
    final target = _testFinder.findTest(targetArg.first);
    _logger.detail('Received test target: $target');

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

    final displayLabel = boolArg('label') ?? true;
    final uninstall = boolArg('uninstall') ?? true;

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
      // develop-specific
      ...{
        'INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE': 'false',
        'PATROL_HOT_RESTART': 'true',
      },
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

    final developConfig = DevelopCommandConfig(
      device: device,
      target: target,
      dartDefines: dartDefines,
      displayLabel: displayLabel,
      uninstall: uninstall,
      // Android-specific options
      packageName: packageName,
      androidFlavor: androidFlavor,
      // iOS-specific options
      bundleId: bundleId,
      iosFlavor: iosFlavor,
      scheme: stringArg('scheme') ?? defaultScheme,
      xcconfigFile: stringArg('xcconfig') ?? defaultXCConfigFile,
      configuration: !(argResults?.wasParsed('configuration') ?? false) &&
              (argResults?.wasParsed('flavor') ?? false)
          ? 'Debug-${argResults!['flavor']}'
          : stringArg('configuration') ?? defaultConfiguration,
    );

    // Prevents keystrokes from being printed automatically. Needs to be
    // disabled for lineMode to be disabled too.
    stdin.echoMode = false;

    // Causes the stdin stream to provide the input as soon as it arrives (one
    // key press at a time).
    stdin.lineMode = false;

    _testRunner
      ..addTarget(developConfig.target)
      ..addDevice(developConfig.device)
      ..builder = _builderFor(developConfig)
      ..executor = _executorFor(developConfig);

    final results = await _testRunner.run();
    final exitCode = results.allSuccessful ? 0 : 1;
    return exitCode;
  }

  Future<void> Function(String, Device) _builderFor(
    DevelopCommandConfig config,
  ) {
    return (target, device) async {
      Future<void> Function() action;

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(
            target: target,
            flavor: config.androidFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
          );
          action = () => _androidTestBackend.build(options);
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            target: target,
            flavor: config.iosFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
            scheme: config.scheme,
            xcconfigFile: config.xcconfigFile,
            configuration: config.configuration,
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

  Future<void> Function(String, Device) _executorFor(
    DevelopCommandConfig config,
  ) {
    return (target, device) async {
      Future<void> Function() action;
      Future<void> Function()? finalizer;

      AppOptions appOptions;
      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(
            target: target,
            flavor: config.androidFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
          );
          appOptions = options;
          action = () => _androidTestBackend.execute(options, device);
          final package = config.packageName;
          if (package != null && config.uninstall) {
            finalizer = () => _androidTestBackend.uninstall(package, device);
          }
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            target: target,
            flavor: config.iosFlavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
            scheme: config.scheme,
            xcconfigFile: config.xcconfigFile,
            configuration: config.configuration,
            simulator: !device.real,
          );
          appOptions = options;
          action = () async => _iosTestBackend.execute(options, device);
          final bundle = config.bundleId;
          if (bundle != null && config.uninstall) {
            finalizer = () => _iosTestBackend.uninstall(bundle, device);
          }
      }

      try {
        final logsProces = LoggingLocalProcessManager(logger: _logger);
        unawaited(() async {
          final process = await logsProces.start(
            ['flutter', '--no-version-check', 'logs', '--device-id', device.id],
          );
          _logger.info('Waiting for app to connect for logs...');
          process
            ..listenStdOut((l) => _logger.info('\t: $l'))
            ..listenStdErr((l) => _logger.err('\t$l'));
        }());

        final attachProces = LoggingLocalProcessManager(logger: _logger);
        unawaited(() async {
          final process = await attachProces.start(
            appOptions.toFlutterAttachInvocation(),
          );
          _logger.info('Waiting for app to connect for Hot Restart...');
          process
            ..listenStdOut((l) => _logger.detail('\t: $l'))
            ..listenStdErr((l) => _logger.err('\t$l'));
          stdin.listen((event) {
            final char = String.fromCharCode(event.first);
            if (char == 'r' || char == 'R') {
              _logger.success('Hot Restart in progress...');
              process.stdin.add(event);
            }

            if (char == 'q' || char == 'Q') {
              _logger.success('Quitting APP...');
              process.stdin.add(event);
            }
          });
        }());
        await action();
      } catch (err, st) {
        _logger
          ..err('$err')
          ..detail('$st')
          ..err(defaultFailureMessage);
        rethrow;
      } finally {
        await finalizer?.call();
      }
    };
  }
}
