// The biometrics API is experimental.
// ignore_for_file: experimental_member_use, unnecessary_ignore

import 'common.dart';

// Needs an iOS simulator run by `patrol test` or an Android 12+ device.
void main() {
  patrol('authenticates with a simulated biometric', ($) async {
    await createApp($);

    try {
      // Inside the try, so a half-done enrollment is cleaned up too.
      await $.platform.mobile.enrollBiometrics();

      await $('Open biometrics screen').scrollTo().tap();

      await $('Check enrollment').tap();
      expect($(#biometricsStatus).text, startsWith('Enrolled'));

      // On iOS, the first prompt waits for the Face ID permission alert, which
      // the reject below taps through.
      await $('Authenticate').tap();

      // A face that doesn't match keeps the prompt open for another try. If
      // the prompt isn't up yet, the reject is lost, which this can't tell.
      await Future<void>.delayed(const Duration(seconds: 2));
      await $.platform.mobile.rejectBiometricAuthentication();
      expect($(#biometricsStatus).text, 'Authenticating');

      await _acceptUntilAuthenticated($);
    } finally {
      await $.platform.mobile.unenrollBiometrics();
    }
  }, tags: ['android', 'ios', 'biometrics']);
}

// A match sent before the system prompt waits for one is lost, and the prompt
// takes a while to animate in, so retry until the app sees the result.
Future<void> _acceptUntilAuthenticated(PatrolIntegrationTester $) async {
  const attempts = 5;
  for (var attempt = 1; ; attempt++) {
    await $.platform.mobile.acceptBiometricAuthentication();
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
