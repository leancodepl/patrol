// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' as io;
import 'dart:isolate';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test_driver.dart';
import 'package:path/path.dart' show join;

/// Adaptation of [integrationDriver] for Patrol's host-side capabilities.
Future<void> patrolIntegrationDriver({
  Duration timeout = const Duration(minutes: 20),
  ResponseDataCallback? responseDataCallback = writeResponseData,
}) async {
  final driver = await FlutterDriver.connect();

  await _initCommunication(driver);

  final jsonResult = await driver.requestData(null, timeout: timeout);
  final response = Response.fromJson(jsonResult);

  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');
    if (responseDataCallback != null) {
      await responseDataCallback(response.data);
    }
    io.exit(0);
  } else {
    print('Failure Details:\n${response.formattedFailureDetails}');
    io.exit(1);
  }
}

/// Performs Patrol-specific setup to enable bidirectional communication between
/// this test driver file (running on host) and the test target file (running on
/// device).
Future<void> _initCommunication(FlutterDriver driver) async {
  {
    // Call extension
    final info = await developer.Service.controlWebServer(enable: true);
    final serverWsUri = info.serverWebSocketUri!;

    // TODO: Forward with adb only if running on Android
    io.Process.runSync(
      'adb',
      // TODO: What's the chance of host port being taken?
      ['reverse', 'tcp:${serverWsUri.port}', 'tcp:${serverWsUri.port}'],
      runInShell: true,
    );
    // TODO: forward with iproxy if running on physical iOS device

    await driver.serviceClient.callServiceExtension(
      'ext.flutter.patrol',
      isolateId: driver.appIsolate.id,
      args: <String, String>{
        'DRIVER_ISOLATE_ID': developer.Service.getIsolateID(Isolate.current)!,
        'DRIVER_VM_SERVICE_WS_URI': serverWsUri.toString(),
      },
    );

    developer.registerExtension(
      'ext.leancode.patrol.status',
      (method, args) async {
        print('Here I am, the avenger of flakiness, called with $args');
        return developer.ServiceExtensionResponse.result(
          jsonEncode({'method': method, 'status': 'ok'}),
        );
      },
    );

    developer.registerExtension(
      'ext.leancode.patrol.screenshot',
      (method, parameters) async {
        final screenshotName = parameters['name'];
        if (screenshotName == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'screenshot name is null',
          );
        }

        final screenshotPath = parameters['path'];
        if (screenshotPath == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'screenshot path is null',
          );
        }

        final screenshotDir = io.Directory(screenshotPath);
        if (!screenshotDir.existsSync()) {
          screenshotDir.createSync(recursive: true);
        }

        final proccessResult = await io.Process.run(
          'flutter',
          ['screenshot', '--out', join(screenshotPath, '$screenshotName.png')],
          runInShell: true,
        );

        final exitCode = proccessResult.exitCode;
        if (exitCode != 0) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.extensionError,
            'flutter screenshot exited with exit code $exitCode',
          );
        }

        return developer.ServiceExtensionResponse.result(
          jsonEncode({'method': method}),
        );
      },
    );
  }
}
