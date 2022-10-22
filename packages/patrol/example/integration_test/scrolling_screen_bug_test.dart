import 'package:example/keys.dart';
import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'drags to a widget',
    nativeAutomation: true,
    ($) async {
      await $.pumpWidgetAndSettle(ExampleApp());
      await $('Open scrolling screen bug').scrollTo().tap();

      expect(await $(K.topText).waitUntilVisible(), findsOneWidget);
      expect($(K.bottomText).hitTestable(), findsNothing);

      await $(K.bottomText).scrollTo(); // spins here
      $.log('After scrollTo()');

      await Future<void>.delayed(Duration(seconds: 3));

      await $(K.bottomText).tap();
      $.log('After tap()');

      expect($(K.bottomText).hitTestable(), findsOneWidget);
    },
  );
}
