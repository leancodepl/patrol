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
        MaterialApp(
          key: const Key('app'),
          home: Column(
            children: [
              Container(
                key: const Key('container'),
                child: const Text('Hello 1', key: Key('helloText')),
              ),
              const SizedBox(
                key: Key('sizedbox'),
                child: Text('Hello 2', key: Key('helloText')),
              ),
            ],
          ),
        ),
      );

      expect($(MaterialApp).$(Text), findsNWidgets(2));
      expect($(MaterialApp).$(#helloText), findsNWidgets(2));
      expect($(Container).$(Text), findsOneWidget);
      expect($(SizedBox).$(Text), findsOneWidget);
      expect($(Container).$('Hello 2'), findsNothing);
      expect($(SizedBox).$('Hello 1'), findsNothing);

      expect($(MaterialApp).$(Container).$(Text), findsOneWidget);
      expect($(MaterialApp).$(Container).$('Hello 1'), findsOneWidget);
      expect($(MaterialApp).$(SizedBox).$('Hello 2'), findsOneWidget);
    });
  });
}
