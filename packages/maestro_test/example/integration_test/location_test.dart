import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'accepts location permission',
    config: maestroConfig.copyWith(sleep: const Duration(seconds: 5)),
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open location screen').tap(andSettle: false);

      await maestro.selectCoarseLocation();
      await maestro.selectFineLocation();
      await maestro.grantPermissionOnlyThisTime();

      await $.pumpAndSettle();

      expect($(RegExp('lat')), findsOneWidget);
      expect($(RegExp('lng')), findsOneWidget);
    },
  );
}
