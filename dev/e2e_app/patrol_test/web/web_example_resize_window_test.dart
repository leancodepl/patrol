import 'package:flutter/material.dart';

import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('resize window', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await $.platform.web.resizeWindow(size: Size(800, 600));
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.platform.web.resizeWindow(size: Size(1920, 1080));
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));

    await $.platform.web.resizeWindow(size: Size(1280, 720));
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
