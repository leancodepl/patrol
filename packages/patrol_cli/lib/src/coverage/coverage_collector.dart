import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coverage/coverage.dart';
import 'package:glob/glob.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

Future<ProcessResult> forwardPort(String host, String guest) async {
  return Process.run('adb', ['forward', 'tcp:$host', 'tcp:$guest']);
}

Future<Map<String, HitMap>> collectCoverage(
  VmService client,
  Uri vmUri,
  String packageName,
  String mainIsolateId,
  Logger logger,
) async {
  final vm = await client.getVM();

  for (final isolate in vm.isolates!) {
    try {
      await client.pause(isolate.id!);
    } catch (err) {
      logger.err('$err');
    }

    // print('Version ${await client.getVersion()}');
    // final scripts = await client.getScripts(isolate.id!);
    //
    // for (final script in scripts.scripts!) {
    //   final uri = Uri.parse(script.uri!);
    //   final scope = uri.path.split('/').first;
    //
    //   print('$uri, scope = $scope');
    // }
  }

  // the isolates might not be paused yet (see docs of [serviceClient.pause])
  // but it most likely doesn't matter (isolates do not need to be paused
  // to collect coverage successfuly)

  final coverage = await collect(
    vmUri,
    false,
    false,
    false,
    {packageName},
  );

  // TODO: Check if it's possible that the isolates have not been paused yet
  // and they get paused after `resume` requests or is it a queue
  for (final isolate in vm.isolates!) {
    try {
      await client.resume(isolate.id!);
    } catch (err) {
      logger.err('$err');
    }
  }

  try {
    final socket = await WebSocket.connect(client.wsUri!);
    socket.add(
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
  } catch (err) {
    logger.err('$err');
  }

  final map = await HitMap.parseJson(
    coverage['coverage'] as List<Map<String, dynamic>>,
    // TODO: This should probably be passed as a command line arg
    checkIgnoredLines: true,
  );

  return map;
}

Future<void> runCodeCoverage({
  required String flutterPackageName,
  required Directory flutterPackageDirectory,
  required TargetPlatform platform,
  required Logger logger,
}) async {
  final homeDirectory =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

  final logsProcess = await Process.start(
    'flutter',
    ['logs'],
    workingDirectory: homeDirectory,
  );
  final vmRegex = RegExp('listening on (http.+)');

  final hitmap = <String, HitMap>{};
  String? collectUri;
  int? totalTestCount;
  var count = 0;

  logsProcess.stdout.transform(utf8.decoder).listen(
    (line) async {
      final vmLink = vmRegex.firstMatch(line)?.group(1);

      if (vmLink == null) {
        return;
      }

      final port = RegExp(':([0-9]+)/').firstMatch(vmLink)!.group(1)!;
      final auth = RegExp(':$port/(.+)').firstMatch(vmLink)!.group(1);

      final String? hostPort;

      switch (platform) {
        case TargetPlatform.android:
          await forwardPort('61011', port);

          // It might be necessary to grab the port from adb forward --list because
          // if debugger was attached, the port might be different from the one we set
          final forwardList = await Process.run('adb', ['forward', '--list']);
          final output = forwardList.stdout as String;
          hostPort =
              RegExp('tcp:([0-9]+) tcp:$port').firstMatch(output)?.group(1);
        case TargetPlatform.iOS || TargetPlatform.macOS:
          hostPort = port;
        default:
          hostPort = null;
      }

      if (hostPort != null) {
        collectUri = 'http://127.0.0.1:$hostPort/$auth';
        final uri = Uri.parse(collectUri!); // TODO: Do not use !
        final pathSegments =
            uri.pathSegments.where((c) => c.isNotEmpty).toList()..add('ws');
        final replaced = uri.replace(scheme: 'ws', pathSegments: pathSegments);
        final serviceClient = await vmServiceConnectUri(replaced.toString());

        await serviceClient.streamListen('Extension');

        serviceClient.onExtensionEvent.listen(
          (event) async {
            if (event.extensionKind == 'testCount' && totalTestCount == null) {
              // This is the initial run that patrol makes to learn the structure of
              // the tests (workaround for https://github.com/dart-lang/test/issues/1998)
              totalTestCount = event.extensionData!.data['testCount'] as int;
              print('Total test count is $totalTestCount');
            }

            if (event.extensionKind == 'waitForCoverageCollection') {
              if (totalTestCount == null) {
                // TODO: Handle? this should not happen
              }

              hitmap.merge(
                await collectCoverage(
                  serviceClient,
                  uri,
                  flutterPackageName,
                  event.extensionData!.data['mainIsolateId'] as String,
                  logger,
                ),
              );
              await serviceClient.dispose();

              logger.info('Collected ${++count} / $totalTestCount coverages');

              if (count == totalTestCount) {
                logsProcess.kill();

                logger.info('All coverage gathered, saving');
                final formatted = hitmap.formatLcov(
                  await Resolver.create(
                    packagePath: flutterPackageDirectory.path,
                  ),
                  // TODO: allow passing globs through command line args / yaml
                  // config
                  ignoreGlobs: {Glob('**/*.g.dart')},
                );

                final coverageDirectory = Directory('coverage');

                if (!coverageDirectory.existsSync()) {
                  await coverageDirectory.create();
                }

                await File(
                  coverageDirectory.uri.resolve('patrol_lcov.info').toString(),
                ).writeAsString(formatted);
              }
            }
          },
        );
      } else {
        logger.err('Port forwarding failed');
      }
    },
  );
}
