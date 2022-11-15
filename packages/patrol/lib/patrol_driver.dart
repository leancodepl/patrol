// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io' as io;

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test_driver.dart';
import 'package:path/path.dart' show join;
import 'package:vm_service/vm_service.dart' as vm;

/// Adaptation of [integrationDriver] for Patrol's host-side capabilities.
///
/// Depends on `DRIVER_DEVICE_ID` and `DRIVER_DEVICE_OS` env variables to be
/// set. They're automatically set by `patrol drive`, but can also be set
/// manually.
Future<void> patrolIntegrationDriver({
  Duration timeout = const Duration(minutes: 20),
  ResponseDataCallback? responseDataCallback = writeResponseData,
}) async {
  final driver = await FlutterDriver.connect();

  await _initCommunication(
    vmService: driver.serviceClient,
    isolateId: driver.appIsolate.id!,
  );

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

Future<void> _initCommunication({
  required vm.VmService vmService,
  required String isolateId,
}) async {
  await vmService.streamListen('Extension');
  vmService.onEvent('Extension').listen((event) {
    if (event.extensionKind != 'patrol') {
      return;
    }

    final method = event.extensionData!.data['method'] as String;
    final requestId = event.extensionData!.data['request_id'] as int;
    switch (method) {
      case 'take_screenshot':
        bool status;
        try {
          _takeScreenshot(
            event.extensionData!.data['args'] as Map<String, dynamic>,
          );
          status = true;
        } catch (err) {
          status = false;
        }

        vmService.callServiceExtension(
          'ext.flutter.patrol',
          isolateId: isolateId,
          args: <String, dynamic>{'request_id': requestId, 'status': status},
        );
        break;
      default:
        throw StateError('unknown method $method');
    }
  });
}

void _takeScreenshot(Map<String, dynamic> args) {
  final deviceId = io.Platform.environment['DRIVER_DEVICE_ID'];
  if (deviceId == null || deviceId.isEmpty) {
    print('Error: DRIVER_DEVICE_ID is not set');
    io.exit(1);
  }

  final deviceOs = io.Platform.environment['DRIVER_DEVICE_OS'];
  if (deviceOs == null || deviceOs.isEmpty) {
    print('Error: DRIVER_DEVICE_OS is not set');
    io.exit(1);
  }

  final screenshotName = args['name'] as String?;
  if (screenshotName == null) {
    throw StateError('screenshot name is null');
  }

  final screenshotPath = args['path'] as String?;
  if (screenshotPath == null) {
    throw StateError('screenshot path is null');
  }

  final screenshotDir = io.Directory(screenshotPath);
  if (!screenshotDir.existsSync()) {
    screenshotDir.createSync(recursive: true);
  }

  final proccessResult = io.Process.runSync(
    'flutter',
    [
      ...['--device-id', deviceId],
      'screenshot',
      ...['--out', join(screenshotPath, '$screenshotName.png')],
    ],
    runInShell: true,
  );

  final exitCode = proccessResult.exitCode;
  if (exitCode != 0) {
    throw StateError('flutter screenshot exited with code $exitCode');
  }
}
