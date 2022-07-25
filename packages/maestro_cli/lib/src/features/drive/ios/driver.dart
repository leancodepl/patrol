import 'dart:io';

import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;

class IOSDriver {
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required bool verbose,
    required bool debug,
    required String device,
    required String? flavor,
    Map<String, String> dartDefines = const {},
  }) async {
    _runServer(deviceName: 'iPhone 12');
    await flutter_driver.runWithOutput(
      driver: driver,
      target: target,
      host: host,
      port: port,
      verbose: verbose,
      device: device,
      flavor: flavor,
      dartDefines: dartDefines,
    );
  }

  void _runServer({required String deviceName}) {
    Process.start('xcodebuild', [
      'test',
      '-workspace',
      'MaestroExample.xcworkspace',
      '-scheme',
      'MaestroExample',
      '-sdk',
      'iphonesimulator',
      '-destination',
      'platform=iOS Simulator,name=$deviceName',
    ]);
  }
}
