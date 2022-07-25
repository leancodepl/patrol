import 'package:maestro_cli/src/common/logging.dart';
import 'package:maestro_cli/src/features/drive/android/adb.dart';
import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;

class AndroidDriver {
  late MaestroAdb _adb;

  Future<void> init() async {
    _adb = MaestroAdb();
    await _adb.init();
  }

  Future<void> runTestsInParallel({
    required String driver,
    required String target,
    required String host,
    required int port,
    required bool verbose,
    required bool debug,
    required List<String> devices,
    required String? flavor,
    required Map<String, String>? dartDefines,
  }) async {
    await Future.wait(
      devices.map((device) async {
        await _adb.installApps(device: device, debug: debug);
        await _adb.forwardPorts(port, device: device);
        _adb.runServer(device: device, port: port);
        await flutter_driver.runWithOutput(
          driver: driver,
          target: target,
          host: host,
          port: port,
          verbose: verbose,
          device: device,
          flavor: flavor,
          dartDefines: dartDefines ?? {},
        );
      }),
    );
  }

  Future<void> runTestsSequentially({
    required String driver,
    required String target,
    required String host,
    required int port,
    required bool verbose,
    required bool debug,
    required List<String> devices,
    required String? flavor,
    Map<String, String> dartDefines = const {},
  }) async {
    for (final device in devices) {
      await _adb.installApps(device: device, debug: debug);
      await _adb.forwardPorts(port, device: device);
      _adb.runServer(device: device, port: port);
      await flutter_driver.runWithOutput(
        driver: driver,
        target: target,
        host: host,
        port: port,
        verbose: verbose,
        device: device,
        flavor: flavor,
        dartDefines: dartDefines,
      );
    }
  }

  Future<List<String>> parseDevices(List<String>? devicesArg) async {
    if (devicesArg == null || devicesArg.isEmpty) {
      final adbDevices = await _adb.devices();

      if (adbDevices.isEmpty) {
        throw Exception('No devices attached');
      }

      if (adbDevices.length > 1) {
        final firstDevice = adbDevices.first;
        log.info(
          'More than 1 device attached. Running only on the first one ($firstDevice)',
        );

        return [firstDevice];
      }

      return adbDevices;
    }

    if (devicesArg.contains('all')) {
      return _adb.devices();
    }

    return devicesArg;
  }
}
