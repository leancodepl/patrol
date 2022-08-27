import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

late String mapsId;
late String myAppId;

Future<void> main() async {
  Maestro.forTest();

  maestroTest(
    'a dummy test that does nothing',
    ($) async {
      await $.pumpWidgetAndSettle(const ExampleApp());

      await Future<void>.delayed(const Duration(minutes: 10));
    },
    config: maestroConfig,
  );
}
