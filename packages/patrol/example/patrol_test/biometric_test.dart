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

    await $.platform.mobile.tap(Selector(text: 'Pass'));

    await $.pumpAndSettle();

    expect($('Authentication Successful'), findsOneWidget);
  });
}
