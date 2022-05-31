import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/adb.dart';
import 'package:maestro_cli/src/flutter_driver.dart';

Future<int> maestroCommandRunner(List<String> args) async {
  final runner = CommandRunner<int>(
    'maestro',
    'Tool for running Flutter-native UI tests with superpowers',
  )..addCommand(DriveCommand());

  final exitCode = await runner.run(args);
  return exitCode ?? 0;
}

class DriveCommand extends Command<int> {
  DriveCommand() {
    argParser
      ..addOption(
        'host',
        defaultsTo: 'localhost',
        help: 'Host on which the automator server app is listening.',
      )
      ..addOption(
        'port',
        abbr: 'p',
        defaultsTo: '8081',
        help: 'Port on host on which the automator server app is listening.',
      )
      ..addOption(
        'target',
        abbr: 't',
        mandatory: true,
        help: 'Dart file to run.',
      )
      ..addOption(
        'driver',
        abbr: 'd',
        mandatory: true,
        help: 'Dart file which starts flutter_driver.',
      );
  }

  @override
  String get description => 'Drives the app using flutter_driver.';

  @override
  String get name => 'drive';

  @override
  Future<int> run() async {
    var host = argResults?['host'] as String?;
    host ??= 'localhost';

    final portStr = argResults?['port'] as String? ?? '8081';
    final port = int.parse(portStr);

    final target = argResults?['target'] as String?;
    if (target == null) {
      throw ArgumentError('Missing target argument');
    }

    final driver = argResults?['driver'] as String?;
    if (driver == null) {
      throw ArgumentError('Missing driver argument');
    }

    final options = MaestroDriveOptions(
      host: host,
      port: port,
      target: target,
      driver: driver,
    );

    try {
      await installServerApp();
      await forwardPorts(options.port);
      await runServer();
      await runTestsWithOutput(options.driver, options.target);
    } catch (_) {
      // log error and stacktrace when in verbose mode
      return 1;
    }

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
