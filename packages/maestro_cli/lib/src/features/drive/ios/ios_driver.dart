import 'dart:convert';
import 'dart:io';

import 'package:maestro_cli/src/common/logging.dart';
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
    await _runServer(deviceName: device);
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

    return iosDevices.map((device) => Device.iOS(name: device.name)).toList();
  }

  Future<void> _runServer({required String deviceName}) async {
    // FIXME: Fix failing to build when using Dart x86_64.
    final process = await Process.start(
      'xcodebuild',
      [
        //'-arm64',
        //'xcodebuild',
        'test',
        //'ARCHS=x86_64',
        //'ONLY_ACTIVE_ARCH=YES',
        //'-arch',
        //'"x86_64"',
        '-workspace',
        'AutomatorServer.xcworkspace',
        '-scheme',
        'AutomatorServer',
        '-sdk',
        'iphonesimulator',
        '-destination',
        'platform=iOS Simulator,name=$deviceName',
      ],
      runInShell: true,
      // FIXME: don't hardcode working directory
      includeParentEnvironment: false,
      workingDirectory:
          '/Users/bartek/dev/leancode/maestro/AutomatorServer/ios',
    );

    final stdOutSub = process.stdout.listen((msg) {
      systemEncoding.decode(msg).split('\n').map((str) => str.trim()).toList()
        ..removeWhere((element) => element.isEmpty)
        ..forEach(log.info);
    });

    final stdErrSub = process.stderr.listen((msg) {
      final text = systemEncoding.decode(msg).trim();
      log.severe(text);
    });
  }
}

class IOSDevice {
  IOSDevice({required this.name, required this.state, required this.udid});

  final String name;
  final String state;
  final String udid;
}
