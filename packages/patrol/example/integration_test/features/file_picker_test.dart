@Tags(['android'])

import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../config.dart';

void main() {
  patrolTest(
    'selects an image using a native file picker',
    config: patrolConfig,
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());

      await $('Open file picker screen').scrollTo().tap();
      await $('Open file picker').tap();

      expect($(#image_0), findsNothing);

      await $.native.tap(Selector(text: 'download.jpeg'));
      await $.pumpAndSettle();

      expect($(#image_0), findsOneWidget);
    },
  );
}
