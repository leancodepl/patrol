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
          home: Text('Hello', key: Key('hello')),
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

  group('finds widget by parent', () {
    maestroTest('simple parent', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          key: Key('app'),
          home: Scaffold(body: Text('Hello', key: Key('hello'))),
        ),
      );

      expect($(MaterialApp), findsOneWidget);
      expect($(#xd).$(#hello), findsOneWidget);

      expect(
        find.descendant(
          of: find.byType(MaterialApp),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );

      //expect($(MaterialApp).$(Text), findsOneWidget);
      //expect($(MaterialApp).$('Text'), findsOneWidget);
      //expect($(MaterialApp).$(#hello), findsOneWidget);
    });
  });
}
