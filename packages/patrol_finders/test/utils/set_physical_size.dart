import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

void setPhysicalSize(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 600);

  // resets the screen to its original size after the test end
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
