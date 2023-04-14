import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.native.pressHome();
      await $.native.openApp();

      expect($(#counterText).text, '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');
    },
  );

  group('example group top', () {
    // A few simple tests that do nothing

    group('example group bottom', () {
      test('example bottom test 1', () {
        expect(1, equals(1));
      });
    });

    test('example test 1', () {
      expect(1, equals(1));
    });

    test('example test 2', () {
      expect(1, equals(1));
    });
  });
}
