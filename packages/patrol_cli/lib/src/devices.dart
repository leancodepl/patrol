import 'dart:convert';
import 'dart:io' as io;

import 'package:ci/ci.dart' as ci;
import 'package:dispose_scope/dispose_scope.dart';
import 'package:meta/meta.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/interactive_prompts.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:patrol_cli/src/runner/flutter_command.dart';
import 'package:process/process.dart';

class DeviceFinder {
  DeviceFinder({
    required ProcessManager processManager,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  }) : _processManager = processManager,
       _disposeScope = DisposeScope(),
       _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final ProcessManager _processManager;
  final DisposeScope _disposeScope;
  final Logger _logger;

  Future<List<Device>> getAttachedDevices({
    required FlutterCommand flutterCommand,
  }) async {
    final output = await _getCommandOutput(flutterCommand: flutterCommand);
    final jsonOutput = jsonDecode(output) as List<dynamic>;

    final devices = <Device>[];
    for (final deviceJson in jsonOutput) {
      deviceJson as Map<String, dynamic>;

      final targetPlatform = deviceJson['targetPlatform'] as String;
      if (!targetPlatform.startsWith('android-') &&
          targetPlatform != 'ios' &&
          targetPlatform != 'darwin' &&
          targetPlatform != 'web-javascript') {
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

  Future<List<Device>> find(
    List<String> devices, {
    required FlutterCommand flutterCommand,
  }) async {
    final attachedDevices = await getAttachedDevices(
      flutterCommand: flutterCommand,
    );

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
  /// * Shows interactive device selection if multiple devices are attached,
  ///   [wantDevices] is empty, and running in an interactive terminal.
  ///
  /// * Returns the first attached device if [wantDevices] is empty and not
  ///   in an interactive environment.
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
      // Check if we should show interactive device selection
      if (attachedDevices.length > 1 && _shouldShowInteractiveSelection()) {
        final selectedDevice = _promptForDeviceSelection(attachedDevices);
        if (selectedDevice == null) {
          throwToolExit('Device selection was cancelled');
        }
        return [selectedDevice];
      }

      // Default behavior: use first device
      final firstDevice = attachedDevices.first;
      _logger.info(
        'No device specified, using the first one (${firstDevice.name})',
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

  Future<String> _getCommandOutput({
    required FlutterCommand flutterCommand,
  }) async {
    var flutterKilled = false;
    final process = await _processManager.start([
      flutterCommand.executable,
      ...flutterCommand.arguments,
      '--no-version-check',
      '--suppress-analytics',
      'devices',
      '--machine',
    ], runInShell: true);
    _disposeScope.addDispose(() {
      process.kill();
      flutterKilled = true; // `flutter` has exit code 0 on SIGINT
    });

    var output = '';
    process.listenStdOut((line) => output += line).disposedBy(_disposeScope);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throwToolExit('`$flutterCommand devices` exited with code $exitCode');
    } else if (flutterKilled) {
      throwToolInterrupted('`$flutterCommand devices` was interrupted');
    } else {
      return output;
    }
  }

  /// Determines if interactive device selection should be shown.
  ///
  /// Returns true if:
  /// - We have a terminal (stdin.hasTerminal)
  /// - Not running in CI environment
  bool _shouldShowInteractiveSelection() {
    return io.stdin.hasTerminal && !ci.isCI;
  }

  /// Prompts the user to select a device from the list of attached devices.
  ///
  /// Returns the selected device or null if the user cancels.
  Device? _promptForDeviceSelection(List<Device> attachedDevices) {
    try {
      final prompts = InteractivePrompts(logger: _logger);

      final selectedIndex = prompts.selectFromList<Device>(
        prompt: 'Multiple devices found. Please choose one:',
        options: attachedDevices,
        displayFunction: (device) => '${device.name} (${device.id})',
        cancelMessage: 'Cancel and exit',
      );

      if (selectedIndex == null) {
        return null;
      }

      final selectedDevice = attachedDevices[selectedIndex];
      _logger.info(
        'Selected device: ${selectedDevice.name} (${selectedDevice.id})',
      );
      return selectedDevice;
    } catch (err) {
      _logger.detail('Interactive device selection failed: $err');
      return null;
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
        return '$platformDescription $name';
      case TargetPlatform.web:
        return '$platformDescription $name';
    }
  }

  String get platformDescription {
    switch (targetPlatform) {
      case TargetPlatform.android:
        return real ? 'device' : '';
      case TargetPlatform.iOS:
        return real ? 'device' : 'simulator';
      case TargetPlatform.macOS:
        return 'desktop';
      case TargetPlatform.web:
        return 'browser';
    }
  }
}

enum TargetPlatform { iOS, android, macOS, web }

extension TargetPlatformX on TargetPlatform {
  static TargetPlatform fromString(String platform) {
    if (platform == 'ios') {
      return TargetPlatform.iOS;
    } else if (platform.startsWith('android-')) {
      return TargetPlatform.android;
    } else if (platform == 'darwin') {
      return TargetPlatform.macOS;
    } else if (platform == 'web-javascript') {
      return TargetPlatform.web;
    } else {
      throw Exception('Unsupported platform $platform');
    }
  }
}
