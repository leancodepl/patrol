// The biometrics API is experimental.
// ignore_for_file: experimental_member_use, unnecessary_ignore

import 'common.dart';

// Needs an iOS simulator run by `patrol test` or an Android 12+ device.
void main() {
  patrol('passes a simulated biometric', ($) async {
    await createApp($);

    try {
      // Inside the try, so a half-done enrollment is cleaned up too.
      await $.platform.mobile.enrollBiometrics();

      await $('Open biometrics screen').scrollTo().tap();

      await $('Check enrollment').tap();
      expect($(#biometricsStatus).text, startsWith('Enrolled'));

      // On iOS, the first prompt waits for the Face ID permission alert, which
      // the fail below taps through.
      await $('Authenticate').tap();

      // A face that doesn't match keeps the prompt open for another try. If
      // the prompt isn't up yet, the fail is lost, which this can't tell.
      await _waitForPrompt();
      await $.platform.mobile.failBiometric();
      expect($(#biometricsStatus).text, 'Authenticating');

      await _passUntilAuthenticated($);
    } finally {
      await $.platform.mobile.unenrollBiometrics();
    }
  }, tags: ['android', 'ios', 'biometrics']);

  patrol('cancels a biometric prompt', ($) async {
    await createApp($);

    try {
      await $.platform.mobile.enrollBiometrics();

      await $('Open biometrics screen').scrollTo().tap();
      await $('Authenticate').tap();

      await _waitForPrompt();
      await $.platform.mobile.cancelBiometric();
      await $('Error: userCanceled').waitUntilVisible();
    } finally {
      await $.platform.mobile.unenrollBiometrics();
    }
  }, tags: ['android', 'ios', 'biometrics']);
}

// The system prompt animates in, and ignores a biometric sent before it.
Future<void> _waitForPrompt() {
  return Future<void>.delayed(const Duration(seconds: 2));
}

// The prompt can take longer than _waitForPrompt to animate in, so retry until
// the app sees the result.
Future<void> _passUntilAuthenticated(PatrolIntegrationTester $) async {
  const attempts = 5;
  for (var attempt = 1; ; attempt++) {
    await $.platform.mobile.passBiometric();
    try {
      await $(
        'Authenticated',
      ).waitUntilVisible(timeout: const Duration(seconds: 2));
      return;
    } on WaitUntilVisibleTimeoutException {
      if (attempt == attempts) {
        rethrow;
      }
    }
  }
}
