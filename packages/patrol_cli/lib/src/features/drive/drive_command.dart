import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/extensions/map.dart';
import 'package:patrol_cli/src/common/globals.dart' as globals;
import 'package:patrol_cli/src/common/staged_command.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:patrol_cli/src/features/drive/flutter_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/android_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/ios_driver.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:patrol_cli/src/patrol_config.dart';
import 'package:patrol_cli/src/top_level_flags.dart';

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
  }) = _DriveCommandConfig;
}

class DriveCommand extends StagedCommand<DriveCommandConfig> {
  DriveCommand(
    DisposeScope parentDisposeScope,
    this._topLevelFlags,
    this._artifactsRepository, [
    DeviceFinder? deviceFinder,
    TestFinder? testFinder,
  ])  : _disposeScope = DisposeScope(),
        _deviceFinder = deviceFinder ?? DeviceFinder(),
        _testFinder = testFinder ??
            TestFinder(
              integrationTestDir: globals.fs.directory('integration_test'),
              fileSystem: globals.fs,
            ),
        _testRunner = TestRunner() {
    _disposeScope.disposedBy(parentDisposeScope);

    argParser
      ..addMultiOption(
        'targets',
        abbr: 't',
        help: 'Integration tests to run. If empty, all tests are run.',
        valueHelp: 'integration_test/app_test.dart',
      )
      ..addMultiOption(
        'devices',
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
      );
  }

  final DisposeScope _disposeScope;
  final ArtifactsRepository _artifactsRepository;
  final TopLevelFlags _topLevelFlags;

  final DeviceFinder _deviceFinder;
  final TestFinder _testFinder;
  final TestRunner _testRunner;

  @override
  String get name => 'drive';

  @override
  String get description => 'Drive the app using flutter_driver.';

  @override
  Future<DriveCommandConfig> parseInput() async {
    PatrolConfig? config;
    try {
      final toml = globals.fs.file(configFileName).readAsStringSync();
      config = PatrolConfig.fromToml(toml);
    } on FileSystemException {
      log.info("patrol.toml doesn't exist");
    }

    final dynamic host = argResults?['host'] ?? config?.driveConfig.host;
    if (host != null && host is! String) {
      throw const FormatException('`host` argument is not a string');
    }

    final dynamic port = argResults?['port'] ?? config?.driveConfig.port;
    if (port != null && port is String && int.tryParse(port) == null) {
      throw const FormatException('`port` argument does not represent an int');
    }

    final dynamic target = argResults?['targets'] ?? config?.driveConfig.target;
    if (target != null && target is! String) {
      throw const FormatException('`target` argument is not a string');
    }

    if (target != null && !globals.fs.file(target as String).existsSync()) {
      throw Exception('target file $target does not exist');
    }

    final targets =
        target != null ? [target as String] : _testFinder.findTests();

    final dynamic driver = argResults?['driver'] ?? config?.driveConfig.driver;
    if (driver != null && driver is! String) {
      throw const FormatException('`driver` argument is not a string');
    }

    final dynamic flavor = argResults?['flavor'] ?? config?.driveConfig.flavor;
    if (flavor != null && flavor is! String) {
      throw const FormatException('`flavor` argument is not a string');
    }

    final devices = argResults?['devices'] as List<String>? ?? [];
    for (var i = 0; i < devices.length; i++) {
      devices[i] = devices[i].trim();
    }

    final dartDefines = config?.driveConfig.dartDefines ?? {};
    final dynamic cliDartDefines = argResults?['dart-define'] ?? <String>[];
    if (cliDartDefines != null && cliDartDefines is! List<String>) {
      throw FormatException(
        '`dart-define` argument $cliDartDefines is not a list',
      );
    }

    for (final entry in cliDartDefines as List<String>) {
      final split = entry.split('=');
      if (split.length != 2) {
        throw FormatException('`dart-define` value $split is not valid');
      }
      dartDefines[split[0]] = split[1];
    }

    for (final dartDefine in dartDefines.entries) {
      log.info('Passed --dart--define: ${dartDefine.key}=${dartDefine.value}');
    }

    final dynamic packageName =
        argResults?['package-name'] ?? config?.driveConfig.packageName;

    final dynamic bundleId =
        argResults?['bundle-id'] ?? config?.driveConfig.bundleId;

    final dynamic wait = argResults?['wait'] ?? '0';
    if (int.tryParse(wait as String) == null) {
      throw const FormatException('`wait` argument is not an int');
    }

    final attachedDevices = await _deviceFinder.getAttachedDevices();
    if (attachedDevices.isEmpty) {
      throw Exception('No devices attached');
    } else {
      log.fine('Successfully queried available devices');
    }

    if (devices.isEmpty) {
      final firstDevice = attachedDevices.first;
      devices.add(firstDevice.resolvedName);
      log.info(
        'No device specified, using the first one (${firstDevice.resolvedName})',
      );
    } else if (devices.contains('all')) {
      if (devices.length > 1) {
        throw Exception("Device 'all' must be the only device");
      }

      devices.addAll(attachedDevices.map((e) => e.resolvedName));
    }

    final activeDevices = _deviceFinder.findDevicesToUse(
      attachedDevices: attachedDevices,
      wantDevices: devices,
    );

    return DriveCommandConfig(
      devices: activeDevices,
      targets: targets,
      host: host as String? ?? envHostDefaultValue,
      port: port as String? ?? envPortDefaultValue,
      driver: driver as String? ?? 'test_driver/integration_test.dart',
      flavor: flavor as String?,
      dartDefines: {
        ...dartDefines,
        envWaitKey: wait,
        envPackageNameKey: packageName as String?,
        envBundleIdKey: bundleId as String?,
      }.withNullsRemoved(),
      packageName: packageName,
      bundleId: bundleId,
    );
  }

  @override
  Future<int> execute(DriveCommandConfig config) async {
    for (final device in config.devices) {
      _testRunner.addDevice(device);

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          await AndroidDriver(_disposeScope, _artifactsRepository).run(
            port: config.port,
            device: device,
            flavor: config.flavor,
            verbose: _topLevelFlags.verbose,
            debug: _topLevelFlags.debug,
          );
          break;
        case TargetPlatform.iOS:
          await IOSDriver(_disposeScope, _artifactsRepository).run(
            port: config.port,
            device: device,
            flavor: config.flavor,
            verbose: _topLevelFlags.verbose,
          );
          break;
      }
    }

    final flutterDriver = FlutterDriver(_disposeScope);

    for (final target in config.targets) {
      _testRunner.addTest((device) async {
        if (_disposeScope.disposed) {
          log.fine('Skipping running $target...');
          return;
        }

        final flutterDriverOptions = FlutterDriverOptions(
          driver: config.driver,
          target: target,
          host: config.host,
          port: config.port,
          device: device,
          flavor: config.flavor,
          verbose: _topLevelFlags.verbose,
          dartDefines: config.dartDefines,
        );

        await flutterDriver.run(flutterDriverOptions);
      });
    }

    await _testRunner.run();

    return 0;
  }
}
