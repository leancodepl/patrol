import 'package:adb/adb.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/common/artifacts_repository.dart';
import 'package:patrol_cli/src/common/common.dart';
import 'package:patrol_cli/src/common/logger.dart';
import 'package:patrol_cli/src/features/run_commons/constants.dart';
import 'package:patrol_cli/src/features/run_commons/device.dart';

class AndroidDriver {
  AndroidDriver({
    required ArtifactsRepository artifactsRepository,
    Adb? adb,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _disposeScope = DisposeScope(),
        _artifactsRepository = artifactsRepository,
        _adb = adb ?? Adb(),
        _logger = logger {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  static const _serverPackage = 'pl.leancode.automatorserver';
  static const _instrumentationPackage = 'pl.leancode.automatorserver.test';

  final DisposeScope _disposeScope;
  final ArtifactsRepository _artifactsRepository;
  final Adb _adb;
  final Logger _logger;

  Future<void> run({
    required String port,
    required Device device,
    required String? flavor,
  }) async {
    await _installServer(device: device.id);
    await _installInstrumentation(device: device.id);
    await _runServer(device: device.id, port: port);
  }

  Future<void> _installServer({required String device}) async {
    await _disposeScope.run((scope) async {
      _logger.detail('Installing server');
      try {
        scope.addDispose(() async {
          final result = await _adb.uninstall(_serverPackage, device: device);
          final msg = result.exitCode == 0
              ? 'Uninstalled server package $_serverPackage'
              : 'Failed to uninstall server package $_serverPackage '
                  '(code ${result.exitCode})';
          _logger.detail(msg);
        });

        await _forceInstallApk(
          path: _artifactsRepository.serverArtifactPath,
          device: device,
          packageName: _serverPackage,
        );
      } catch (err) {
        _logger.err('Failed to install server');
        rethrow;
      }

      _logger.detail('Installed server');
    });
  }

  Future<void> _installInstrumentation({String? device}) async {
    await _disposeScope.run((scope) async {
      _logger.detail('Installing instrumentation');

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
          _logger.detail(msg);
        });

        await _forceInstallApk(
          path: _artifactsRepository.instrumentationArtifactPath,
          device: device,
          packageName: _instrumentationPackage,
        );
      } catch (err) {
        _logger.err('Failed to install instrumentation');
        rethrow;
      }

      _logger.detail('Installed instrumentation');
    });
  }

  Future<void> _runServer({
    required String? device,
    required String port,
  }) async {
    await _disposeScope.run((scope) async {
      _logger.detail('Started native Android instrumentation');
      final process = await _adb.instrument(
        packageName: _instrumentationPackage,
        intentClass: 'androidx.test.runner.AndroidJUnitRunner',
        device: device,
        arguments: {envPortKey: port},
      );

      process.listenStdOut(_logger.detail).disposedBy(scope);
      process.listenStdErr(_logger.err).disposedBy(scope);
      scope.addDispose(() async {
        final msg = process.kill()
            ? 'Killed native Android instrumentation'
            : 'Failed to kill native Android instrumentation';
        _logger.detail(msg);
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
