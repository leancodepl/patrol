import 'package:example/keys.dart';
import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  maestroTest('drags to a widget', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());

    // TRY 1
    await $('Open scrolling screen').scrollTo().tap();

    // TRY 2 - also works, but only with a somewhat bigger Offset (e.g (0, -50))
    // await $.tester.dragUntilVisible(
    //   $('Open scrolling screen'),
    //   $(Scrollable),
    //   Offset(0, -50),
    // );

    // TRY 3 - works
    // await $.tester.scrollUntilVisible(find.text('Open scrolling screen'), 100);

    //await $('Open scrolling screen').tap();

    expect(await $(K.topText).waitUntilVisible(), findsOneWidget);
    expect($(K.bottomText).hitTestable(), findsNothing);

    await $(K.bottomText).scrollTo();

    expect($(K.bottomText).hitTestable(), findsOneWidget);
  });
}
