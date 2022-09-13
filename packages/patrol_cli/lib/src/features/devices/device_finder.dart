import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

class DeviceFinder {
  DeviceFinder();

  Future<List<Device>> getAttachedDevices() async {
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

  //@visibleForTesting
  List<Device> findDevicesToUse({
    required List<Device> attachedDevices,
    required List<String> wantDevices,
  }) {
    final attachedDevicesSet =
        attachedDevices.map((device) => device.resolvedName).toSet();

    for (final wantDevice in wantDevices) {
      if (!attachedDevicesSet.contains(wantDevice)) {
        throw Exception('Device $wantDevice is not attached');
      }
    }

    return attachedDevices
        .where((device) => wantDevices.contains(device.resolvedName))
        .toList();
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
