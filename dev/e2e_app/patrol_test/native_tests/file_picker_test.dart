import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'common.dart';

/// Creates a file the picker will show under On My iPhone > Example
/// (the app's Documents folder, exposed via `UIFileSharingEnabled`).
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

    // The picker is a system view, but it belongs to the app under test,
    // so the default appId drives it.
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

      // This id shows up in the picker's element identifiers, but it's a file
      // provider extension XCTest can't attach to. Patrol must fail fast
      // instead of hanging (#2790).
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
