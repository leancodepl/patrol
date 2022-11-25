import 'package:example/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('shows hello text when loading completes', ($) async {
    await $.pumpWidget(MaterialApp(home: LoadingScreen()));

    final helloText = $('Hello');
    await helloText.waitUntilVisible();
    await helloText.tap(andSettle: false);
    expect(helloText, findsOneWidget);
  });

  patrolTest(
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
