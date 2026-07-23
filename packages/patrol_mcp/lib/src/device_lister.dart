import 'dart:convert';
import 'dart:io';

import 'package:patrol_cli/patrol_cli.dart'
    show Device, FlutterCommand, TargetPlatform;

/// Lists the devices Flutter reports as attached, by running
/// `flutter devices --machine` as a subprocess and parsing its output.
///
/// Runs Flutter as a subprocess (rather than patrol_cli's in-process
/// `DeviceFinder`) so nothing is written to this process's `stdout` — the MCP's
/// JSON-RPC channel stays clean.
Future<List<Device>> listAttachedDevices({
  required FlutterCommand flutterCommand,
}) async {
  final result = await Process.run(flutterCommand.executable, [
    ...flutterCommand.arguments,
    'devices',
    '--machine',
  ]);
  if (result.exitCode != 0) {
    throw Exception(
      'flutter devices exited with code ${result.exitCode}: ${result.stderr}',
    );
  }
  return parseFlutterDevices(result.stdout as String);
}

/// Parses `flutter devices --machine` JSON into [Device]s, mirroring the
/// mapping patrol_cli's `DeviceFinder` uses (unsupported platforms are skipped).
List<Device> parseFlutterDevices(String machineJson) {
  final entries = jsonDecode(machineJson) as List<dynamic>;
  final devices = <Device>[];
  for (final entry in entries) {
    entry as Map<String, dynamic>;
    final platform = _targetPlatform(entry['targetPlatform'] as String);
    if (platform == null) {
      continue;
    }
    devices.add(
      Device(
        name: entry['name'] as String,
        id: entry['id'] as String,
        targetPlatform: platform,
        real: !(entry['emulator'] as bool),
      ),
    );
  }
  return devices;
}

/// Mirrors patrol_cli's `TargetPlatformX.fromString`, returning `null` for
/// platforms patrol doesn't handle (instead of throwing).
TargetPlatform? _targetPlatform(String platform) {
  if (platform == 'ios') {
    return TargetPlatform.iOS;
  } else if (platform.startsWith('android-')) {
    return TargetPlatform.android;
  } else if (platform == 'darwin') {
    return TargetPlatform.macOS;
  } else if (platform == 'web-javascript') {
    return TargetPlatform.web;
  }
  return null;
}
