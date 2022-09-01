import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

Future<void> main() async {
  print('here 1!');
  final maestro = Maestro.forTest();
  print('here 2!');

  maestroTest(
    'wait',
    ($) async {
      print('here 3');
      await $.pumpWidget(const ExampleApp());
      print('here 4');

      //final testBinding = $.tester.binding;
      //testBinding.window.platformDispatcher.semanticsEnabledTestValue = true;

      final nativeWidgets = await maestro.getNativeWidgets(
        Selector(contentDescriptionContains: 'screen'),
      );

      for (var i = 0; i < nativeWidgets.length; i++) {
        print('nativeWidget $i: ${nativeWidgets[i]}');
      }

      //expect(nativeWidgets.isNotEmpty, true);

      await Future<void>.delayed(const Duration(minutes: 10));
    },
    config: maestroConfig,
  );
}
