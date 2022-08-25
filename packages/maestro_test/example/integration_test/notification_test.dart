import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

import 'config.dart';

void main() {
  final maestro = Maestro.forTest();

  maestroTest(
    'sends a notification and taps on it',
    ($) async {
      $.log('Yay, notification_test.dart is starting!');

      await $.pumpWidgetAndSettle(const ExampleApp());

      await $('Open notifications screen').tap();

      await $(RegExp('someone liked')).tap(); // appears on top
      await $(RegExp('special offer')).tap(); // also appears on top

      (await maestro.getNotifications()).forEach($.log);

      await maestro.tapOnNotificationByIndex(1);
      await maestro.tapOnNotificationBySelector(
        const Selector(textContains: 'special offer'),
      );
    },
    config: maestroConfig,
  );
}
