// The biometrics API is experimental.
// ignore_for_file: experimental_member_use, unnecessary_ignore

import 'dart:io';

import 'common.dart';

// Needs an iOS simulator run by `patrol test` or an Android 11+ device.
void main() {
  patrol('authenticates with a simulated biometric', ($) async {
    await createApp($);
    await $.platform.mobile.enrollBiometrics();

    try {
      await $('Open biometrics screen').scrollTo().tap();

      await $('Check enrollment').tap();
      expect($(#biometricsStatus).text, startsWith('Enrolled'));

      await $('Authenticate').tap();
      if (Platform.isIOS &&
          await $.platform.mobile.isPermissionDialogVisible(
            timeout: const Duration(seconds: 5),
          )) {
        // Face ID asks for NSFaceIDUsageDescription the first time.
        await $.platform.mobile.grantPermissionWhenInUse();
      }
      await _waitForPrompt($);

      // A face that doesn't match keeps the prompt open for another try.
      await $.platform.mobile.rejectBiometricAuthentication();
      await _waitForPrompt($);
      expect($(#biometricsStatus).text, 'Authenticating');

      await $.platform.mobile.acceptBiometricAuthentication();
      await $('Authenticated').waitUntilVisible();
    } finally {
      await $.platform.mobile.unenrollBiometrics();
    }
  }, tags: ['android', 'ios', 'biometrics']);
}

// The system prompt animates in; a match sent before it waits is lost.
Future<void> _waitForPrompt(PatrolIntegrationTester $) {
  return Future<void>.delayed(const Duration(seconds: 2));
}
