import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'accepts location permission',
    config: maestroConfig,
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open location screen').tap(andSettle: false);

      await maestro.grantLocationOnlyThisTime();

      await $.pumpAndSettle();

      expect($(RegExp('lat')), findsOneWidget);
      expect($(RegExp('lng')), findsOneWidget);
    },
  );
}
