import 'dart:io';

import 'package:args/args.dart';
import 'package:maestro/src/adb.dart';
import 'package:maestro/automator.dart';
import 'package:maestro/flutter_driver.dart';
import 'package:maestro/version.dart';

Future<int> main(List<String> args) async {
  final argParser = ArgParser();
  final driveParser = _generateDriveParser();

  argParser.addCommand('drive', driveParser);

  print('Maestro by LeanCode | v${maestroVersion}');

  final argResults = argParser.parse(args);
  if (argResults.command?.name != 'drive') {
    return 1;
  }

  final port = int.parse(argResults.command!['port']);
  final target = argResults.command!['target'];
  final driver = argResults.command!['driver'];

  await installServer();
  await forwardPorts(port);
  await runServer();
  await runTestsWithOutput(driver, target);

  Automator.init(port);
  await Automator.instance.stop();

  return 0;
}

ArgParser _generateDriveParser() {
  final driveParser = ArgParser();

  driveParser.addOption(
    'port',
    abbr: 'p',
    defaultsTo: '8081',
  );
  driveParser.addOption(
    'host',
    abbr: 'h',
    defaultsTo: 'localhost',
  );
  driveParser.addOption(
    'target',
    abbr: 't',
    mandatory: true,
  );
  driveParser.addOption(
    'driver',
    abbr: 'd',
    mandatory: true,
  );

  return driveParser;
}
