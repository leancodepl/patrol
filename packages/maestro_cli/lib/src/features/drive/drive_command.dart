import 'dart:io';

import 'package:adb/adb.dart';
import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/command_runner.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/adb.dart' as drive_adb;
import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;
import 'package:maestro_cli/src/maestro_config.dart';

class DriveCommand extends Command<int> {
  DriveCommand(List<String> devices) {
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
        allowed: ['all', ...devices],
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

    dynamic host = argResults?['host'];
    host ??= config.driveConfig.host;
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

    dynamic target = argResults?['target'];
    target ??= config.driveConfig.target;
    if (target is! String) {
      throw const FormatException('`target` argument is not a string');
    }

    dynamic driver = argResults?['driver'];
    driver ??= config.driveConfig.driver;
    if (driver is! String) {
      throw const FormatException('`driver` argument is not a string');
    }

    dynamic flavor = argResults?['flavor'];
    flavor ??= config.driveConfig.flavor;
    if (flavor != null && flavor is! String) {
      throw const FormatException('`flavor` argument is not a string');
    }

    final devicesArg = argResults?['devices'] as List<String>?;
    final devices = await _parseDevices(devicesArg);

    final parallel = argResults?['parallel'] as bool? ?? false;

    if (parallel) {
      await _runTestsInParallel(
        driver: driver,
        target: target,
        host: host,
        port: port,
        verbose: verboseFlag,
        devices: devices,
        flavor: flavor as String?,
      );
    } else {
      await _runTestsSequentially(
        driver: driver,
        target: target,
        host: host,
        port: port,
        verbose: verboseFlag,
        devices: devices,
        flavor: flavor as String?,
      );
    }

    return 0;
  }

  Future<void> _runTestsInParallel({
    required String driver,
    required String target,
    required String host,
    required int port,
    required bool verbose,
    required List<String> devices,
    required String? flavor,
  }) async {
    await Future.wait(
      devices.map((device) async {
        await drive_adb.installApps(device: device, debug: debugFlag);
        await drive_adb.forwardPorts(port, device: device);
        drive_adb.runServer(device: device, port: port);
        await flutter_driver.runTestsWithOutput(
          driver: driver,
          target: target,
          host: host,
          port: port,
          verbose: verboseFlag,
          device: device,
          flavor: flavor,
        );
      }),
    );
  }

  Future<void> _runTestsSequentially({
    required String driver,
    required String target,
    required String host,
    required int port,
    required bool verbose,
    required List<String> devices,
    required String? flavor,
  }) async {
    for (final device in devices) {
      await drive_adb.installApps(device: device, debug: debugFlag);
      await drive_adb.forwardPorts(port, device: device);
      drive_adb.runServer(device: device, port: port);
      await flutter_driver.runTestsWithOutput(
        driver: driver,
        target: target,
        host: host,
        port: port,
        verbose: verboseFlag,
        device: device,
        flavor: flavor,
      );
    }
  }

  Future<List<String>> _parseDevices(List<String>? devicesArg) async {
    if (devicesArg == null || devicesArg.isEmpty) {
      final adbDevices = await Adb().devices();

      if (adbDevices.isEmpty) {
        throw Exception('No devices attached');
      }

      if (adbDevices.length > 1) {
        final firstDevice = adbDevices.first;
        log.info(
          'More than 1 device attached. Running only on the first one ($firstDevice)',
        );

        return [firstDevice];
      }

      return adbDevices;
    }

    if (devicesArg.contains('all')) {
      return Adb().devices();
    }

    return devicesArg;
  }
}
