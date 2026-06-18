import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('QR scanner with injected QR code on BrowserStack', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    // The image with the specified name must have been uploaded to BrowserStack
    // and included in the cameraInjectionMedia capability.
    await $.platform.ios.injectCameraPhoto(imageName: 'hello_patrol_qr.png');

    await $('Scan QR code').tap();

    if (await $.platform.mobile.isPermissionDialogVisible()) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    expect($('Hello Patrol!'), findsNothing);
    expect($('No QR code detected'), findsOneWidget);

    // Wait for camera to initialize, then feed the injected image
    await $.pump(const Duration(seconds: 2));
    await $.platform.ios.feedInjectedImageToViewfinder();
    await $.pump(const Duration(seconds: 1));

    expect($('Hello Patrol!'), findsOneWidget);
    expect($('No QR code detected'), findsNothing);
  });
}
