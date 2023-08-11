import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:patrol_finders_example/loading_screen.dart';

void main() {
  patrolWidgetTest('shows hello text when loading completes', ($) async {
    await $.pumpWidget(MaterialApp(home: LoadingScreen()));

    final helloText = $('Hello');
    await helloText.waitUntilVisible();
    await helloText.tap(settlePolicy: SettlePolicy.noSettle);
    expect(helloText, findsOneWidget);
  });

  patrolWidgetTest(
    'throws TimeoutException when takes more than visibleTimeout',
    ($) async {
      await $.tester.runAsync(() async {
        await $.pumpWidget(MaterialApp(home: LoadingScreen()));

        final helloText = $('Hello');
        await expectLater(
          helloText.waitUntilVisible,
          throwsA(isA<WaitUntilVisibleTimeoutException>()),
        );
      });
    },
    config: PatrolTesterConfig(visibleTimeout: Duration(milliseconds: 100)),
  );
}
