import 'common.dart';

void main() {
  group('example_test.dart', () {
    group('alpha', () {
      patrol('first', ($) async {
        await _testBody($);
      });
      patrol('Second', ($) async {
        await _testBody($);
      });
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
  await $.native.pressHome();
  await $.native.openApp();
}
