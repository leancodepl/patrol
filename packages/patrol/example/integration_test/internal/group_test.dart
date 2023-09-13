import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

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

Future<void> _testBody(PatrolTester $) async {
  await createApp($);

  final testName = Invoker.current!.fullCurrentTestName();
  await $(#textField).enterText(testName);

  await $.native.pressHome();
  await $.native.openApp();
}
