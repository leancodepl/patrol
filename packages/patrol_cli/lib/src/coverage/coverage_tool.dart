import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:adb/adb.dart';
import 'package:coverage/coverage.dart' as coverage;
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:package_config/package_config.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/device_to_host_port_transformer.dart';
import 'package:patrol_cli/src/coverage/vm_connection_details.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

class CoverageTool {
  CoverageTool({
    required FileSystem fs,
    required Directory rootDirectory,
    required ProcessManager processManager,
    required Platform platform,
    required Adb adb,
    required DisposeScope parentDisposeScope,
    required Logger logger,
  })  : _fs = fs,
        _rootDirectory = rootDirectory,
        _processManager = processManager,
        _platform = platform,
        _adb = adb,
        _logger = logger,
        _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final FileSystem _fs;
  final Directory _rootDirectory;
  final ProcessManager _processManager;
  final Platform _platform;
  final Adb _adb;
  final Logger _logger;
  final DisposeScope _disposeScope;

  Future<void> run({
    required Device device,
    required Set<RegExp> packagesRegExps,
    required TargetPlatform platform,
    required Logger logger,
    required Set<Glob> ignoreGlobs,
  }) async {
    final homeDirectory =
        _platform.environment['HOME'] ?? _platform.environment['USERPROFILE'];
    final hitMap = <String, coverage.HitMap>{};

    await _disposeScope.run(
      (scope) async {
        final logsProcess = await _processManager.start(
          [
            'flutter',
            'logs',
            '-d',
            device.id,
          ],
          workingDirectory: homeDirectory,
          runInShell: true,
        )
          ..disposedBy(scope);

        final vmConnectionDetailsStream = logsProcess.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .map(VMConnectionDetails.tryExtractFromLogs)
            .where((details) => details != null)
            .cast<VMConnectionDetails>()
            .transform(
              DeviceToHostPortTransformer(
                device: device,
                devicePlatform: platform,
                adb: _adb,
                logger: logger,
              ),
            )
            .asBroadcastStream();

        final totalTestCount = await vmConnectionDetailsStream
            .asyncMap(_collectTotalTestCount)
            .first;
        logger.info('Total test count: $totalTestCount');

        var count = 0;
        final coverageCollectionCompleter = Completer<void>()
          ..disposedBy(scope, null);
        vmConnectionDetailsStream
            .take(totalTestCount)
            .asyncMap(
              (details) => _collectFromVM(
                packagesRegExps: packagesRegExps,
                connectionDetails: details,
              ),
            )
            .listen(
          (coverage) {
            hitMap.merge(coverage);
            logger.info('Collected ${++count} / $totalTestCount coverages');
          },
        )
          ..onDone(coverageCollectionCompleter.complete)
          ..disposedBy(scope);
        await coverageCollectionCompleter.future;

        logger.info('All coverage gathered, saving');
        final report = hitMap.formatLcov(
          await coverage.Resolver.create(
            packagePath: _rootDirectory.path,
          ),
          ignoreGlobs: ignoreGlobs,
        );
        await _saveReport(report);
      },
    );
  }

  Future<int> _collectTotalTestCount(
    VMConnectionDetails connectionDetails,
  ) async {
    final serviceClient = await vmServiceConnectUri(
      connectionDetails.webSocketUri.toString(),
    );
    _disposeScope.addDispose(serviceClient.dispose);

    await serviceClient.streamListen('Extension');
    final completer = Completer<int>()..disposedBy(_disposeScope, 0);
    serviceClient.onExtensionEvent.listen((event) async {
      if (event.extensionKind == 'testCount') {
        completer.complete(event.extensionData!.data['testCount'] as int);
      }
    }).disposedBy(_disposeScope);

    final testCount = await completer.future;
    await serviceClient.dispose();

    return testCount;
  }

  Future<Map<String, coverage.HitMap>> _collectFromVM({
    required Set<RegExp> packagesRegExps,
    required VMConnectionDetails connectionDetails,
  }) async {
    final result = <String, coverage.HitMap>{};
    final coverageReadyForCollection = Completer<Event?>();
    final serviceClient = await vmServiceConnectUri(
      connectionDetails.webSocketUri.toString(),
    );
    _disposeScope.addDispose(serviceClient.dispose);

    await serviceClient.streamListen('Extension');
    unawaited(
      serviceClient.onDone.then((_) {
        if (!coverageReadyForCollection.isCompleted) {
          coverageReadyForCollection.complete(null);
        }
      }),
    );
    unawaited(
      serviceClient.onExtensionEvent
          .where((event) => event.extensionKind == 'waitForCoverageCollection')
          .first
          .then(coverageReadyForCollection.complete),
    );
    final event = await coverageReadyForCollection.future;
    if (event == null) {
      // If the event is null, then the VM service terminated without sending
      // the waitForCoverageCollection event. This means that the test was
      // skipped, so we don't need to collect coverage.
      return {};
    }

    result.merge(
      await _collectAndMarkTestCompleted(
        connectionDetails: connectionDetails,
        packagesRegExps: packagesRegExps,
        mainIsolateId: event.extensionData!.data['mainIsolateId'] as String,
      ),
    );
    await serviceClient.dispose();

    return result;
  }

  Future<Map<String, coverage.HitMap>> _collectAndMarkTestCompleted({
    required VMConnectionDetails connectionDetails,
    required Set<RegExp> packagesRegExps,
    required String mainIsolateId,
  }) async {
    final packages = await _getCoveragePackages(packagesRegExps);

    final data = await coverage.collect(
      connectionDetails.uri,
      false,
      false,
      false,
      packages,
    );

    final socket =
        await io.WebSocket.connect(connectionDetails.webSocketUri.toString())
          ..add(
            jsonEncode(
              {
                'jsonrpc': '2.0',
                'id': 21,
                'method': 'ext.patrol.markTestCompleted',
                'params': {
                  'isolateId': mainIsolateId,
                  'command': 'markTestCompleted',
                },
              },
            ),
          );
    await socket.close();

    return coverage.HitMap.parseJson(
      data['coverage'] as List<Map<String, dynamic>>,
    );
  }

  Future<void> _saveReport(String report) async {
    final coverageDirectory = _fs.directory('coverage');

    if (!coverageDirectory.existsSync()) {
      await coverageDirectory.create();
    }

    await coverageDirectory.childFile('patrol_lcov.info').writeAsString(report);
  }

  Future<Set<String>> _getCoveragePackages(Set<RegExp> packagesRegExps) async {
    final packageConfig = await loadPackageConfig(
      _rootDirectory
          .childDirectory('.dart_tool')
          .childFile('package_config.json'),
    );

    final packagesToInclude = {
      for (final regExp in packagesRegExps)
        ...packageConfig.packages.map((e) => e.name).where(regExp.hasMatch),
    };

    _logger.detail('Packages included in coverage: $packagesToInclude');

    return packagesToInclude;
  }
}

extension<T> on Completer<T> {
  void disposedBy(DisposeScope disposeScope, T disposeValue) {
    disposeScope.addDispose(() {
      if (!isCompleted) {
        complete(disposeValue);
      }
    });
  }
}
