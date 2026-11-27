import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/common.dart' show runWithDeterministicCursor;

Widget _focusedIosTextField() {
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.iOS),
    home: const Scaffold(body: TextField(autofocus: true)),
  );
}

/// Pumps for a few blink periods and tells whether a ticker kept running
/// after the focus animations ended.
Future<bool> _cursorAnimates(WidgetTester tester) async {
  var animating = false;
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (i >= 10) {
      animating |= tester.binding.transientCallbackCount > 0;
    }
  }
  return animating;
}

void main() {
  group('runWithDeterministicCursor()', () {
    testWidgets('stops the iOS cursor animation', (tester) async {
      await runWithDeterministicCursor(
        enabled: true,
        body: () async {
          await tester.pumpWidget(_focusedIosTextField());

          expect(await _cursorAnimates(tester), isFalse);
        },
      );
    });

    testWidgets('keeps the iOS cursor animating when disabled', (tester) async {
      await runWithDeterministicCursor(
        enabled: false,
        body: () async {
          await tester.pumpWidget(_focusedIosTextField());

          expect(await _cursorAnimates(tester), isTrue);
        },
      );
    });

    test('restores the previous value', () async {
      expect(EditableText.debugDeterministicCursor, isFalse);

      await runWithDeterministicCursor(
        enabled: true,
        body: () async {
          expect(EditableText.debugDeterministicCursor, isTrue);
        },
      );

      expect(EditableText.debugDeterministicCursor, isFalse);
    });

    test('restores the previous value when the body throws', () async {
      await expectLater(
        runWithDeterministicCursor(
          enabled: true,
          body: () async => throw StateError('test failed'),
        ),
        throwsStateError,
      );

      expect(EditableText.debugDeterministicCursor, isFalse);
    });
  });
}
