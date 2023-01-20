import 'package:ansi_styles/extension.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/extensions/core.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/run_commons/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';
import 'package:patrol_cli/src/features/run_commons/test_finder.dart';
import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:patrol_cli/src/features/test/ios_test_backend.dart';
import 'package:patrol_cli/src/features/test/native_test_runner.dart';

import '../../common/staged_command.dart';
import '../../common/tool_exit.dart';
import '../run_commons/constants.dart';

class TestCommandConfig {
  const TestCommandConfig({
    required this.devices,
    required this.targets,
    required this.flavor,
    required this.scheme,
    required this.xcconfigFile,
    required this.configuration,
    required this.dartDefines,
    required this.packageName,
    required this.bundleId,
    required this.repeat,
    required this.displayLabel,
  });

  final List<Device> devices;
  final List<String> targets;
  final String? flavor;
  final String scheme;
  final String xcconfigFile;
  final String configuration;
  final Map<String, String> dartDefines;
  final String? packageName;
  final String? bundleId;
  final int repeat;
  final bool displayLabel;
}

const _defaultRepeats = 1;

class TestCommand extends StagedCommand<TestCommandConfig> {
  TestCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required NativeTestRunner testRunner,
    required DartDefinesReader dartDefinesReader,
    required DisposeScope parentDisposeScope,
    required AndroidNativeTestBackend androidTestDriver,
    required IOSTestBackend iosTestDriver,
    required Logger logger,
  })  : _disposeScope = DisposeScope(),
        _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testRunner = testRunner,
        _androidTestBackend = androidTestDriver,
        _iosTestBackend = iosTestDriver,
        _dartDefinesReader = dartDefinesReader,
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);

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
        defaultsTo: 'Runner',
      )
      ..addOption(
        'xcconfig',
        help: '(iOS only) Xcode .xcconfig file to use',
        defaultsTo: 'Flutter/Debug.xcconfig',
      )
      ..addOption(
        'configuration',
        help: '(iOS only) Xcode configuration to use',
        defaultsTo: 'Debug',
      );
  }

  @override
  bool get hidden => true;

  final DisposeScope _disposeScope;

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final NativeTestRunner _testRunner;
  final AndroidNativeTestBackend _androidTestBackend;
  final IOSTestBackend _iosTestBackend;
  final DartDefinesReader _dartDefinesReader;

  final Logger _logger;

  bool verbose = false;

  @override
  String get name => 'test';

  @override
  String get description => 'Test the app using native instrumentation.';

  @override
  Future<TestCommandConfig> parseInput() async {
    final target = argResults?['target'] as List<String>? ?? [];
    final targets = target.isNotEmpty
        ? _testFinder.findTests(target)
        : _testFinder.findAllTests();

    _logger.detail('Received ${targets.length} test target(s)');
    for (final t in targets) {
      _logger.detail('Received test target: $t');
    }

    final flavor = argResults?['flavor'] as String?;

    final devices = argResults?['device'] as List<String>? ?? [];

    final dartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(
        args: argResults?['dart-define'] as List<String>? ?? [],
      ),
    };

    _logger.detail('Received ${dartDefines.length} --dart-define(s)');
    for (final dartDefine in dartDefines.entries) {
      _logger.detail('Received --dart-define: ${dartDefine.key}');
    }

    final dynamic packageName = argResults?['package-name'];
    final dynamic bundleId = argResults?['bundle-id'];

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

    final attachedDevices = await _deviceFinder.find(devices);

    return TestCommandConfig(
      devices: attachedDevices,
      targets: targets,
      flavor: flavor,
      scheme: argResults?['scheme'] as String,
      xcconfigFile: argResults?['xcconfig'] as String,
      configuration: argResults?['configuration'] as String,
      dartDefines: <String, String?>{
        ...dartDefines,
        envWaitKey: wait as String? ?? '0',
        envPackageNameKey: packageName as String?,
        envBundleIdKey: bundleId as String?,
        envVerbose: '$verbose',
      }.withNullsRemoved(),
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
      ..executor = (target, device) async {
        Future<void> Function() callback;
        switch (device.targetPlatform) {
          case TargetPlatform.android:
            callback = () => _androidTestBackend.run(
                  device: device,
                  options: AndroidAppOptions(
                    target: target,
                    flavor: config.flavor,
                    dartDefines: config.dartDefines,
                  ),
                );
            break;
          case TargetPlatform.iOS:
            callback = () => _iosTestBackend.run(
                  device: device,
                  options: IOSAppOptions(
                    target: target,
                    flavor: config.flavor,
                    dartDefines: config.dartDefines,
                    scheme: config.scheme,
                    xcconfigFile: config.xcconfigFile,
                    configuration: config.configuration,
                  ),
                );
            break;
        }

        try {
          await callback();
        } catch (err) {
          _logger
            ..err('$err')
            ..err(
              'See the logs above to learn what happened. If the logs above '
              "aren't useful then it's a bug – please report it.",
            );
          rethrow;
        }
      };

    final results = await _testRunner.run();

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
}
