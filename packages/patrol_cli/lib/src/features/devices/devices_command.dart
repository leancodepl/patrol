import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

class DevicesCommand extends Command<int> {
  DevicesCommand(DisposeScope parentDisposeScope)
      : _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final DisposeScope _disposeScope;

  @override
  String get name => 'devices';

  @override
  String get description => 'List attached devices, simulators and emulators.';

  @override
  Future<int> run() async {
    final devices = await _getDevices();

    if (devices.isEmpty) {
      log.warning('No devices attached');
      return 1;
    }

    for (final device in devices) {
      log.info('${device.name} (${device.id})');
    }

    return 0;
  }

  Future<List<Device>> _getDevices() async {
    int? exitCode;
    final process = await Process.start(
      'flutter',
      ['devices', '--machine'],
      runInShell: true,
    );

    _disposeScope.addDispose(() async {
      if (exitCode != null) {
        return;
      }

      final msg = process.kill()
          ? 'Killed `flutter devices`'
          : 'Failed to kill `flutter devices`';
      log.fine(msg);
    });

    var msg = '';
    process.listenStdOut((line) => msg += line).disposedBy(_disposeScope);
    exitCode = await process.exitCode;
    log.fine('exit code of `flutter devices`: $exitCode');

    final jsonOutput = jsonDecode(msg) as List<dynamic>;

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
}

@Deprecated('Cannot be disposed')
Future<List<Device>> getDevices(DisposeScope disposeScope) async {
  int? exitCode;
  final process = await Process.start(
    'flutter',
    ['devices', '--machine'],
    runInShell: true,
  );

  disposeScope.addDispose(() async {
    if (exitCode != null) {
      return;
    }

    final msg = process.kill()
        ? 'Killed `flutter devices`'
        : 'Failed to kill `flutter devices`';
    log.fine(msg);
  });

  var msg = '';
  process.listenStdOut((line) => msg += line).disposedBy(disposeScope);
  exitCode = await process.exitCode;
  log.fine('exit code of `flutter devices`: $exitCode');

  final jsonOutput = jsonDecode(msg) as List<dynamic>;

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
