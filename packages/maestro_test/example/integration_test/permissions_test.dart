import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  Future<void> requestAndGrantCameraPermission(MaestroTester $) async {
    await $(#requestCamera).tap(andSettle: false);
    await maestro.grantPermissionWhenInUse();
    await $.pumpAndSettle();
    expect($(#cameraStatusText).text, 'Granted: true');
  }

  Future<void> requestAndGrantMicrophonePermission(MaestroTester $) async {
    await $(#requestMicrophone).tap(andSettle: false);
    await maestro.grantPermissionWhenInUse();
    await $.pumpAndSettle();
    expect($(#microphoneStatusText).text, 'Granted: true');
  }

  maestroTest(
    'grants various permissions',
    config: maestroConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open permissions screen').tap();

      await requestAndGrantCameraPermission($);
      await requestAndGrantMicrophonePermission($);
    },
  );
}
