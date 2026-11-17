import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../common.dart';

// These tests check what the app sees when the browser emulates a phone. Run
// them with a device and what the app should see on it, for example:
//
//   patrol test --target patrol_test/web_device_emulation/ -d chrome \
//     --web-device "Pixel 7" \
//     --dart-define=EMULATED_PLATFORM=android \
//     --dart-define=EMULATED_DEVICE_PIXEL_RATIO=2.625 \
//     --dart-define=EMULATED_SIZE=412x839 \
//     --dart-define=EMULATED_SCREEN=412x915
const _platform = String.fromEnvironment('EMULATED_PLATFORM');
const _devicePixelRatio = String.fromEnvironment('EMULATED_DEVICE_PIXEL_RATIO');
const _size = String.fromEnvironment('EMULATED_SIZE');
const _screen = String.fromEnvironment('EMULATED_SCREEN');

List<double> _parseSize(String size) =>
    size.split('x').map(double.parse).toList();

void main() {
  patrol('sees the screen of the emulated phone', ($) async {
    await $.pumpWidgetAndSettle(_app);

    final view = $.tester.view;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    final [width, height] = _parseSize(_size);
    final [screenWidth, screenHeight] = _parseSize(_screen);

    expect(view.devicePixelRatio, double.parse(_devicePixelRatio));
    expect(logicalSize.width, closeTo(width, 1));
    expect(logicalSize.height, closeTo(height, 1));
    expect(web.window.screen.width, screenWidth);
    expect(web.window.screen.height, screenHeight);
    expect(web.window.matchMedia('(pointer: coarse)').matches, isTrue);
    expect(web.window.navigator.maxTouchPoints, greaterThan(0));
  });

  patrol('runs on the platform of the emulated phone', ($) async {
    await $.pumpWidgetAndSettle(_app);

    expect(defaultTargetPlatform.name, _platform);
  });

  // Patrol collects the tests in one browser page and runs each by name in
  // another. This name is computed in both, so the test is only found (and
  // the run only passes) if the collecting page emulates the phone too.
  final collectingView = ui.PlatformDispatcher.instance.implicitView!;
  patrol('is collected on ${defaultTargetPlatform.name} '
      'at ${collectingView.devicePixelRatio}x', ($) async {
    await $.pumpWidgetAndSettle(_app);

    expect(defaultTargetPlatform.name, _platform);
    expect(collectingView.devicePixelRatio, double.parse(_devicePixelRatio));
  });
}

const _app = MaterialApp(home: Scaffold(body: Text('Device emulation')));
