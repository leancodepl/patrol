import '../../common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('grants various permissions', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndDenyContactsPermission($);
    print('here 1');
  });
}

Future<void> _requestAndGrantCameraPermission(PatrolTester $) async {
  expect($(#camera).$(#statusText).text, 'Not granted');

  await $('Request camera permission').tap();

  final request = await $.native.isPermissionDialogVisible(timeout: _timeout);
  if (request) {
    await $.native.grantPermissionWhenInUse();
  }

  await $.pump();
  expect($(#camera).$(#statusText).text, 'Granted');
}

Future<void> _requestAndGrantMicrophonePermission(PatrolTester $) async {
  expect($(#microphone).$(#statusText).text, 'Not granted');

  await $('Request microphone permission').tap();

  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.grantPermissionWhenInUse();
  }

  await $.pump();
  expect($(#microphone).$(#statusText).text, 'Granted');
}

Future<void> _requestAndDenyContactsPermission(PatrolTester $) async {
  expect($(#contacts).$(#statusText).text, 'Not granted');

  await $('Request contacts permission').tap();

  if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
    await $.native.denyPermission();
  }

  await $.pump();
  expect($(#contacts).$(#statusText).text, 'Not granted');
}
