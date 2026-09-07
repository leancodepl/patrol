import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'common.dart';

/// Puts a file in the app's Documents directory. Thanks to
/// `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` in the
/// Info.plist, it shows up in the native file picker under
/// On My iPhone > Example, which gives the test a folder and a file to
/// navigate to. The test body runs in the app process, so it writes to the
/// app's own sandbox.
Future<File> _createTestFile() async {
  final documents = await getApplicationDocumentsDirectory();

  return File('${documents.path}/patrol_test_file.txt')
    ..writeAsStringSync('patrol');
}

void main() {
  patrol('picks a file from the iOS file picker', ($) async {
    await createApp($);

    final file = await _createTestFile();
    $.log('created ${file.path}, exists=${file.existsSync()}');

    await $(#filePickerScreenButton).scrollTo().tap();
    await $(#pickFileButton).tap();

    // The picker opens on the Recents tab; go to Browse > On My iPhone >
    // Example (the app's Documents folder) and pick the test file. The picker
    // is a system view, but it lives in the app under test's view hierarchy,
    // so it's driven with the default appId.
    await $.platform.ios.tap(IOSSelector(label: 'Browse'));
    await $.platform.ios.tap(IOSSelector(labelContains: 'On My iPhone'));
    await $.platform.ios.tap(IOSSelector(labelContains: 'Example'));
    await $.platform.ios.tap(IOSSelector(labelContains: 'patrol_test_file'));

    await $.waitUntilVisible($('picked: patrol_test_file.txt'));
  }, tags: ['ios', 'simulator']);

  patrol(
    'fails gracefully when tapping via an unattachable appId',
    ($) async {
      await createApp($);

      await $(#filePickerScreenButton).scrollTo().tap();
      await $(#pickFileButton).tap();

      await $.platform.ios.waitUntilVisible(IOSSelector(label: 'Browse'));

      // com.apple.FileProvider.LocalStorage shows up in element identifiers of
      // the file picker, so users mistake it for the appId owning the picker.
      // It's a file provider extension, not an app, and XCTest can't attach to
      // it - Patrol must fail fast with an explanation instead of hanging for
      // over a minute and timing out
      // (https://github.com/leancodepl/patrol/issues/2790).
      await expectLater(
        $.platform.ios.tap(
          IOSSelector(labelContains: 'On My iPhone'),
          appId: 'com.apple.FileProvider.LocalStorage',
          timeout: const Duration(seconds: 3),
        ),
        throwsA(
          isA<PatrolActionException>().having(
            (err) => '$err',
            'message',
            contains('cannot be interacted with'),
          ),
        ),
      );

      // Springboard is always running, so it must pass the running-app check
      // and fail on the selector instead.
      await expectLater(
        $.platform.ios.tap(
          IOSSelector(label: 'ThisViewDoesNotExist'),
          appId: 'com.apple.springboard',
          timeout: const Duration(seconds: 2),
        ),
        throwsA(
          isA<PatrolActionException>().having(
            (err) => '$err',
            'message',
            contains("doesn't exist"),
          ),
        ),
      );

      // The automator server must survive the failed calls.
      await $.platform.ios.tap(IOSSelector(label: 'Cancel'));

      await $.waitUntilVisible($('cancelled'));
    },
    tags: ['ios', 'simulator'],
  );
}
