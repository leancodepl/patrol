import 'dart:convert';
import 'dart:io';

import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;
import 'package:maestro_cli/src/features/drive/platform_driver.dart';

class IOSDriver extends PlatformDriver {
  @override
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required String device,
    required String? flavor,
    Map<String, String> dartDefines = const {},
    required bool verbose,
    required bool debug,
  }) async {
    _runServer(deviceName: device);
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

  @override
  Future<List<Device>> devices() async {
    final result = await Process.run(
      'xcrun',
      ['simctl', 'list', 'devices', '--json'],
    );

    final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final osVersions = (json['devices'] as Map<String, dynamic>).entries;

    final iosDevices = <IOSDevice>[];
    for (final osVersion in osVersions) {
      final os = osVersion.key;
      final devices = osVersion.value as List<dynamic>;
      if (os.contains('com.apple.CoreSimulator.SimRuntime.iOS')) {
        for (final device in devices) {
          final name = (device as Map<String, dynamic>)['name'] as String;
          final state = device['state'] as String;
          final udid = device['udid'] as String;

          if (state == 'Booted') {
            iosDevices.add(IOSDevice(name: name, state: state, udid: udid));
          }
        }
      }
    }

    return iosDevices.map((device) => Device.ios(name: device.name)).toList();
  }

  void _runServer({required String deviceName}) {
    Process.start(
      'xcodebuild',
      [
        'test',
        '-workspace',
        'MaestroExample.xcworkspace',
        '-scheme',
        'MaestroExample',
        '-sdk',
        'iphonesimulator',
        '-destination',
        'platform=iOS Simulator,name=$deviceName',
      ],
      runInShell: true,
      workingDirectory: '/Users/bartek/dev/leancode/maestro/MaestroExample',
    );
  }
}

class IOSDevice {
  IOSDevice({required this.name, required this.state, required this.udid});

  final String name;
  final String state;
  final String udid;
}
