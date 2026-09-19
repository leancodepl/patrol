import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/develop_view_assertion.dart';

void main() {
  group('isDisposedViewAssertion', () {
    test('matches the engine assertion, however it is wrapped', () {
      expect(
        isDisposedViewAssertion(
          'Assertion failed: org-dartlang-sdk:///lib/_engine/engine/window.dart'
          ':99:12\n!isDisposed\n"Trying to render a disposed '
          'EngineFlutterView."',
        ),
        isTrue,
      );
      expect(
        isDisposedViewAssertion(
          FlutterError('Trying to render a disposed EngineFlutterView.'),
        ),
        isTrue,
      );
    });

    test('leaves other failures alone', () {
      expect(
        isDisposedViewAssertion('Expected: exactly one matching'),
        isFalse,
      );
      expect(isDisposedViewAssertion(TestFailure('nope')), isFalse);
      expect(isDisposedViewAssertion(null), isFalse);
    });
  });
}
