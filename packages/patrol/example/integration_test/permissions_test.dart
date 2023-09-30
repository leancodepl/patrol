import 'dart:async';
import 'dart:io' as io;

import 'package:permission_handler/permission_handler.dart';

import 'common.dart';

const _timeout = Duration(seconds: 5); // to avoid timeouts on CI

void main() {
  patrol('grants location permission only this time', ($) async {
    await createApp($);

    await $('Open location screen').scrollTo().tap();

    if (!await Permission.location.isGranted) {
      expect($('Permission not granted'), findsOneWidget);
      await $('Grant permission').tap();
      if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
        await $.native.selectCoarseLocation();
        await $.native.selectFineLocation();
        await $.native.selectCoarseLocation();
        await $.native.selectFineLocation();
        await $.native.grantPermissionOnlyThisTime();
      }
      await $.pump();

      await _dismissGoogleDialog($);
    }

    expect(await $(RegExp('lat')).waitUntilVisible(), findsOneWidget);
    expect(await $(RegExp('lng')).waitUntilVisible(), findsOneWidget);
  });

  patrol('grants camera permission when in use', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantCameraPermission($);
  });

  patrol('grants microphone permission only this time', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndGrantMicrophonePermission($);
  });

  patrol('denies contacts permission', ($) async {
    await createApp($);

    await $('Open permissions screen').scrollTo().tap();

    await _requestAndDenyContactsPermission($);
  });
}

Future<void> _requestAndGrantCameraPermission(PatrolTester $) async {
  if (!await Permission.camera.isGranted) {
    expect($(#camera).$(#statusText).text, 'Not granted');
    await $('Request camera permission').tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.grantPermissionWhenInUse();
      await $.pump();
    }
  }

  expect($(#camera).$(#statusText).text, 'Granted');
}

Future<void> _requestAndGrantMicrophonePermission(PatrolTester $) async {
  if (!await Permission.microphone.isGranted) {
    expect($(#microphone).$(#statusText).text, 'Not granted');
    await $('Request microphone permission').tap();
    if (await $.native.isPermissionDialogVisible(timeout: _timeout)) {
      await $.native.grantPermissionOnlyThisTime();
      await $.pump();
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
      await $.pump();
    }
  }

  expect($(#contacts).$(#statusText).text, 'Not granted');
}

// Firebase Test Lab pops out another dialog we need to handle
Future<void> _dismissGoogleDialog(PatrolTester $) async {
  if (!io.Platform.isAndroid) {
    return;
  }

  var okTexts = <NativeView>[];
  final inactivityTimer = Timer(Duration(seconds: 10), () {});

  while (okTexts.isEmpty) {
    okTexts = await $.native.getNativeViews(Selector(textContains: 'OK'));
    final timeoutReached = !inactivityTimer.isActive;
    if (timeoutReached) {
      inactivityTimer.cancel();
      break;
    }
  }
  if (okTexts.isNotEmpty) {
    await $.native.tap(Selector(text: 'OK'));
  }
}
