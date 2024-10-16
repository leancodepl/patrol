import '../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('grants various permissions', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndGrantLocationPermission($);
  });
  patrol('grants various permissions 2', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndGrantLocationPermission($);
  });
}

Future<void> _requestAndGrantCameraPermission(PatrolIntegrationTester $) async {
  expect($(#camera).$(#statusText).text, 'Not granted');
  await $('Request camera permission').tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionWhenInUse();
    await $.pump();
  }
}

Future<void> _requestAndGrantMicrophonePermission(
  PatrolIntegrationTester $,
) async {
  expect($(#microphone).$(#statusText).text, 'Not granted');
  await $('Request microphone permission').tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionOnlyThisTime();
    await $.pump();
  }
}

Future<void> _requestAndGrantLocationPermission(
  PatrolIntegrationTester $,
) async {
  expect($(#location).$(#statusText).text, 'Not granted');
  await $('Request location permission').tap();
  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionOnlyThisTime();
    await $.pump();
  }
}
