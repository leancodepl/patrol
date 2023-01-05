import 'dart:convert';
import 'dart:io' show Process;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/common/tool_exit.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';

class DeviceFinder {
  DeviceFinder({required Logger logger}) : _logger = logger;

  final Logger _logger;

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

  Future<List<Device>> find(List<String> devices) async {
    final attachedDevices = await getAttachedDevices();

    return findDevicesToUse(
      attachedDevices: attachedDevices,
      wantDevices: devices,
    );
  }

  /// Transforms device names into [Device] objects.
  ///
  /// ### Edge cases
  ///
  /// * Throws if no devices are attached.
  ///
  /// * Returns the first attached device if [wantDevices] is empty.
  ///
  /// * Returns all attached devices if [wantDevices] contains a single element
  ///   `'all'`.
  ///
  /// * Throws if any of the [wantDevices] isn't attached.
  @visibleForTesting
  List<Device> findDevicesToUse({
    required List<Device> attachedDevices,
    required List<String> wantDevices,
  }) {
    // sanitize device names
    for (var i = 0; i < wantDevices.length; i++) {
      wantDevices[i] = wantDevices[i].trim();
    }

    if (attachedDevices.isEmpty) {
      throwToolExit('No devices attached');
    }

    if (wantDevices.isEmpty) {
      final firstDevice = attachedDevices.first;
      _logger.info(
        'No device specified, using the first one (${firstDevice.resolvedName})',
      );
      return [firstDevice];
    }

    if (wantDevices.contains('all')) {
      if (wantDevices.length != 1) {
        throwToolExit("No other devices can be specified when using 'all'");
      }

      return attachedDevices;
    }

    final attachedDevicesSet = attachedDevices.toSet();

    for (final wantDevice in wantDevices) {
      bool predicate(Device attachedDevice) {
        return attachedDevice.id == wantDevice ||
            attachedDevice.name == wantDevice;
      }

      if (!attachedDevicesSet.any(predicate)) {
        throwToolExit('Device $wantDevice is not attached');
      }
    }

    bool predicate(Device attachedDevice) {
      return wantDevices.contains(attachedDevice.id) ||
          wantDevices.contains(attachedDevice.name);
    }

    return attachedDevices.where(predicate).toList();
  }

  Future<String> _getCommandOutput() async {
    final process = await Process.start(
      'flutter',
      ['--no-version-check', 'devices', '--machine'],
      runInShell: true,
    );

    var output = '';
    process.listenStdOut((line) => output += line);
    await process.exitCode;
    return output;
  }
}
