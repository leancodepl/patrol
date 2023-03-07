import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/features/devices/device_finder.dart';
import 'package:patrol_cli/src/runner/patrol_command.dart';

class DevicesCommand extends PatrolCommand {
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
      _logger.err('No devices attached');
      return 1;
    }

    for (final device in devices) {
      _logger.info('${device.name} (${device.id})');
    }

    return 0;
  }
}
