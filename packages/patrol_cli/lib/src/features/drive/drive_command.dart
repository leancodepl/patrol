import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/features/drive/android/android_driver.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';
import 'package:patrol_cli/src/features/drive/flutter_driver.dart';
import 'package:patrol_cli/src/features/drive/ios/ios_driver.dart';
import 'package:patrol_cli/src/features/drive/test_runner.dart';
import 'package:patrol_cli/src/patrol_config.dart';
import 'package:patrol_cli/src/top_level_flags.dart';

class DriveCommand extends Command<int> {
  DriveCommand(
    DisposeScope parentDisposeScope,
    this._topLevelFlags,
    this._artifactsRepository,
  )   : _disposeScope = DisposeScope(),
        _deviceFinder = DeviceFinder(),
        _testRunner = TestRunner() {
    _disposeScope.disposedBy(parentDisposeScope);

    argParser
      ..addOption(
        'host',
        help: 'Host on which the automator server app is listening.',
      )
      ..addOption(
        'port',
        abbr: 'p',
        help: 'Port on host on which the automator server app is listening.',
      )
      ..addOption(
        'target',
        abbr: 't',
        help: 'Dart file to run.',
      )
      ..addOption(
        'driver',
        abbr: 'd',
        help: 'Dart file which starts flutter_driver.',
      )
      ..addOption(
        'flavor',
        help: 'Flavor of the app to run.',
      )
      ..addMultiOption(
        'devices',
        help: 'List of devices to drive the app on.',
        valueHelp: 'all, emulator-5554',
      )
      ..addMultiOption(
        'dart-define',
        help:
            'List of additional key-value pairs that will be available to the '
            'app under test.',
        valueHelp: 'SOME_VAR=SOME_VALUE',
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
        help: 'The amount of seconds to wait after the test fails or succeeds.',
      );
  }

  final DisposeScope _disposeScope;
  final ArtifactsRepository _artifactsRepository;
  final TopLevelFlags _topLevelFlags;

  final DeviceFinder _deviceFinder;
  final TestRunner _testRunner;

  @override
  String get name => 'drive';

  @override
  String get description => 'Drive the app using flutter_driver.';

  @override
  Future<int> run() async {
    final toml = File(configFileName).readAsStringSync();
    final config = PatrolConfig.fromToml(toml);

    final dynamic host = argResults?['host'] ?? config.driveConfig.host;
    if (host is! String) {
      throw const FormatException('`host` argument is not a string');
    }

    dynamic portStr = argResults?['port'];
    portStr ??= config.driveConfig.port.toString();
    if (portStr is! String) {
      throw const FormatException('`port` argument is not a string');
    }

    final port = int.tryParse(portStr);
    if (port == null) {
      throw const FormatException('`port` cannot be parsed into an integer');
    }

    final dynamic target = argResults?['target'] ?? config.driveConfig.target;
    if (target != null && target is! String) {
      throw const FormatException('`target` argument is not a string');
    }

    if (target != null && !File(target as String).existsSync()) {
      throw Exception('target file $target does not exist');
    }

    final targets = target != null
        ? [target as String]
        : _findTests(Directory('integration_test'));

    final dynamic driver = argResults?['driver'] ?? config.driveConfig.driver;
    if (driver is! String) {
      throw const FormatException('`driver` argument is not a string');
    }

    final dynamic flavor = argResults?['flavor'] ?? config.driveConfig.flavor;
    if (flavor != null && flavor is! String) {
      throw const FormatException('`flavor` argument is not a string');
    }

    final devices = argResults?['devices'] as List<String>? ?? [];

    final dartDefines = config.driveConfig.dartDefines ?? {};
    final dynamic cliDartDefines = argResults?['dart-define'];
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
        argResults?['package-name'] ?? config.driveConfig.packageName;

    final dynamic bundleId =
        argResults?['bundle-id'] ?? config.driveConfig.bundleId;

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

    for (final device in activeDevices) {
      _testRunner.addDevice(device);

      switch (device.targetPlatform) {
        case TargetPlatform.android:
          await AndroidDriver(_disposeScope, _artifactsRepository).run(
            port: port,
            device: device,
            flavor: flavor as String?,
            verbose: _topLevelFlags.verbose,
            debug: _topLevelFlags.debug,
          );
          break;
        case TargetPlatform.iOS:
          await IOSDriver(_disposeScope, _artifactsRepository).run(
            port: port,
            device: device,
            flavor: flavor as String?,
            verbose: _topLevelFlags.verbose,
          );
          break;
      }
    }

    final flutterDriver = FlutterDriver(_disposeScope);

    for (final target in targets) {
      _testRunner.addTest((device) async {
        if (_disposeScope.disposed) {
          log.fine('Skipping running $target...');
          return;
        }

        await flutterDriver.run(
          driver: driver,
          target: target,
          host: host,
          port: port,
          device: device,
          flavor: flavor as String?,
          verbose: _topLevelFlags.verbose,
          dartDefines: _dartDefines({
            ...dartDefines,
            envWaitKey: wait,
            envPackageNameKey: packageName as String?,
            envBundleIdKey: bundleId as String?,
          }),
        );
      });
    }

    await _testRunner.run();

    return 0;
  }

  /// Searches [directory] and returns files that end with `_test.dart` as
  /// absolute paths.
  List<String> _findTests(Directory directory) {
    return directory
        .listSync(recursive: true, followLinks: false)
        .where(
          (entity) =>
              entity.path.endsWith('_test.dart') &&
              FileSystemEntity.isFileSync(entity.path),
        )
        .map((entity) => entity.absolute.path)
        .toList();
  }

  Map<String, String> _dartDefines(Map<String, String?> defines) {
    return {
      for (final entry in defines.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }
}
