import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

void main() {
  patrolWidgetTest('correctly handles non-hittestable widgets', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $('Open overlay screen').scrollTo().tap();

    expect($('non-visible text'), findsOneWidget);
    expect($('non-visible text').hitTestable(), findsNothing);

    await expectLater(
      () => $('non-visible text').waitUntilVisible(),
      throwsA(isA<WaitUntilVisibleTimeoutException>()),
    );
  });
}
