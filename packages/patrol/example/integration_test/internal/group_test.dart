import 'package:patrol/src/global_state.dart' as global_state;

import '../common.dart';

void main() {
  patrol('at the beginning', ($) async {
    await _testBody($);
  });

  group('top level group in file', () {
    group('alpha', () {
      patrol('first', ($) async {
        await _testBody($);
      });
      patrol('second', ($) async {
        await _testBody($);
      });
    });

    patrol('in the middle', ($) async {
      await _testBody($);
    });

    group('bravo', () {
      patrol('first', ($) async {
        await _testBody($);
      });
      patrol('second', ($) async {
        await _testBody($);
      });
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
