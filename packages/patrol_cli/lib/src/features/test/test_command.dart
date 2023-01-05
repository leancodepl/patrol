import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patrol_cli/src/common/extensions/core.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/test/android_test_runner.dart';
import 'package:patrol_cli/src/features/test/ios_test_runner.dart';

import '../../common/staged_command.dart';
import '../../common/tool_exit.dart';
import '../drive/constants.dart';

part 'test_command.freezed.dart';

@freezed
class TestCommandConfig with _$TestCommandConfig {
  const factory TestCommandConfig({
    required List<Device> devices,
    required List<String> targets,
    required String? flavor,
    required Map<String, String> dartDefines,
    required String? packageName,
    required String? bundleId,
    required int repeat,
    required bool displayLabel,
  }) = _TestCommandConfig;
}

const _defaultRepeats = 1;

class TestCommand extends StagedCommand<TestCommandConfig> {
  TestCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required DartDefinesReader dartDefinesReader,
    required DisposeScope parentDisposeScope,
    required AndroidTestRunner androidTestDriver,
    required IOSTestRunner iosTestDriver,
    required Logger logger,
  })  : _disposeScope = DisposeScope(),
        _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _androidDriver = androidTestDriver,
        _iosTestDriver = iosTestDriver,
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
      );
  }

  final DisposeScope _disposeScope;

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final AndroidTestRunner _androidDriver;
  final IOSTestRunner _iosTestDriver;
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

    final flavor = argResults?['flavor'] as String?;

    final devices = argResults?['device'] as List<String>? ?? [];

    final dartDefines = {
      ..._dartDefinesReader.fromFile(),
      ..._dartDefinesReader.fromCli(
        args: argResults?['dart-define'] as List<String>? ?? [],
      ),
    };

    for (final dartDefine in dartDefines.entries) {
      _logger.info('Got --dart-define ${dartDefine.key}');
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
    for (final device in config.devices) {
      // config.targets.forEach(_testRunner.addTarget);

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          _logger.info('Running `:app:connectedDebugAndroidTest` on Android');
          break;
        case TargetPlatform.iOS:
          _logger.info('Running `xcodebuild test` on Android');
          break;
      }
    }

    const exitCode = 0;

    return exitCode;
  }
}
