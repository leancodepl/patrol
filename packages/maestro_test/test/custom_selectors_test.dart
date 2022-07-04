import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors.dart';

void main() {
  group('finds widget by', () {
    maestroTest('type', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          home: Text('Hello'),
        ),
      );
      expect($(Text), findsOneWidget);
    });

    maestroTest('key', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          home: Text('Hello', key: ValueKey('hello')),
        ),
      );
      expect($(#hello), findsOneWidget);
    });

    maestroTest('text', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(home: Text('Hello')),
      );
      expect($('Hello'), findsOneWidget);
    });

    maestroTest('text it contains', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(home: Text('Hello')),
      );
      expect($(RegExp('Hello')), findsOneWidget);
      expect($(RegExp('Hell.*')), findsOneWidget);
      expect($(RegExp('.*ello')), findsOneWidget);
      expect($(RegExp('.*ell.*')), findsOneWidget);
    });

    maestroTest('icon', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          home: Icon(Icons.code),
        ),
      );

      expect($(Icons.code), findsOneWidget);
    });

    maestroTest(
      'text using a nested MaestroFinder',
      ($) async {
        await $.pumpWidgetAndSettle(
          const MaterialApp(home: Text('Hello')),
        );
        expect($($('Hello')), findsOneWidget);
      },
    );

    maestroTest(
      'text using many nested MaestroFinders',
      ($) async {
        await $.pumpWidgetAndSettle(
          const MaterialApp(home: Text('Hello')),
        );

        expect($($($($('Hello')))), findsOneWidget);
      },
    );
  });
}
