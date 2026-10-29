// The fold API is experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';

import 'common.dart';

// Needs a foldable simulator, such as the iPhone Duo (Xcode 27.1+).
void main() {
  patrol(
    'app moves between the displays when the simulator folds',
    ($) async {
      await createApp($);

      await $.platform.ios.setFoldPosture(FoldPosture.closed);
      final closedSize = $.tester.view.physicalSize;
      final closedFrame = await _getAppFrame($);

      await $.platform.ios.setFoldPosture(FoldPosture.open);
      final openSize = $.tester.view.physicalSize;
      expect(openSize, isNot(closedSize));
      expect(await _getAppFrame($), isNot(closedFrame));

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.platform.ios.setFoldPosture(FoldPosture.halfOpen);
      expect($.tester.view.physicalSize, openSize);

      await $.platform.ios.setFoldPosture(FoldPosture.closed);
      expect($.tester.view.physicalSize, closedSize);
      expect(await _getAppFrame($), closedFrame);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');
    },
    tags: ['ios', 'foldable'],
  );
}

/// Frame of the app as the native automator sees it, which follows the app to
/// the other display.
Future<Rectangle> _getAppFrame(PatrolIntegrationTester $) async {
  final views = await $.platform.ios.getNativeViews(null);

  return views.roots.first.frame;
}
