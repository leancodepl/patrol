// Biometric authentication happy-path test for BrowserStack.
//
// BrowserStack deployment notes:
// - Upload with `enableBiometric: true` to activate sensor instrumentation.
// - Set `singleRunnerInvocation: true` for Patrol on BrowserStack.

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('biometric authentication happy path', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    await $('Authenticate with Biometrics').tap();

    await $('Authenticate').tap();

    await $.pump(const Duration(seconds: 1));

    // final views = await $.platform.android.getNativeViews(
    //   AndroidSelector(textContains: 'PASS'),
    // );
    // print(views.toJson());

    await $.platform.mobile.tap(
      PlatformSelector(
        // It's not possible perform a tap using a `text` or `textContains` selector on Android on the BS dialog for some reason
        // so we need to use the resourceName of the button found using the commented out code above.
        android: AndroidSelector(resourceName: 'android:id/button1'),
        ios: IOSSelector(text: 'Pass'),
      ),
    );

    await $.pump(const Duration(seconds: 1));

    expect($('Authentication Successful'), findsOneWidget);
  });
}
