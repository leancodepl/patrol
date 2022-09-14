import 'package:args/command_runner.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';

class DevicesCommand extends Command<int> {
  DevicesCommand() : _deviceFinder = DeviceFinder();

  final DeviceFinder _deviceFinder;

  @override
  String get name => 'devices';

  @override
  String get description => 'List attached devices, simulators and emulators.';

  @override
  Future<int> run() async {
    final devices = await _deviceFinder.getAttachedDevices();

    if (devices.isEmpty) {
      log.warning('No devices attached');
      return 1;
    }

    for (final device in devices) {
      log.info('${device.name} (${device.id})');
    }

    return 0;
  }
}
