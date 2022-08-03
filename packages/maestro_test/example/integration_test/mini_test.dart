import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'counter state is the same after going to Home and switching apps',
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $(FloatingActionButton).tap();
      await $(FloatingActionButton).tap();

      await maestro.pressHome();

      $.log(
        'I went to home! Now gonna wait for 5 seconds and then go open the '
        'mail app.',
      );
      await Future<void>.delayed(Duration(seconds: 5));

      // TODO: different for iOS
      await maestro.openApp(id: 'com.google.android.gm');
      await maestro.pressHome();

      $.log('Opeing the app again...');
      await maestro.openApp(id: 'com.example.example');

      expect($(#counterText).text, '2');

      $.log("More functionality is not implemented, so I'm gonna head out now");

      await Future<void>.delayed(Duration(seconds: 5));
      return;
    },
    appName: 'ExampleApp',
  );
}
