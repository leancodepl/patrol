import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/features/drive/constants.dart';
import 'package:patrol_cli/src/features/drive/device.dart';

class AndroidDriver {
  AndroidDriver(
    DisposeScope parentDisposeScope,
    this._artifactsRepository,
  )   : _disposeScope = DisposeScope(),
        _adb = Adb() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  static const _serverPackage = 'pl.leancode.automatorserver';
  static const _instrumentationPackage = 'pl.leancode.automatorserver.test';

  final ArtifactsRepository _artifactsRepository;

  final DisposeScope _disposeScope;
  final Adb _adb;

  Future<void> run({
    required String? port,
    required Device device,
    required String? flavor,
    required bool verbose,
    required bool debug,
  }) async {
    port ??= envPortDefaultValue;

    await _forwardPorts(port, device: device.id);
    await _installServer(device: device.id, debug: debug);
    await _installInstrumentation(device: device.id, debug: debug);
    await _runServer(device: device.id, port: port);
  }

  Future<void> _installServer({
    required String device,
    required bool debug,
  }) async {
    await _disposeScope.run((scope) async {
      final progress = log.progress('Installing server');
      try {
        scope.addDispose(() async {
          final result = await _adb.uninstall(_serverPackage, device: device);
          final msg = result.exitCode == 0
              ? 'Uninstalled server package $_serverPackage'
              : 'Failed to uninstall server package $_serverPackage '
                  '(code ${result.exitCode})';
          log.fine(msg);
        });

        await _forceInstallApk(
          path: _artifactsRepository.serverArtifactPath,
          device: device,
          packageName: _serverPackage,
        );
      } catch (err) {
        progress.fail('Failed to install server');
        rethrow;
      }

      progress.complete('Installed server');
    });
  }

  Future<void> _installInstrumentation({
    String? device,
    bool debug = false,
  }) async {
    await _disposeScope.run((scope) async {
      final progress = log.progress('Installing instrumentation');

      try {
        scope.addDispose(() async {
          final result = await _adb.uninstall(
            _instrumentationPackage,
            device: device,
          );
          final msg = result.exitCode == 0
              ? 'Uninstalled instrumentation package $_instrumentationPackage'
              : 'Failed to uninstall instrumentation package $_instrumentationPackage '
                  '(code ${result.exitCode})';
          log.fine(msg);
        });

        await _forceInstallApk(
          path: _artifactsRepository.instrumentationArtifactPath,
          device: device,
          packageName: _instrumentationPackage,
        );
      } catch (err) {
        progress.fail('Failed to install instrumentation');
        rethrow;
      }

      progress.complete('Installed instrumentation');
    });
  }

  Future<void> _forwardPorts(String port, {String? device}) async {
    await _disposeScope.run((scope) async {
      final progress = log.progress('Forwarding ports');

      try {
        final cancel = await _adb.forwardPorts(
          fromHost: int.parse(port),
          toDevice: int.parse(port),
          device: device,
        );

        scope.addDispose(() async {
          await cancel();
          log.fine('Stopped port forwarding');
        });
      } catch (err) {
        progress.fail('Failed to forward ports');
        rethrow;
      }

      progress.complete('Forwarded ports');
    });
  }

  Future<void> _runServer({
    required String? device,
    required String port,
  }) async {
    await _disposeScope.run((scope) async {
      log.fine('Started native Android instrumentation');
      final process = await _adb.instrument(
        packageName: _instrumentationPackage,
        intentClass: 'androidx.test.runner.AndroidJUnitRunner',
        device: device,
        arguments: {envPortKey: port},
      );

      process.listenStdOut(log.info).disposedBy(scope);
      process.listenStdErr(log.severe).disposedBy(scope);
      scope.addDispose(() async {
        final msg = process.kill()
            ? 'Killed native Android instrumentation'
            : 'Failed to kill native Android instrumentation';
        log.fine(msg);
      });
    });
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
