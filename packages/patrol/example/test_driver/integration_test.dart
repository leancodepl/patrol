import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test_driver.dart';

/// Copied from [integrationDriver].
Future<void> main() async {
  final driver = await FlutterDriver.connect();
  final vmServiceUrl = Platform.environment['VM_SERVICE_URL']!;
  print('vmServiceUrl: $vmServiceUrl');

  final vmService = driver.serviceClient;

  print('before callServiceExtension()');
  await vmService.callServiceExtension(
    'ext.flutter.patrol',
    isolateId: driver.appIsolate.id,
  );
  print('after callServiceExtension()');

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
