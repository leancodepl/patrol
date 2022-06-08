import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/external/adb.dart' as adb;
import 'package:maestro_cli/src/external/flutter_driver.dart' as flutter_driver;
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
        'device',
        help: 'Serial number of ADB device to use.',
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

    final device = argResults?['device'] as String?;

    final options = MaestroDriveOptions(
      host: host,
      port: int.parse(portStr),
      target: target,
      driver: driver,
    );

    await adb.installApps(device: device);
    await adb.forwardPorts(options.port, device: device);
    await adb.runServer(device: device);
    await flutter_driver.runTestsWithOutput(
      options.driver,
      options.target,
      device: device,
    );

    return 0;
  }
}

class MaestroDriveOptions {
  const MaestroDriveOptions({
    required this.host,
    required this.port,
    required this.target,
    required this.driver,
  });

  final String host;
  final int port;
  final String target;
  final String driver;
}
