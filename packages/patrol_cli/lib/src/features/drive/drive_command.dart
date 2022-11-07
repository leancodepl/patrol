import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:patrol_cli/src/common/extensions/map.dart';
import 'package:patrol_cli/src/common/staged_command.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
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
  }) = _DriveCommandConfig;
}

class DriveCommand extends StagedCommand<DriveCommandConfig> {
  DriveCommand({
    required DisposeScope parentDisposeScope,
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestRunner testRunner,
    required AndroidDriver androidDriver,
    required IOSDriver iosDriver,
    required FlutterTool flutterTool,
    required Logger logger,
  })  : _disposeScope = DisposeScope(),
        _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testRunner = testRunner,
        _androidDriver = androidDriver,
        _iosDriver = iosDriver,
        _flutterTool = flutterTool,
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
        defaultsTo: '1',
      );
  }

  final DisposeScope _disposeScope;

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestRunner _testRunner;
  final AndroidDriver _androidDriver;
  final IOSDriver _iosDriver;
  final FlutterTool _flutterTool;
  final Logger _logger;

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

    final driver = argResults?['driver'] as String?;

    final flavor = argResults?['flavor'] as String?;

    final devices = argResults?['device'] as List<String>? ?? [];

    final cliDartDefines = argResults?['dart-define'] as List<String>? ?? [];

    final dartDefines = <String, String>{};
    for (final entry in cliDartDefines) {
      final split = entry.split('=');
      if (split.length != 2) {
        throw FormatException('`dart-define` value $split is not valid');
      }
      dartDefines[split[0]] = split[1];
    }

    for (final dartDefine in dartDefines.entries) {
      _logger
          .info('Passed --dart-define: ${dartDefine.key}=${dartDefine.value}');
    }

    final dynamic packageName = argResults?['package-name'];
    final dynamic bundleId = argResults?['bundle-id'];

    final dynamic wait = argResults?['wait'];
    if (wait != null && int.tryParse(wait as String) == null) {
      throw const FormatException('`wait` argument is not an int');
    }

    var repeat = 1;
    try {
      final repeatStr = argResults?['repeat'] as String? ?? '1';
      repeat = int.parse(repeatStr);
    } on FormatException {
      throw const FormatException('`repeat` argument is not an int');
    }

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
      }.withNullsRemoved(),
      packageName: packageName,
      bundleId: bundleId,
      repeat: repeat,
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
    );

    var exitCode = 0;

    _testRunner
      ..repeats = config.repeat
      ..builder = (target, device) async {
        try {
          await _flutterTool.build(target, device);
        } catch (err) {
          exitCode = 1;
          _logger
            ..severe(err)
            ..severe(
                'See the logs above to learn what happened. If the logs above '
                "aren't useful then it's a bug – please report it.");
        }
      }
      ..executor = (target, device) async {
        try {
          await _flutterTool.drive(target, device);
        } on FlutterDriverFailedException catch (err) {
          exitCode = 1;
          _logger
            ..severe(err)
            ..severe(
              'See the logs above to learn what happened. If the logs above '
              "aren't useful then it's a bug – please report it.",
            );
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

    await _testRunner.run();

    return exitCode;
  }
}
