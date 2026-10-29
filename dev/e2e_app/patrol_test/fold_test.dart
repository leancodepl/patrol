// The fold API is experimental.
// ignore_for_file: experimental_member_use

import 'dart:io';

import 'package:flutter/material.dart';

import 'common.dart';

// Needs a foldable device, such as the iPhone Duo simulator or a Pixel Fold.
void main() {
  patrol(
    'app moves between the displays when the device folds',
    ($) async {
      await createApp($);

      await $.platform.mobile.setFoldPosture(FoldPosture.closed);
      final closedSize = $.tester.view.physicalSize;
      final closedFrame = await _getAppFrame($);

      await $.platform.mobile.setFoldPosture(FoldPosture.open);
      final openSize = $.tester.view.physicalSize;
      expect(openSize, isNot(closedSize));
      expect(await _getAppFrame($), isNot(closedFrame));

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '1');

      await $.platform.mobile.setFoldPosture(FoldPosture.halfOpen);
      expect($.tester.view.physicalSize, openSize);

      await $.platform.mobile.setFoldPosture(FoldPosture.closed);
      expect($.tester.view.physicalSize, closedSize);
      expect(await _getAppFrame($), closedFrame);

      await $(FloatingActionButton).tap();
      expect($(#counterText).text, '2');

      if (Platform.isAndroid) {
        await $.platform.android.resetFoldPosture();
      }
    },
    tags: ['android', 'ios', 'foldable'],
  );
}

Future<Rectangle> _getAppFrame(PatrolIntegrationTester $) async {
  if (Platform.isAndroid) {
    // The roots include system windows.
    final appId = $.platform.android.resolvedAppId;
    final views = await $.platform.android.getNativeViews(null);

    return views.roots
        .firstWhere((view) => view.applicationPackage == appId)
        .visibleBounds;
  }

  final views = await $.platform.ios.getNativeViews(null);

  return views.roots.first.frame;
}
