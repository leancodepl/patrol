import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';

class DevicesCommand extends Command<int> {
  DevicesCommand({required DeviceFinder deviceFinder, required Logger logger})
      : _deviceFinder = deviceFinder,
        _logger = logger;

  final DeviceFinder _deviceFinder;
  final Logger _logger;

  @override
  String get name => 'devices';

  @override
  String get description => 'List attached devices, simulators and emulators.';

  @override
  Future<int> run() async {
    final devices = await _deviceFinder.getAttachedDevices();

    if (devices.isEmpty) {
      _logger.warning('No devices attached');
      return 1;
    }

    for (final device in devices) {
      _logger.info('${device.name} (${device.id})');
    }

    return 0;
  }
}
