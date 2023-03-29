import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('grants various permissions', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
    await _requestAndGrantMicrophonePermission($);
    await _requestAndDenyContactsPermission($);
  });
}

Future<void> _requestAndGrantCameraPermission(PatrolTester $) async {
  if (!await Permission.camera.isGranted) {
    expect($(#camera).$(#statusText).text, 'Not granted');
    await $('Request camera permission').tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.grantPermissionWhenInUse();
      await $.pumpAndSettle(duration: _timeout);
    }
  }

  expect($(#camera).$(#statusText).text, 'Granted');
}

Future<void> _requestAndGrantMicrophonePermission(PatrolTester $) async {
  if (!await Permission.microphone.isGranted) {
    expect($(#microphone).$(#statusText).text, 'Not granted');
    await $('Request microphone permission').tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.grantPermissionWhenInUse();
      await $.pumpAndSettle(duration: _timeout);
    }
  }

  expect($(#microphone).$(#statusText).text, 'Granted');
}

Future<void> _requestAndDenyContactsPermission(PatrolTester $) async {
  if (!await Permission.contacts.isGranted) {
    expect($(#contacts).$(#statusText).text, 'Not granted');
    await $('Request contacts permission').tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.denyPermission();
      await $.pumpAndSettle(duration: _timeout);
    }
  }

  expect($(#contacts).$(#statusText).text, 'Not granted');
}
