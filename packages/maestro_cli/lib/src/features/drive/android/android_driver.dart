import 'package:adb/adb.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/constants.dart';
import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;
import 'package:path/path.dart' as path;

class AndroidDriver {
  late Adb _adb;

  Future<void> init() async {
    _adb = Adb();
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
    Map<String, String>? dartDefines = const {},
  }) async {
    await Future.wait(
      devices.map((device) async {
        await _installApps(device: device, debug: debug);
        await _forwardPorts(port, device: device);
        _runServer(device: device, port: port);
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
      await _installApps(device: device, debug: debug);
      await _forwardPorts(port, device: device);
      _runServer(device: device, port: port);
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

  Future<List<String>> devices(List<String>? devicesArg) async {
    if (devicesArg == null || devicesArg.isEmpty) {
      final adbDevices = await _adb.devices();

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

  Future<void> _installApps({String? device, bool debug = false}) async {
    final serverInstallProgress = log.progress('Installing server');
    try {
      final p = path.join(
        artifactPath,
        debug ? debugServerArtifactFile : serverArtifactFile,
      );
      await _adb.forceInstallApk(p, device: device);
    } catch (err) {
      serverInstallProgress.fail('Failed to install server');
      rethrow;
    }
    serverInstallProgress.complete('Installed server');

    final instrumentInstallProgress =
        log.progress('Installing instrumentation');
    try {
      final p = path.join(
        artifactPath,
        debug ? debugInstrumentationArtifactFile : instrumentationArtifactFile,
      );
      await _adb.forceInstallApk(p, device: device);
    } catch (err) {
      instrumentInstallProgress.fail('Failed to install instrumentation');
      rethrow;
    }

    instrumentInstallProgress.complete('Installed instrumentation');
  }

  Future<void> _forwardPorts(int port, {String? device}) async {
    final progress = log.progress('Forwarding ports');

    try {
      await _adb.forwardPorts(
        fromHost: port,
        toDevice: port,
        device: device,
      );
    } catch (err) {
      progress.fail('Failed to forward ports');
      rethrow;
    }

    progress.complete('Forwarded ports');
  }

  void _runServer({
    required String? device,
    required int port,
  }) {
    _adb.instrument(
      packageName: 'pl.leancode.automatorserver.test',
      intentClass: 'androidx.test.runner.AndroidJUnitRunner',
      device: device,
      onStdout: log.info,
      onStderr: log.severe,
      arguments: {envPortKey: port.toString()},
    );
  }
}
