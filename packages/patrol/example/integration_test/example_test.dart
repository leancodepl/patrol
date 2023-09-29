import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  // WORKS
  // 12 + 1 + 180 + 1 = 194
  //
  // example_test: 12
  // space: 1
  // alpha * 36: 180
  // A: 1
  patrol(
    '${"alpha" * 36}A', // 194
    ($) async {
      await createApp($);

      await Future.delayed(Duration(seconds: 5));

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');
    },
  );

  // WORKS
  // 12 + 1 + 180 + 2 = 195
  //
  // example_test: 12
  // space: 1
  // alpha * 36: 180
  // A: 2
  patrol(
    '${"alpha" * 36}AA', // 195
    ($) async {
      await createApp($);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');
    },
  );
}
