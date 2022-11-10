import 'dart:async';
import 'dart:developer' as developer;
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
    final currentIsolateId = developer.Service.getIsolateID(Isolate.current)!;
    final serviceProtocolInfo =
        await developer.Service.controlWebServer(enable: true);
    final serverHttpUri = serviceProtocolInfo.serverUri!;
    final serverWsUri = serviceProtocolInfo.serverWebSocketUri!;

    print('currentIsolateId: $currentIsolateId');
    print('serverHttpUri: $serverHttpUri');
    print('serverWsUri: $serverWsUri, port: ${serverWsUri.port}');

    Process.runSync(
      'adb',
      ['reverse', 'tcp:2137', 'tcp:${serverWsUri.port}'],
      runInShell: true,
    );

    await vmService.callServiceExtension(
      'ext.flutter.patrol',
      isolateId: driver.appIsolate.id,
      args: <String, String>{
        'DRIVER_ISOLATE_ID': currentIsolateId,
        'DRIVER_VM_SERVICE_WS_URI': serverWsUri.replace(port: 2137).toString(),
        'DRIVER_VM_SERVICE_HTTP_URI':
            serverHttpUri.replace(port: 2137).toString(),
      },
    );
    print('after callServiceExtension()');
    developer.registerExtension(
      'ext.leancode.patrol.hello',
      (method, args) async {
        print('HELLO');
        print('Here I am, the avenger of flakiness, called with $args');
        return developer.ServiceExtensionResponse.result('{"STATUS": 200}');
      },
    );

    /* await vmService.registerService('ext.leancode.patrol.hello', 'Patrol');
    vmService.registerServiceCallback(
      'ext.leancode.patrol.hello',
      (args) async {
        return <String, String>{'MSG': 'Hello from driver!'};
      },
    ); */
    print('registered extension');
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
