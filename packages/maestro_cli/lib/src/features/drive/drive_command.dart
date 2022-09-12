import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:maestro_cli/src/common/artifacts_repository.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/devices/devices_command.dart';
import 'package:maestro_cli/src/features/drive/android/android_driver.dart';
import 'package:maestro_cli/src/features/drive/device.dart';
import 'package:maestro_cli/src/features/drive/ios/ios_driver.dart';
import 'package:maestro_cli/src/features/drive/test_runner.dart';
import 'package:maestro_cli/src/maestro_config.dart';
import 'package:maestro_cli/src/top_level_flags.dart';

class DriveCommand extends Command<int> {
  DriveCommand(
    DisposeScope parentDisposeScope,
    this._topLevelFlags,
    this._artifactsRepository,
  )   : _disposeScope = DisposeScope(),
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
      )
      ..addFlag(
        'parallel',
        help: '(experimental, inactive) Run tests on devices in parallel.',
      );
  }

  final DisposeScope _disposeScope;
  final ArtifactsRepository _artifactsRepository;
  final TopLevelFlags _topLevelFlags;

  final TestRunner _testRunner;

  @override
  String get name => 'drive';

  @override
  String get description => 'Drive the app using flutter_driver.';

  @override
  Future<int> run() async {
    final toml = File(configFileName).readAsStringSync();
    final config = MaestroConfig.fromToml(toml);

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

    final wantDevices = argResults?['devices'] as List<String>? ?? [];
    final wantsAll = wantDevices.contains('all');
    if (wantsAll && wantDevices.length > 1) {
      throw Exception("Device 'all' must be the only device");
    }

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

    final availableDevices = await getDevices(_disposeScope);
    if (availableDevices.isEmpty) {
      throw Exception('No devices are available');
    } else {
      log.fine('Successfully queried available devices');
    }

    if (wantDevices.isEmpty) {
      final firstDevice = availableDevices.first;
      wantDevices.add(firstDevice.resolvedName);
      log.info(
        'No device specified, using the first one (${firstDevice.resolvedName})',
      );
    }

    findDevicesToRun(
      availableDevices: availableDevices,
      wantDevices: wantsAll
          ? availableDevices.map((device) => device.resolvedName).toList()
          : wantDevices,
    ).forEach(_testRunner.addDevice);

    for (final target in targets) {
      _testRunner.addTest((device) async {
        switch (device.targetPlatform) {
          case TargetPlatform.android:
            final childDisposeScope = DisposeScope();
            _disposeScope.addDispose(() async {
              if (childDisposeScope.disposed) {
                await childDisposeScope.dispose();
              }
            });
            await AndroidDriver(_disposeScope, _artifactsRepository).run(
              driver: driver,
              target: target,
              host: host,
              port: port,
              device: device,
              flavor: flavor as String?,
              verbose: _topLevelFlags.verbose,
              debug: _topLevelFlags.debug,
              dartDefines: _dartDefines({
                'MAESTRO_WAIT': wait,
                'MAESTRO_APP_PACKAGE_NAME': packageName as String?,
                'MAESTRO_APP_BUNDLE_ID': bundleId as String?,
              }),
            );
            await childDisposeScope.run((scope) => scope.dispose());
            break;
          case TargetPlatform.iOS:
            await IOSDriver(_disposeScope, _artifactsRepository).run(
              driver: driver,
              target: target,
              host: host,
              port: port,
              device: device,
              flavor: flavor as String?,
              verbose: _topLevelFlags.verbose,
              dartDefines: _dartDefines({
                'MAESTRO_WAIT': wait,
                'MAESTRO_APP_PACKAGE_NAME': packageName as String?,
                'MAESTRO_APP_BUNDLE_ID': bundleId as String?,
              }),
              simulator: !device.real,
            );
            break;
        }
      });
    }

    print('starting test run');
    await _testRunner.run();
    print('done test run');

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

  @visibleForTesting
  static List<Device> findDevicesToRun({
    required List<Device> availableDevices,
    required List<String> wantDevices,
  }) {
    final availableDevicesSet =
        availableDevices.map((device) => device.resolvedName).toSet();

    for (final wantDevice in wantDevices) {
      if (!availableDevicesSet.contains(wantDevice)) {
        throw Exception('Device $wantDevice is not available');
      }
    }

    return availableDevices
        .where((device) => wantDevices.contains(device.resolvedName))
        .toList();
  }

  Map<String, String> _dartDefines(Map<String, String?> defines) {
    return {
      for (final entry in defines.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }
}
