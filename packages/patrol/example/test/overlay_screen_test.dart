import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('correctly handles non-hittestable widgets', ($) async {
    await $.pumpWidgetAndSettle(ExampleApp());
    await $('Open overlay screen').tap();

    expect($('non-visible text'), findsOneWidget);
    expect($('non-visible text').hitTestable(), findsNothing);

    await expectLater(
      () => $('non-visible text').waitUntilVisible(),
      throwsA(isA<WaitUntilVisibleTimeoutException>()),
    );
  });
}
