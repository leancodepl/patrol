import 'package:e2e_app/keys.dart';

import '../native_tests/common.dart';

// Enrolls a fingerprint on the emulator before a biometric test.
// The patrol CLI pushes the emulator auth token automatically — no manual setup needed.
Future<void> _enrollBiometric(PatrolIntegrationTester $) =>
    $.platform.android.enrollBiometricOnEmulator();

void main() {
  patrol('biometric authentication succeeds', ($) async {
    await _enrollBiometric($);
    await createApp($);

    await $(K.biometricScreenButton).scrollTo().tap();

    expect($(K.biometricStatusText).text, 'Not authenticated');

    await $(K.biometricAuthenticateButton).tap();

    await $.platform.android.performBiometricAuthentication(success: true);

    // The authentication result arrives via an async platform-channel callback,
    // so wait for the status to reflect it instead of asserting immediately —
    // asserting right after pumpAndSettle races the callback and flakes.
    await $(
      'Authenticated',
    ).waitUntilVisible(timeout: const Duration(seconds: 30));
    expect($(K.biometricStatusText).text, 'Authenticated');
  }, tags: ['local']);
}
