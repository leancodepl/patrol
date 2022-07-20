import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_selectors/custom_selectors.dart';

void main() {
  group('MaestroFinders work the same as Flutter Finders', () {
    maestroTest('(simple case 1)', ($) async {
      final flutterFinder = find.byType(Text);
      final maestroFinder = $(Text);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(simple case 2)', ($) async {
      final flutterFinder = find.byKey(const Key('someKey'));
      final maestroFinder = $(#someKey);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(simple case 2)', ($) async {
      final flutterFinder = find.byIcon(Icons.home);
      final maestroFinder = $(Icons.home);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 1)', ($) async {
      final flutterFinder = find.descendant(
        of: find.byType(Container),
        matching: find.byType(Text),
      );

      final maestroFinder = $(Container).$(Text);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 2)', ($) async {
      final flutterFinder = find.descendant(
        of: find.descendant(
          of: find.byType(MaterialApp),
          matching: find.byType(Container),
        ),
        matching: find.byType(Text),
      );

      final maestroFinder = $(MaterialApp).$(Container).$(Text);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 3)', ($) async {
      final flutterFinder = find.descendant(
        of: find.ancestor(
          of: find.text('layer'),
          matching: find.byType(MaterialApp),
        ),
        matching: find.byKey(const Key('SomeKey')),
      );

      final maestroFinder = $(MaterialApp).containing('layer').$(#SomeKey);

      expect(flutterFinder.toString(), maestroFinder.toString());
    });

    maestroTest('(complex case 4)', ($) async {
      final flutterFinder = find.ancestor(
        of: find.ancestor(
          of: find.byKey(const Key('SomeKey')),
          matching: find.text('layer'),
        ),
        matching: find.byType(MaterialApp),
      );

      final maestroFinder =
          $(MaterialApp).containing($('layer').containing(#SomeKey));

      expect(flutterFinder.toString(), maestroFinder.toString());
    });
  });

  group('matches widget by', () {
    maestroTest('first', ($) async {
      await smallPump($);
      expect($(Text).first, findsOneWidget);
      expect($(Icon).first, findsOneWidget);
      expect($(Row).first, findsOneWidget);
    });

    maestroTest('last', ($) async {
      await smallPump($);
      expect($(Text).last, findsOneWidget);
      expect($(Icon).last, findsOneWidget);
      expect($(Row).last, findsOneWidget);
    });

    maestroTest('at', ($) async {
      await smallPump($);
      expect($(Text).at(0), findsOneWidget);
      expect($(Icon).at(0), findsOneWidget);
      expect($(Row).at(0), findsOneWidget);
    });
  });

  group('finds widget by', () {
    maestroTest('type', ($) async {
      await smallPump($);
      expect($(Text), findsOneWidget);
      expect($(Icon), findsOneWidget);
      expect($(Row), findsOneWidget);
    });

    maestroTest('key', ($) async {
      await mediumPump($);

      expect($(#hello), findsOneWidget);
      expect($(const Symbol('hello')), findsOneWidget);
      expect($(const Key('hello')), findsOneWidget);

      expect($(const Symbol('Some \n long, complex\t\ttext!')), findsOneWidget);
      expect($(const Key('Some \n long, complex\t\ttext!')), findsOneWidget);

      expect($(const ValueKey({'key': 'value'})), findsOneWidget);
      expect($(const ValueKey({'key': 'value1'})), findsNothing);
    });

    maestroTest('text', ($) async {
      await smallPump($);
      expect($('Hello'), findsOneWidget);
    });

    maestroTest('text it contains', ($) async {
      await smallPump($);
      expect($(RegExp('Hello')), findsOneWidget);
      expect($(RegExp('Hell.*')), findsOneWidget);
      expect($(RegExp('.*ello')), findsOneWidget);
      expect($(RegExp('.*ell.*')), findsOneWidget);
    });

    maestroTest('icon', ($) async {
      await smallPump($);
      expect($(Icons.front_hand), findsOneWidget);
    });

    maestroTest('text using MaestroFinder', ($) async {
      await smallPump($);
      expect($('Hello'), findsOneWidget);
    });

    maestroTest(
      'text using 2 nested MaestroFinders',
      ($) async {
        await smallPump($);
        expect($($('Hello')), findsOneWidget);
      },
    );

    maestroTest(
      'text using many nested MaestroFinders',
      ($) async {
        await smallPump($);
        expect($($($($($('Hello'))))), findsOneWidget);
      },
    );

    maestroTest('text using Flutter Finder', ($) async {
      await smallPump($);
      expect($(find.text('Hello')), findsOneWidget);
    });
  });

  group('smoke tests', () {
    maestroTest('finds by parent', ($) async {
      await bigPump($);

      expect($(MaterialApp).$(Text), findsNWidgets(2));
      expect($(MaterialApp).$(#helloText), findsNWidgets(2));

      expect($(MaterialApp).$(Text).at(0), findsOneWidget);
      expect($(MaterialApp).$(Text).at(1), findsOneWidget);

      expect($(Container).$(Text), findsOneWidget);
      expect($(SizedBox).$(Text), findsOneWidget);
      expect($(Container).$('Hello 2'), findsNothing);
      expect($(SizedBox).$('Hello 1'), findsNothing);

      expect($(MaterialApp).$(Container).$(Text), findsOneWidget);
      expect($(MaterialApp).$(Container).$('Hello 1'), findsOneWidget);
      expect($(MaterialApp).$(SizedBox).$('Hello 2'), findsOneWidget);
    });

    maestroTest('finds by parent and with descendant', ($) async {
      await bigPump($);

      expect($(SizedBox).containing(Text), findsOneWidget);
      expect($(Column).containing('Hello 2'), findsOneWidget);

      final columnFinder = $(Column).containing(
        $(Container).containing('Hello 1'),
      );
      expect(columnFinder, findsOneWidget);
      expect(columnFinder.finder.evaluate().first.widget.runtimeType, Column);

      expect(
        $(Column).containing(Container).containing(#helloText),
        findsNWidgets(2),
      );
    });

    maestroTest('finds only hit testable', ($) async {
      await pumpWithOverlays($);

      expect(find.text('hidden boi'), findsOneWidget);

      // what if we want to scroll to it?
      await expectLater($('hidden boi').hitTestable(), findsNothing);
    });
  });
}

Future<void> smallPump(MaestroTester $) async {
  await $.pumpWidgetAndSettle(
    MaterialApp(
      home: Row(
        children: const [
          Icon(Icons.front_hand),
          Text('Hello'),
        ],
      ),
    ),
  );
}

Future<void> mediumPump(MaestroTester $) async {
  await $.pumpWidgetAndSettle(
    MaterialApp(
      home: Column(
        children: const [
          Text('Hello', key: Key('hello')),
          Text('Some text', key: Key('Some \n long, complex\t\ttext!')),
          Text('Another text', key: ValueKey({'key': 'value'})),
        ],
      ),
    ),
  );
}

Future<void> bigPump(MaestroTester $) async {
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
          const SizedBox(child: Icon(Icons.code)),
        ],
      ),
    ),
  );
}

Future<void> pumpWithOverlays(MaestroTester $) async {
  await $.pumpWidgetAndSettle(
    MaterialApp(
      key: const Key('app'),
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: TextButton(
                child: const Text('hidden boi'),
                onPressed: () => print('tap tap'),
              ),
            ),
            Center(
              child: Container(
                width: 150,
                height: 150,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
