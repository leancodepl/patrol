import 'package:example/main.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  maestroTest('correctly handles non-hittestable widgets', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $('Open overlay screen').tap();

    expect($('non-visible text'), findsOneWidget);
    expect($('non-visible text').hitTestable(), findsNothing);

    await expectLater(
      () => $('non-visible text').waitUntilVisible(),
      throwsA(isA<WaitUntilVisibleTimedOutException>()),
    );
  });
}
