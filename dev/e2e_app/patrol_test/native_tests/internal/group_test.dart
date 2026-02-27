// We want to keep tests on deprecated APIs.
// ignore_for_file: deprecated_member_use

import 'package:patrol/src/global_state.dart' as global_state;

import '../common.dart';

void main() {
  patrol(
    'at the beginning',
    ($) async {
      await _testBody($);
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );

  group('top level group in file', () {
    group('alpha', () {
      patrol(
        'first',
        ($) async {
          await _testBody($);
        },
        tags: ['android', 'emulator', 'ios', 'simulator'],
      );
      patrol(
        'second',
        ($) async {
          await _testBody($);
        },
        tags: ['android', 'emulator', 'ios', 'simulator'],
      );
    });

    patrol(
      'in the middle',
      ($) async {
        await _testBody($);
      },
      tags: ['android', 'emulator', 'ios', 'simulator'],
    );

    group('bravo', () {
      patrol(
        'first',
        ($) async {
          await _testBody($);
        },
        tags: ['android', 'emulator', 'ios', 'simulator'],
      );
      patrol(
        'second',
        ($) async {
          await _testBody($);
        },
        tags: ['android', 'emulator', 'ios', 'simulator'],
      );
    });
  });
}

Future<void> _testBody(PatrolIntegrationTester $) async {
  await createApp($);

  final testName = global_state.currentTestFullName;
  await $(#textField).enterText(testName);

  await $.native.pressHome();
  await $.native.openApp();
}
