import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/adb.dart';
import 'package:maestro_cli/src/flutter_driver.dart';

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
    final host = argResults?['host'] as String;

    final portStr = argResults?['port'] as String;
    final port = int.parse(portStr);

    final target = argResults?['target'] as String;

    final driver = argResults?['driver'] as String;

    final options = MaestroDriveOptions(
      host: host,
      port: port,
      target: target,
      driver: driver,
    );

    try {
      await installApps();
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
