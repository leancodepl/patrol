import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/extensions/map.dart';
import 'package:patrol_cli/src/common/staged_command.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:patrol_cli/src/features/drive/flutter_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/android_driver.dart';
import 'package:patrol_cli/src/features/drive/platform/ios_driver.dart';
import 'package:patrol_cli/src/features/drive/test_finder.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
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
  DriveCommand({
    required DisposeScope parentDisposeScope,
    required TopLevelFlags topLevelFlags,
    required ArtifactsRepository artifactsRepository,
    required DeviceFinder deviceFinder,
    required TestFinder testFinder,
    required TestRunner testRunner,
  })  : _disposeScope = DisposeScope(),
        _topLevelFlags = topLevelFlags,
        _artifactsRepository = artifactsRepository,
        _deviceFinder = deviceFinder,
        _testFinder = testFinder,
        _testRunner = testRunner {
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
      log.info('Passed --dart--define: ${dartDefine.key}=${dartDefine.value}');
    }

    final dynamic packageName = argResults?['package-name'];
    final dynamic bundleId = argResults?['bundle-id'];

    final dynamic wait = argResults?['wait'];
    if (wait != null && int.tryParse(wait as String) == null) {
      throw const FormatException('`wait` argument is not an int');
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
