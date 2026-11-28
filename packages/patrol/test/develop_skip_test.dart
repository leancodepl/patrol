import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/common.dart' show skipsInBody;

void main() {
  group('skipsInBody()', () {
    test('runs the body of a skipped test in develop mode', () {
      expect(skipsInBody(skip: true, hotRestart: true), isTrue);
    });

    test('leaves a skipped test to the test runner outside develop mode', () {
      expect(skipsInBody(skip: true, hotRestart: false), isFalse);
    });

    test('leaves a test that is not skipped alone', () {
      expect(skipsInBody(skip: false, hotRestart: true), isFalse);
      expect(skipsInBody(skip: null, hotRestart: true), isFalse);
    });
  });
}
