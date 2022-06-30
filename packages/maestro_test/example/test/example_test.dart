import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'counter state is the same after going to Home and switching apps',
    (tester) async {
      await tester.pump(const MyApp());

      await $(FloatingActionButton).tap();
      expect($(#counterText), '1');

      await maestro.pressHome();
      await maestro.pressDoubleRecentApps();

      expect($(#counterText), '1');
      await $(FloatingActionButton).tap();
      expect($(#counterText), '2');

      await maestro.openHalfNotificationShade();
      await maestro.pressBack();
    },
  );
}
