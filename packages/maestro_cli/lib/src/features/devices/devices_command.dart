import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/device.dart';

class DevicesCommand extends Command<int> {
  @override
  String get name => 'devices';

  @override
  String get description => 'List attached devices, simulators and emulators.';

  @override
  Future<int> run() async {
    final devices = await getDevices();

    if (devices.isEmpty) {
      log.info('No devices attached');
      return 1;
    }

    for (final device in devices) {
      log.info('${device.name} (${device.id})');
    }

    return 0;
  }

  static Future<List<Device>> getDevices([DisposeScope? disposeScope]) async {
    final process = await Process.start(
      'flutter',
      ['devices', '--machine'],
      runInShell: true,
    );

    disposeScope?.addDispose(() async {
      final msg = process.kill()
          ? 'Killed `flutter devices`'
          : 'Failed to kill `flutter devices`';
      log.info(msg);
    });

    var msg = '';
    process.listenStdOut((line) => msg += line);
    await process.exitCode;

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
