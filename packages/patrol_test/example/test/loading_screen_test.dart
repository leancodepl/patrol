import 'package:example/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:patrol_test/patrol_test.dart';

void main() {
  group('LoadingScreen', () {
    patrolTest('shows hello text when loading completes', ($) async {
      await $.pumpWidget(const MaterialApp(home: LoadingScreen()));

      final helloText = $('Hello');
      await helloText.waitUntilVisible();
      await helloText.tap(andSettle: false);
      expect(helloText, findsOneWidget);
    });

    patrolTest(
      'throws TimeoutException when takes more than visibleTimeout',
      ($) async {
        await $.tester.runAsync(() async {
          await $.pumpWidget(const MaterialApp(home: LoadingScreen()));

          final helloText = $('Hello');
          await expectLater(
            helloText.waitUntilVisible,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        });
      },
      config: PatrolTestConfig(
        visibleTimeout: const Duration(milliseconds: 100),
      ),
    );
  });
}
