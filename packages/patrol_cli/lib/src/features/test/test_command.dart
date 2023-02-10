import 'package:ansi_styles/extension.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' show basename;
import 'package:patrol_cli/src/common/extensions/core.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/common/staged_command.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';
import 'package:patrol_cli/src/features/test/native_test_runner.dart';
import 'package:patrol_cli/src/features/test/pubspec_reader.dart';

part 'test_command.freezed.dart';

@freezed
class TestCommandConfig with _$TestCommandConfig {
  const factory TestCommandConfig({
    required List<Device> devices,
    required List<String> targets,
    required String? flavor,
    required String scheme,
    required String xcconfigFile,
    required String configuration,
    required Map<String, String> dartDefines,
    required String? packageName,
    required String? bundleId,
    required int repeat,
    required bool displayLabel,
  }) = _TestCommandConfig;
}

const _defaultRepeats = 1;
const _failureMessage =
    'See the logs above to learn what happened. Also consider running with '
    "--verbose. If the logs still aren't useful, then it's a bug – please "
    'report it.';

class TestCommand extends StagedCommand<TestCommandConfig> {
  TestCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required NativeTestRunner testRunner,
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

    argParser
      ..addMultiOption(
        'target',
        aliases: ['targets'],
        abbr: 't',
        help: 'Integration tests to run. If empty, all tests are run.',
        valueHelp: 'integration_test/app_test.dart',
      )
      ..addMultiOption(
        'device',
        aliases: ['devices'],
        abbr: 'd',
        help:
            'Devices to run the tests on. If empty, the first device is used.',
        valueHelp: "all, emulator-5554, 'iPhone 14'",
      )
      ..addOption(
        'flavor',
        help: 'Flavor of the app to run.',
      )
      ..addMultiOption(
        'dart-define',
        aliases: ['dart-defines'],
        help: 'Additional key-value pairs that will be available to the app '
            'under test.',
        valueHelp: 'KEY=VALUE',
      )
      ..addOption(
        'package-name',
        help: 'Package name of the Android app under test.',
        valueHelp: 'pl.leancode.awesomeapp',
      )
      ..addOption(
        'bundle-id',
        help: 'Bundle identifier of the iOS app under test.',
        valueHelp: 'pl.leancode.AwesomeApp',
      )
      ..addOption(
        'wait',
        help: 'Seconds to wait after the test fails or succeeds.',
        defaultsTo: '0',
      )
      ..addOption(
        'repeat',
        abbr: 'n',
        help: 'Repeat the test n times.',
        defaultsTo: '$_defaultRepeats',
      )
      ..addFlag(
        'label',
        help: 'Display the label over the application under test.',
        defaultsTo: true,
      )
      ..addOption(
        'scheme',
        help: '(iOS only) Xcode scheme to use',
        defaultsTo: _defaultScheme,
      )
      ..addOption(
        'xcconfig',
        help: '(iOS only) Xcode .xcconfig file to use',
        defaultsTo: _defaultXCConfigFile,
      )
      ..addOption(
        'configuration',
        help: '(iOS only) Xcode configuration to use',
        defaultsTo: _defaultConfiguration,
      );
  }
  static const _defaultScheme = 'Runner';
  static const _defaultXCConfigFile = 'Flutter/Debug.xcconfig';
  static const _defaultConfiguration = 'Debug';

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final NativeTestRunner _testRunner;
  final DartDefinesReader _dartDefinesReader;
  final PubspecReader _pubspecReader;
  final AndroidTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;

  final Logger _logger;

  bool verbose = false;

  @override
  String get name => 'test';

  @override
  String get description => 'Run integration tests.';

  @override
  Future<TestCommandConfig> configure() async {
    final target = argResults?['target'] as List<String>? ?? [];
    final targets = target.isNotEmpty
        ? _testFinder.findTests(target)
        : _testFinder.findAllTests();

    _logger.detail('Received ${targets.length} test target(s)');
    for (final t in targets) {
      _logger.detail('Received test target: $t');
    }

    final pubspecConfig = _pubspecReader.read();

    var flavor = argResults?['flavor'] as String?;
    flavor ??= pubspecConfig.flavor;
    if (flavor != null) {
      _logger.detail('Received flavor: $flavor');
    }

    final devices = argResults?['device'] as List<String>? ?? [];
    final devicesToUse = await _deviceFinder.find(devices);
    _logger.detail('Received ${devicesToUse.length} device(s) to run on');
    for (final device in devicesToUse) {
      _logger.detail('Received device: ${device.resolvedName}');
    }

    final customDartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(
        args: argResults?['dart-define'] as List<String>? ?? [],
      ),
    };

    var packageName = argResults?['package-name'] as String?;
    packageName ??= pubspecConfig.android.packageName;

    var bundleId = argResults?['bundle-id'] as String?;
    bundleId ??= pubspecConfig.ios.bundleId;

    final dynamic wait = argResults?['wait'];
    if (wait != null && int.tryParse(wait as String) == null) {
      throw const FormatException('`wait` argument is not an int');
    }

    final int repeat;
    try {
      final repeatStr = argResults?['repeat'] as String? ?? '$_defaultRepeats';
      repeat = int.parse(repeatStr);
    } on FormatException {
      throw const FormatException('`repeat` argument is not an int');
    }

    final displayLabel = argResults?['label'] as bool?;

    if (repeat < 1) {
      throwToolExit('repeat count must not be smaller than 1');
    }

    if (repeat != 1) {
      _logger.info('Every test target will be run $repeat times');
    }

    final internalDartDefines = {
      'PATROL_WAIT': wait as String? ?? '0',
      'PATROL_VERBOSE': '$verbose',
      'PATROL_APP_PACKAGE_NAME': packageName,
      'PATROL_APP_BUNDLE_ID': bundleId,
      'PATROL_ANDROID_APP_NAME': pubspecConfig.android.appName,
      'PATROL_IOS_APP_NAME': pubspecConfig.ios.appName,
    }.withNullsRemoved();

    final effectiveDartDefines = {...customDartDefines, ...internalDartDefines};

    _logger.detail(
      'Received ${effectiveDartDefines.length} --dart-define(s) '
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

    return TestCommandConfig(
      devices: devicesToUse,
      targets: targets,
      flavor: flavor,
      scheme: argResults?['scheme'] as String? ?? _defaultScheme,
      xcconfigFile: argResults?['xcconfig'] as String? ?? _defaultXCConfigFile,
      configuration: !(argResults?.wasParsed('configuration') ?? false) &&
              (argResults?.wasParsed('flavor') ?? false)
          ? 'Debug-${argResults!['flavor']}'
          : argResults?['configuration'] as String? ?? _defaultConfiguration,
      dartDefines: effectiveDartDefines,
      packageName: packageName,
      bundleId: bundleId,
      repeat: repeat,
      displayLabel: displayLabel ?? true,
    );
  }

  @override
  Future<int> execute(TestCommandConfig config) async {
    config.targets.forEach(_testRunner.addTarget);
    config.devices.forEach(_testRunner.addDevice);
    _testRunner
      ..repeats = config.repeat
      ..builder = _builderFor(config)
      ..executor = _executorFor(config);

    final results = await _testRunner.run();

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

    final exitCode = results.allSuccessful ? 0 : 1;

    return exitCode;
  }

  Future<void> Function(String, Device) _builderFor(TestCommandConfig config) {
    return (target, device) async {
      Future<void> Function() action;

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(
            target: target,
            flavor: config.flavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
          );
          action = () => _androidTestBackend.build(options, device);
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            target: target,
            flavor: config.flavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
            scheme: config.scheme,
            xcconfigFile: config.xcconfigFile,
            configuration: config.configuration,
          );
          action = () => _iosTestBackend.build(options, device);
      }

      try {
        await action();
      } catch (err, st) {
        _logger
          ..err('$err')
          ..detail('$st')
          ..err(_failureMessage);
        rethrow;
      }
    };
  }

  Future<void> Function(String, Device) _executorFor(TestCommandConfig config) {
    return (target, device) async {
      Future<void> Function() action;
      Future<void> Function()? finalizer;

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          final options = AndroidAppOptions(
            target: target,
            flavor: config.flavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
          );
          action = () => _androidTestBackend.execute(options, device);
          final package = config.packageName;
          if (package != null) {
            finalizer = () => _androidTestBackend.uninstall(package, device);
          }
          break;
        case TargetPlatform.iOS:
          final options = IOSAppOptions(
            target: target,
            flavor: config.flavor,
            dartDefines: {
              ...config.dartDefines,
              if (config.displayLabel) 'PATROL_TEST_LABEL': basename(target)
            },
            scheme: config.scheme,
            xcconfigFile: config.xcconfigFile,
            configuration: config.configuration,
          );
          action = () async => _iosTestBackend.execute(options, device);
          final bundle = config.bundleId;
          if (bundle != null) {
            finalizer = () => _iosTestBackend.uninstall(bundle, device);
          }
      }

      try {
        await action();
      } catch (err, st) {
        _logger
          ..err('$err')
          ..detail('$st')
          ..err(_failureMessage);
        rethrow;
      } finally {
        await finalizer?.call();
      }
    };
  }
}
