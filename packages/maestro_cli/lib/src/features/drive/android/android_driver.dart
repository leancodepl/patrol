import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:maestro_cli/src/common/common.dart';
import 'package:maestro_cli/src/features/drive/constants.dart';
import 'package:maestro_cli/src/features/drive/device.dart';
import 'package:maestro_cli/src/features/drive/flutter_driver.dart';
import 'package:maestro_cli/src/features/drive/platform_driver.dart';
import 'package:path/path.dart' as path;

class AndroidDriver implements PlatformDriver {
  AndroidDriver(DisposeScope parentDisposeScope)
      : _disposeScope = DisposeScope(),
        _adb = Adb() {
    _disposeScope.disposed(parentDisposeScope);
  }

  static const _serverPackageName = 'pl.leancode.automatorserver';
  static const _instrumentationPackageName = 'pl.leancode.automatorserver.test';

  final DisposeScope _disposeScope;
  final Adb _adb;

  @override
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required Device device,
    required String? flavor,
    required Map<String, String> dartDefines,
    required bool verbose,
    required bool debug,
  }) async {
    await _forwardPorts(port, device: device.id);
    await _installServer(device: device.id, debug: debug);
    await _installInstrumentation(device: device.id, debug: debug);
    await _runServer(device: device.id, port: port);
    await FlutterDriver(_disposeScope).runWithOutput(
      driver: driver,
      target: target,
      host: host,
      port: port,
      device: device.id,
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
    required List<Device> devices,
    required String? flavor,
    required Map<String, String> dartDefines,
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
          verbose: verbose,
          debug: debug,
          device: device,
          flavor: flavor,
          dartDefines: dartDefines,
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
    required List<Device> devices,
    required String? flavor,
    required Map<String, String> dartDefines,
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
        dartDefines: dartDefines,
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
        packageName: _serverPackageName,
      );

      _disposeScope.addDispose(() async {
        final result = await _adb.uninstall(
          _serverPackageName,
          device: device,
        );
        final msg = result.exitCode == 0
            ? 'Uninstalled server package $_serverPackageName'
            : 'Failed to uninstall server package $_serverPackageName '
                '(code ${result.exitCode})';
        log.fine(msg);
      });
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
        packageName: _instrumentationPackageName,
      );

      _disposeScope.addDispose(() async {
        final result = await _adb.uninstall(
          _instrumentationPackageName,
          device: device,
        );
        final msg = result.exitCode == 0
            ? 'Uninstalled instrumentation package $_instrumentationPackageName'
            : 'Failed to uninstall instrumentation package $_instrumentationPackageName '
                '(code ${result.exitCode})';
        log.fine(msg);
      });
    } catch (err) {
      progress.fail('Failed to install instrumentation');
      rethrow;
    }

    progress.complete('Installed instrumentation');
  }

  Future<void> _forwardPorts(int port, {String? device}) async {
    final progress = log.progress('Forwarding ports');

    try {
      final cancel = await _adb.forwardPorts(
        fromHost: port,
        toDevice: port,
        device: device,
      );

      _disposeScope.addDispose(() async {
        await cancel();
        log.fine('Stopped port forwarding');
      });
    } catch (err) {
      progress.fail('Failed to forward ports');
      rethrow;
    }

    progress.complete('Forwarded ports');
  }

  Future<void> _runServer({
    required String? device,
    required int port,
  }) async {
    final process = await _adb.instrument(
      packageName: _instrumentationPackageName,
      intentClass: 'androidx.test.runner.AndroidJUnitRunner',
      device: device,
      arguments: {envPortKey: port.toString()},
    );

    _disposeScope.addDispose(() async {
      final msg = process.kill()
          ? 'Killed instrumentation with ADB'
          : 'Failed to kill instrumentation with ADB';
      log.fine(msg);
    });
    process.listenStdOut(log.info).disposed(_disposeScope);
    process.listenStdErr(log.severe).disposed(_disposeScope);
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
