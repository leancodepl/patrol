import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/custom_finders.dart';

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

    maestroTest(
      'visible() throws exception when widget is not hit testable',
      ($) async {
        await pumpWithOverlays($);

        expect(find.text('hidden boi'), findsOneWidget);

        await expectLater(
          () => $('hidden boi').waitUntilVisible(),
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
      config: const MaestroTestConfig(
        visibleTimeout: Duration(milliseconds: 300),
      ),
    );

    maestroTest('finds RichText', ($) async {
      await $.pumpWidgetAndSettle(
        const MaterialApp(
          home: Text.rich(
            TextSpan(
              text: 'Some text',
              children: [
                TextSpan(text: 'Some more text'),
                WidgetSpan(child: SizedBox(width: 8)),
                WidgetSpan(child: Icon(Icons.public)),
              ],
            ),
          ),
        ),
      );

      expect($(RegExp('Some text')), findsOneWidget);
      expect($(RegExp('Some more text')), findsOneWidget);
      expect($('Some textSome more text\uFFFC\uFFFC'), findsOneWidget);
    });
  });

  maestroTest('text returns the nearest visible Text widget (1)', ($) async {
    await smallPump($);

    expect($(#helloText), findsOneWidget);
    expect($(#helloText).text, 'Hello');
  });

  maestroTest('text returns the nearest visible Text widget (2)', ($) async {
    await pumpWithOverlays($);

    expect($(#visibleText), findsOneWidget);
    expect($(#hiddenText), findsOneWidget);

    expect($(#visibleText).text, 'visible boi');
    expect(
      () => $(#hiddenBoi).text,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'No element',
        ),
      ),
    );
    expect(
      () => $(#hiddenBoiButWrongKey).text,
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'No element',
        ),
      ),
    );
  });
}

Future<void> smallPump(MaestroTester $) async {
  await $.pumpWidgetAndSettle(
    MaterialApp(
      home: Row(
        children: const [
          Icon(Icons.front_hand),
          Text('Hello', key: Key('helloText')),
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
            const Center(child: Text('hidden boi', key: Key('hiddenText'))),
            Center(
              child: Container(
                width: 150,
                height: 150,
                color: Colors.blue,
              ),
            ),
            const Text('visible boi', key: Key('visibleText')),
          ],
        ),
      ),
    ),
  );
}
