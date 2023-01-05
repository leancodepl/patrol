import 'package:ansi_styles/extension.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patrol_cli/src/common/extensions/core.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/common/staged_command.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/dart_defines_reader.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:patrol_cli/src/features/drive/flutter_tool.dart';
import 'package:patrol_cli/src/features/drive/platform/android_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/ios_driver.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';

part 'drive_command.freezed.dart';

@freezed
class DriveCommandConfig with _$DriveCommandConfig {
  const factory DriveCommandConfig({
    required List<Device> devices,
    required List<String> targets,
    required String host,
    required String port,
    required String driver,
    required String? flavor,
    required Map<String, String> dartDefines,
    required String? packageName,
    required String? bundleId,
    required int repeat,
    required String? useApplicationBinary,
    required bool displayLabel,
  }) = _DriveCommandConfig;
}

const _defaultRepeats = 1;

class DriveCommand extends StagedCommand<DriveCommandConfig> {
  DriveCommand({
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestRunner testRunner,
    required AndroidDriver androidDriver,
    required IOSDriver iosDriver,
    required FlutterTool flutterTool,
    required DartDefinesReader dartDefinesReader,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _disposeScope = DisposeScope(),
        _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testRunner = testRunner,
        _androidDriver = androidDriver,
        _iosDriver = iosDriver,
        _flutterTool = flutterTool,
        _dartDefinesReader = dartDefinesReader,
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
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
        'host',
        help: 'Host on which the automator server app is listening.',
      )
      ..addOption(
        'port',
        help: 'Port on host on which the automator server app is listening.',
      )
      ..addOption(
        'driver',
        help: 'Dart file which starts flutter_driver.',
        defaultsTo: 'test_driver/integration_test.dart',
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
      ..addOption(
        'use-application-binary',
        help:
            'Specify a pre-built application binary to use when running. For Android applications, '
            'this must be the path to an APK. For iOS applications, the path to a .app or an IPA. '
            'Other device types do not yet support prebuilt application binaries. '
            'See `flutter drive --help` on for more information.',
        valueHelp: 'path/to/app.apk|path/to/iphonesimulator/app.app',
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
  final TestRunner _testRunner;
  final AndroidDriver _androidDriver;
  final IOSDriver _iosDriver;
  final FlutterTool _flutterTool;
  final DartDefinesReader _dartDefinesReader;

  final Logger _logger;

  bool verbose = false;

  @override
  String get name => 'drive';

  @override
  String get description => 'Drive the app using flutter_driver.';

  @override
  Future<DriveCommandConfig> parseInput() async {
    final host = argResults?['host'] as String?;

    final port = argResults?['port'] as String?;
    if (port is String && int.tryParse(port) == null) {
      throw const FormatException('`port` is not an int');
    }

    final target = argResults?['target'] as List<String>? ?? [];
    final targets = target.isNotEmpty
        ? _testFinder.findTests(target)
        : _testFinder.findAllTests();

    for (final t in targets) {
      _logger.detail('Found test $t');
    }

    final driver = argResults?['driver'] as String?;

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

    final useApplicationBinary =
        argResults?['use-application-binary'] as String?;

    final displayLabel = argResults?['label'] as bool?;

    if (repeat < 1) {
      throwToolExit('repeat count must not be smaller than 1');
    }

    if (repeat != 1) {
      _logger.info('Every test target will be run $repeat times');
    }

    final attachedDevices = await _deviceFinder.find(devices);

    return DriveCommandConfig(
      devices: attachedDevices,
      targets: targets,
      host: host ?? envHostDefaultValue,
      port: port ?? envPortDefaultValue,
      driver: driver ?? 'test_driver/integration_test.dart',
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
      useApplicationBinary: useApplicationBinary,
      displayLabel: displayLabel ?? true,
    );
  }

  @override
  Future<int> execute(DriveCommandConfig config) async {
    _flutterTool.init(
      driver: config.driver,
      host: config.host,
      port: config.port,
      flavor: config.flavor,
      dartDefines: config.dartDefines,
      displayLabel: config.displayLabel,
    );

    _testRunner
      ..repeats = config.repeat
      ..useApplicationBinary = config.useApplicationBinary
      ..builder = (target, device) async {
        try {
          await _flutterTool.build(target, device);
        } catch (err) {
          _logger
            ..err('$err')
            ..err(
                'See the logs above to learn what happened. If the logs above '
                "aren't useful then it's a bug – please report it.");
          rethrow;
        }
      }
      ..executor = (target, device) async {
        try {
          await _flutterTool.drive(target, device, config.useApplicationBinary);
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

    for (final device in config.devices) {
      _testRunner.addDevice(device);
      config.targets.forEach(_testRunner.addTarget);

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          await _androidDriver.run(
            port: config.port,
            device: device,
            flavor: config.flavor,
          );
          break;
        case TargetPlatform.iOS:
          await _iosDriver.run(
            port: config.port,
            device: device,
            flavor: config.flavor,
          );
          break;
      }
    }

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
