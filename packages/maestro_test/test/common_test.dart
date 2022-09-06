import 'package:flutter/material.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  group('maestroTest', () {
    maestroTest(
      'does not fail the test when exception is caught with takeException()',
      ($) async {
        await $.pumpWidgetAndSettle(
          MaterialApp(
            home: Column(
              children: [
                const Text('some text'),
                ...[
                  for (var i = 0; i < 100; i++)
                    Container(
                      width: 100,
                      height: 100,
                      color: Colors.red,
                      padding: const EdgeInsets.all(16),
                    )
                ],
              ],
            ),
          ),
        );

        $.tester.takeException();

        expect(find.text('some text'), findsOneWidget);
      },
    );
  });
}
