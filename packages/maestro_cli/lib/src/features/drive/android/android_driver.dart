import 'package:adb/adb.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/constants.dart';
import 'package:maestro_cli/src/features/drive/flutter_driver.dart'
    as flutter_driver;
import 'package:maestro_cli/src/features/drive/platform_driver.dart';
import 'package:path/path.dart' as path;

class AndroidDriver implements PlatformDriver {
  final _adb = Adb();

  @override
  Future<List<Device>> devices() async {
    final adbDevices = await _adb.devices();
    return adbDevices
        .map((adbDevice) => Device.android(name: adbDevice))
        .toList();
  }

  @override
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required String device,
    required String? flavor,
    Map<String, String> dartDefines = const {},
    required bool verbose,
    required bool debug,
  }) async {
    await _installServer(device: device, debug: debug);
    await _installInstrumentation(device: device, debug: debug);
    await _forwardPorts(port, device: device);
    _runServer(device: device, port: port);
    await flutter_driver.runWithOutput(
      driver: driver,
      target: target,
      host: host,
      port: port,
      device: device,
      flavor: flavor,
      dartDefines: dartDefines,
      verbose: verbose,
    );
  }

  Future<void> runTestsInParallel({
    required String driver,
    required String target,
    required String host,
    required int port,
    required List<String> devices,
    required String? flavor,
    Map<String, String> dartDefines = const {},
    required bool verbose,
    required bool debug,
  }) async {
    await Future.wait(
      devices.map((device) async {
        await run(
          driver: driver,
          target: target,
          host: host,
          port: port,
          debug: debug,
          device: device,
          flavor: flavor,
          dartDefines: dartDefines,
          verbose: verbose,
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
      await run(
        driver: driver,
        target: target,
        host: host,
        port: port,
        verbose: verbose,
        debug: debug,
        device: device,
        flavor: flavor,
      );
    }
  }

  Future<void> _installServer({
    required String device,
    required bool debug,
  }) async {
    final progress = log.progress('Installing server');
    try {
      final p = path.join(
        artifactPath,
        debug ? debugServerArtifactFile : serverArtifactFile,
      );
      await _forceInstallApk(
        path: p,
        device: device,
        packageName: 'pl.leancode.automatorserver',
      );
    } catch (err) {
      progress.fail('Failed to install server');
      rethrow;
    }
    progress.complete('Installed server');
  }

  Future<void> _installInstrumentation({
    String? device,
    bool debug = false,
  }) async {
    final progress = log.progress('Installing instrumentation');
    try {
      final p = path.join(
        artifactPath,
        debug ? debugInstrumentationArtifactFile : instrumentationArtifactFile,
      );
      await _forceInstallApk(
        path: p,
        device: device,
        packageName: 'pl.leancode.automatorserver.test',
      );
    } catch (err) {
      progress.fail('Failed to install instrumentation');
      rethrow;
    }

    progress.complete('Installed instrumentation');
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

  Future<void> _forceInstallApk({
    required String path,
    required String? device,
    required String packageName,
  }) async {
    try {
      await _adb.install(path, device: device);
    } on AdbInstallFailedUpdateIncompatible {
      await _adb.uninstall(packageName, device: device);
      await _adb.install(path, device: device);
    }
  }
}
