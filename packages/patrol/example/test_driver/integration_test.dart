import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test_driver.dart';

/// Copied from [integrationDriver].
Future<void> main() async {
  final driver = await FlutterDriver.connect();

  {
    print('vmServiceUrl: ${Platform.environment['VM_SERVICE_URL']}');

    // Call extension
    final vmService = driver.serviceClient;
    print('before callServiceExtension()');
    final currentIsolateId = Service.getIsolateID(Isolate.current)!;
    final serviceProtocolInfo = await Service.controlWebServer(enable: true);
    final serverHttpUri = serviceProtocolInfo.serverUri!;
    final serverWsUri = serviceProtocolInfo.serverWebSocketUri!;

    print('currentIsolateId: $currentIsolateId');
    print('serverUri: $serverHttpUri');
    print('serverWebSocketUri: ${serviceProtocolInfo.serverWebSocketUri}');
    await vmService.callServiceExtension(
      'ext.flutter.patrol',
      isolateId: driver.appIsolate.id,
      args: <String, String>{
        'DRIVER_ISOLATE_ID': currentIsolateId,
        'DRIVER_VM_SERVICE_WS_URI': serverWsUri.toString(),
        'DRIVER_VM_SERVICE_HTTP_URI': serverHttpUri.toString(),
      },
    );
    print('after callServiceExtension()');

    // Register our extension
    await vmService.registerService('ext.leancode.patrol.hello', 'Patrol');
    vmService.registerServiceCallback(
      'ext.leancode.patrol.hello',
      (args) async {
        return <String, String>{'MSG': 'Hello from driver!'};
      },
    );
  }

  final jsonResult = await driver.requestData(
    null,
    timeout: const Duration(minutes: 20),
  );
  final response = Response.fromJson(jsonResult);

  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');

    await writeResponseData(response.data);

    exit(0);
  } else {
    print('Failure Details:\n${response.formattedFailureDetails}');
    exit(1);
  }
}
