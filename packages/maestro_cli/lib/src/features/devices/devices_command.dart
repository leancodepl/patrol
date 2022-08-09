import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/logging.dart';
import 'package:maestro_cli/src/features/drive/device.dart';

class DevicesCommand extends Command<int> {
  @override
  String get name => 'devices';

  @override
  String get description => 'List available devices, simulators and emulators.';

  @override
  Future<int> run() async {
    final devices = await getDevices();

    if (devices.isEmpty) {
      log.info('No devices attached');
      return 1;
    }

    for (final device in devices) {
      log.info(device.name);
    }

    return 0;
  }

  static Future<List<Device>> getDevices() async {
    final result = await Process.run(
      'flutter',
      ['devices', '--machine'],
    );

    final jsonOutput = jsonDecode(result.stdout as String) as List<dynamic>;

    return jsonOutput.map((dynamic deviceJson) {
      deviceJson as Map<String, dynamic>;

      return Device(
        name: deviceJson['name'] as String,
        id: deviceJson['id'] as String,
        targetPlatform: TargetPlatformX.fromString(
          deviceJson['targetPlatform'] as String,
        ),
        real: !(deviceJson['emulator'] as bool),
      );
    }).toList();
  }
}
