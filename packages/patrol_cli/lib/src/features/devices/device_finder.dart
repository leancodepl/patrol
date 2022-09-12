import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

class DeviceFinder {
  DeviceFinder();

  Future<List<Device>> getDevices() async {
    final output = await _getCommandOutput();
    final jsonOutput = jsonDecode(output) as List<dynamic>;

    final devices = <Device>[];
    for (final deviceJson in jsonOutput) {
      deviceJson as Map<String, dynamic>;

      final targetPlatform = deviceJson['targetPlatform'] as String;
      if (!targetPlatform.startsWith('android-') && targetPlatform != 'ios') {
        continue;
      }

      devices.add(
        Device(
          name: deviceJson['name'] as String,
          id: deviceJson['id'] as String,
          targetPlatform: TargetPlatformX.fromString(targetPlatform),
          real: !(deviceJson['emulator'] as bool),
        ),
      );
    }

    return devices;
  }

  Future<String> _getCommandOutput() async {
    final process = await Process.start(
      'flutter',
      ['devices', '--machine'],
      runInShell: true,
    );

    var output = '';
    process.listenStdOut((line) => output += line);
    await process.exitCode;
    return output;
  }
}
