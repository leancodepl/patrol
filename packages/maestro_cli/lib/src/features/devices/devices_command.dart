import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/logging.dart';
import 'package:maestro_cli/src/features/drive/android/android_driver.dart';
import 'package:maestro_cli/src/features/drive/ios/ios_driver.dart';
import 'package:maestro_cli/src/features/drive/platform_driver.dart';

class DevicesCommand extends Command<int> {
  @override
  String get name => 'devices';

  @override
  String get description => 'List available devices, simulators and emulators.';

  @override
  Future<int> run() async {
    final drivers = <PlatformDriver>[
      AndroidDriver(),
      if (Platform.isMacOS) IOSDriver(),
    ];

    final devices = [for (final driver in drivers) ...await driver.devices()];

    if (devices.isEmpty) {
      log.info('No devices attached');
      return 1;
    }

    for (final device in devices) {
      log.info(device.name);
    }

    return 0;
  }
}
