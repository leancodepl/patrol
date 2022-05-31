import 'dart:io';

// import 'package:maestro/automator.dart';
import 'package:maestro_cli/src/command_runner.dart';

Future<int> main(List<String> args) async {
  final exitCode = await maestroCommandRunner(args);

  exit(exitCode);

  // final argParser = ArgParser();
  // final driveParser = _generateDriveParser();

  // argParser.addCommand('drive', driveParser);

  // print('Maestro by LeanCode | v$maestroVersion');

  // final argResults = argParser.parse(args);
  // if (argResults.command?.name != 'drive') {
  //   return 1;
  // }

  // final port = int.parse(argResults.command!['port'] as String);
  // final target = argResults.command!['target'] as String;
  // final driver = argResults.command!['driver'] as String;

  // await installServerApp();
  // await forwardPorts(port);
  // await runServer();
  // await runTestsWithOutput(driver, target);

  // // Automator.init(port);
  // // await Automator.instance.pressHome();
  // // await Automator.instance.stop();

  return 0;
}

// ArgParser _generateDriveParser() {
//   final driveParser = ArgParser();

//   return driveParser
//     ..addOption(
//       'port',
//       abbr: 'p',
//       defaultsTo: '8081',
//     )
//     ..addOption(
//       'host',
//       abbr: 'h',
//       defaultsTo: 'localhost',
//     )
//     ..addOption(
//       'target',
//       abbr: 't',
//       mandatory: true,
//     )
//     ..addOption(
//       'driver',
//       abbr: 'd',
//       mandatory: true,
//     );
// }
