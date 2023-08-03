import 'dart:convert';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';

class DeviceFinder {
  DeviceFinder({
    required ProcessManager processManager,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _processManager = processManager,
        _disposeScope = DisposeScope(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final DisposeScope _disposeScope;
  final Logger _logger;

  Future<List<Device>> getAttachedDevices() async {
    final output = await _getCommandOutput();
    final jsonOutput = jsonDecode(output) as List<dynamic>;

    final devices = <Device>[];
    for (final deviceJson in jsonOutput) {
      deviceJson as Map<String, dynamic>;

      final targetPlatform = deviceJson['targetPlatform'] as String;
      if (!targetPlatform.startsWith('android-') &&
          targetPlatform != 'ios' &&
          targetPlatform != 'darwin') {
        //TODO verify darwin
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
    var flutterKilled = false;
    final process = await _processManager.start(
      ['flutter', '--no-version-check', 'devices', '--machine'],
      runInShell: true,
    );
    _disposeScope.addDispose(() async {
      process.kill();
      flutterKilled = true; // `flutter` has exit code 0 on SIGINT
    });

    var output = '';
    process.listenStdOut((line) => output += line).disposedBy(_disposeScope);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throwToolExit('`flutter devices` exited with code $exitCode');
    } else if (flutterKilled) {
      throwToolInterrupted('`flutter devices` was interrupted');
    } else {
      return output;
    }
  }
}

class Device {
  const Device({
    required this.name,
    required this.id,
    required this.targetPlatform,
    required this.real,
  });

  final String name;
  final String id;
  final TargetPlatform targetPlatform;
  final bool real;

  /// Returns the name that Patrol is usually interested with.
  ///
  /// On Android, this is the ID of the device, e.g "emulator-5554".
  ///
  /// On iOS, this is the name of the device, e.g "iPhone 13" or
  /// "Barteks-iPhone".
  String get resolvedName {
    switch (targetPlatform) {
      case TargetPlatform.android:
        return id;
      case TargetPlatform.iOS:
        return name;
      case TargetPlatform.macOS:
        return name; //TODO verify
    }
  }

  String get description {
    switch (targetPlatform) {
      case TargetPlatform.android:
        if (platformDescription.isEmpty) {
          return id;
        } else {
          return '$platformDescription $id';
        }
      case TargetPlatform.iOS:
        return '$platformDescription $name';
      case TargetPlatform.macOS:
        return '$platformDescription $name'; //TODO verify
    }
  }

  String get platformDescription {
    switch (targetPlatform) {
      case TargetPlatform.android:
        return real ? 'device' : '';
      case TargetPlatform.iOS:
        return real ? 'device' : 'simulator';
      case TargetPlatform.macOS:
        return 'desktop'; //TODO verify
    }
  }
}

enum TargetPlatform { iOS, android, macOS }

extension TargetPlatformX on TargetPlatform {
  static TargetPlatform fromString(String platform) {
    if (platform == 'ios') {
      return TargetPlatform.iOS;
    } else if (platform.startsWith('android-')) {
      return TargetPlatform.android;
    } else if (platform == 'darwin') {
      return TargetPlatform.macOS;
    } else {
      throw Exception('Unsupported platform $platform');
    }
  }
}
