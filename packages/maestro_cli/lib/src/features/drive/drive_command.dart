import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/command_runner.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/android/android_driver.dart';
import 'package:maestro_cli/src/features/drive/ios/ios_driver.dart';
import 'package:maestro_cli/src/features/drive/platform_driver.dart';
import 'package:maestro_cli/src/maestro_config.dart';

class DriveCommand extends Command<int> {
  DriveCommand() {
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
      ..addFlag(
        'parallel',
        help: '(experimental) Run tests on devices in parallel.',
      );
  }

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
    if (target is! String) {
      throw const FormatException('`target` argument is not a string');
    }

    final dynamic driver = argResults?['driver'] ?? config.driveConfig.driver;
    if (driver is! String) {
      throw const FormatException('`driver` argument is not a string');
    }

    final dynamic flavor = argResults?['flavor'] ?? config.driveConfig.flavor;
    if (flavor != null && flavor is! String) {
      throw const FormatException('`flavor` argument is not a string');
    }

    final wantDevices = argResults?['devices'] as List<String>? ?? [];

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

    final drivers = <PlatformDriver>[
      AndroidDriver(),
      if (Platform.isMacOS) IOSDriver(),
    ];

    // TODO: handle `all` device

    final availableDevices = [
      for (final driver in drivers) ...await driver.devices()
    ];

    final devicesToUse = findOverlap(
      availableDevices: availableDevices,
      wantDevices: wantDevices,
    );

    for (final device in devicesToUse) {
      await device.map(
        android: (device) => AndroidDriver().run(
          driver: driver,
          target: target,
          host: host,
          port: port,
          device: device.name,
          flavor: flavor as String?,
          verbose: verboseFlag,
          debug: debugFlag,
        ),
        ios: (device) => IOSDriver().run(
          driver: driver,
          target: target,
          host: host,
          port: port,
          device: device.name,
          flavor: flavor as String?,
          verbose: verboseFlag,
          debug: debugFlag,
        ),
      );
    }

    // final parallel = argResults?['parallel'] as bool? ?? false;
    // if (parallel) {
    //   await androidDriver.runTestsInParallel(
    //     driver: driver,
    //     target: target,
    //     host: host,
    //     port: port,
    //     verbose: verboseFlag,
    //     devices: devices,
    //     flavor: flavor as String?,
    //     dartDefines: dartDefines,
    //     debug: debugFlag,
    //   );
    // } else {
    //   await androidDriver.runTestsSequentially(
    //     driver: driver,
    //     target: target,
    //     host: host,
    //     port: port,
    //     verbose: verboseFlag,
    //     devices: devices,
    //     flavor: flavor as String?,
    //     dartDefines: dartDefines,
    //     debug: debugFlag,
    //   );
    // }

    return 0;
  }

  static List<Device> findOverlap({
    required List<Device> availableDevices,
    required List<String> wantDevices,
  }) {
    final availableDevicesSet =
        availableDevices.map((device) => device.name).toSet();

    for (final wantDevice in wantDevices) {
      if (!availableDevicesSet.contains(wantDevice)) {
        throw Exception('Device $wantDevice is not available');
      }
    }

    return availableDevices
        .where((device) => wantDevices.contains(device.name))
        .toList();
  }
}
