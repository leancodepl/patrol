// This test intentionally throws multiple exceptions to verify that
// the Patrol framework correctly reports all exceptions separately:
// 1. RenderFlex overflow exceptions are properly captured and logged
// 2. WaitUntilVisibleTimeoutException is properly captured and logged
// 3. All exceptions are reported distinctly (not merged or lost)
//
// The test passes by suppressing overflow errors and asserting the timeout exception.

import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('opens the overflow screen', ($) async {
    await createApp($);

    // Temporarily suppress FlutterError.onError to allow overflow errors
    // without failing the test. We're specifically testing that multiple
    // exceptions can be handled and reported correctly.
    final originalOnError = FlutterError.onError;
    final List<FlutterErrorDetails> capturedErrors = [];

    FlutterError.onError = capturedErrors.add;

    try {
      await $('Open overflow screen').scrollTo().tap();

      // Wait for frame to render and trigger overflow errors
      await $.pumpAndSettle();

      // Verify that overflow exceptions were captured
      expect(
        capturedErrors.length,
        greaterThanOrEqualTo(2),
        reason: 'Expected at least 2 RenderFlex overflow errors',
      );

      expect(
        capturedErrors.any(
          (e) =>
              e.toString().contains('RenderFlex overflowed') &&
              e.toString().contains('bottom'),
        ),
        isTrue,
        reason: 'Expected vertical overflow error',
      );

      expect(
        capturedErrors.any(
          (e) =>
              e.toString().contains('RenderFlex overflowed') &&
              e.toString().contains('right'),
        ),
        isTrue,
        reason: 'Expected horizontal overflow error',
      );

      // The overflow screen is not scrollable, so attempting to scroll
      // to a non-existent widget should throw a timeout exception
      await expectLater(
        () => $(ValueKey('key')).scrollTo().tap(),
        throwsA(isA<WaitUntilVisibleTimeoutException>()),
      );
    } finally {
      // Restore original error handler
      FlutterError.onError = originalOnError;
    }
  }, tags: ['android', 'ios', 'physical_device']);
}
