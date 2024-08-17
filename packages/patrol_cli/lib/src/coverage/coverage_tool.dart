import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adb/adb.dart';
import 'package:coverage/coverage.dart';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/coverage/device_to_host_port_transformer.dart';
import 'package:patrol_cli/src/coverage/vm_connection_details.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:process/process.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

class CoverageTool {
  CoverageTool({
    required FileSystem fs,
    required ProcessManager processManager,
    required Adb adb,
    required DisposeScope parentDisposeScope,
  })  : _fs = fs,
        _processManager = processManager,
        _adb = adb,
        _disposeScope = DisposeScope() {
    _disposeScope.disposedBy(parentDisposeScope);
  }

  final FileSystem _fs;
  final ProcessManager _processManager;
  final Adb _adb;
  final DisposeScope _disposeScope;

  Future<void> run({
    required String flutterPackageName,
    required TargetPlatform platform,
    required Logger logger,
    required Set<Glob> ignoreGlobs,
  }) async {
    final homeDirectory =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    final hitMap = <String, HitMap>{};

    await _disposeScope.run(
      (scope) async {
        final logsProcess = await _processManager.start(
          ['flutter', 'logs'],
          workingDirectory: homeDirectory,
          runInShell: true,
        )
          ..disposedBy(scope);

        final vmConnectionDetailsStream = logsProcess.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .map(VMConnectionDetails.tryExtractFromLogs)
            .whereNotNull()
            .transform(
              DeviceToHostPortTransformer(
                processManager: _processManager,
                devicePlatform: platform,
                adb: _adb,
                logger: logger,
              ),
            )
            .whereNotNull()
            .asBroadcastStream();

        final totalTestCount = await vmConnectionDetailsStream
            .asyncMap(_collectTotalTestCount)
            .first;
        logger.info('Total test count: $totalTestCount');

        var count = 0;
        final coverageCollectionCompleter = Completer<void>()
          ..disposedBy(
            scope,
            null,
          );
        vmConnectionDetailsStream
            .take(totalTestCount)
            .asyncMap(
              (details) => _collectFromVM(
                flutterPackageName: flutterPackageName,
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
          await Resolver.create(packagePath: _fs.currentDirectory.path),
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

  Future<Map<String, HitMap>> _collectFromVM({
    required String flutterPackageName,
    required VMConnectionDetails connectionDetails,
  }) async {
    final result = <String, HitMap>{};
    final serviceClient = await vmServiceConnectUri(
      connectionDetails.webSocketUri.toString(),
    );
    _disposeScope.addDispose(serviceClient.dispose);
    await serviceClient.setFlag('pause_isolates_on_exit', 'true');

    await serviceClient.streamListen(EventStreams.kIsolate);
    serviceClient.onIsolateEvent.listen(
      (event) async {
        if (event.kind == EventKind.kIsolateRunnable) {
          final isolateCoverage = await collect(
            connectionDetails.uri,
            true,
            false,
            false,
            {flutterPackageName},
            isolateIds: {event.isolate!.id!},
          );
          result.merge(
            await HitMap.parseJson(
              isolateCoverage['coverage'] as List<Map<String, dynamic>>,
            ),
          );
        }
      },
    ).disposedBy(_disposeScope);

    await serviceClient.streamListen('Extension');
    final event = await serviceClient.onExtensionEvent
        .where((event) => event.extensionKind == 'waitForCoverageCollection')
        .first;
    result.merge(
      await _collectAndMarkTestCompleted(
        connectionDetails: connectionDetails,
        packageName: flutterPackageName,
        mainIsolateId: event.extensionData!.data['mainIsolateId'] as String,
      ),
    );
    await serviceClient.dispose();

    return result;
  }

  Future<Map<String, HitMap>> _collectAndMarkTestCompleted({
    required VMConnectionDetails connectionDetails,
    required String packageName,
    required String mainIsolateId,
  }) async {
    final coverage = await collect(
      connectionDetails.uri,
      false,
      false,
      false,
      {packageName},
    );

    final socket =
        await WebSocket.connect(connectionDetails.webSocketUri.toString())
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

    return HitMap.parseJson(
      coverage['coverage'] as List<Map<String, dynamic>>,
    );
  }

  Future<void> _saveReport(String report) async {
    final coverageDirectory = _fs.directory('coverage');

    if (!coverageDirectory.existsSync()) {
      await coverageDirectory.create();
    }

    await coverageDirectory.childFile('patrol_lcov.info').writeAsString(report);
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
