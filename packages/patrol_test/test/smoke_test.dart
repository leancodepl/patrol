import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_test/src/custom_finders/custom_finders.dart';

void main() {
  group('finds widget by', () {
    patrolTest('type', ($) async {
      await smallPump($);
      expect($(Text), findsOneWidget);
      expect($(Icon), findsOneWidget);
      expect($(Row), findsOneWidget);
    });

    patrolTest('key', ($) async {
      await mediumPump($);

      expect($(#hello), findsOneWidget);
      expect($(const Symbol('hello')), findsOneWidget);
      expect($(const Key('hello')), findsOneWidget);

      expect($(const Symbol('Some \n long, complex\t\ttext!')), findsOneWidget);
      expect($(const Key('Some \n long, complex\t\ttext!')), findsOneWidget);

      expect($(const ValueKey({'key': 'value'})), findsOneWidget);
      expect($(const ValueKey({'key': 'value1'})), findsNothing);
    });

    patrolTest('text', ($) async {
      await smallPump($);
      expect($('Hello'), findsOneWidget);
    });

    patrolTest('text it contains', ($) async {
      await smallPump($);
      expect($(RegExp('Hello')), findsOneWidget);
      expect($(RegExp('Hell.*')), findsOneWidget);
      expect($(RegExp('.*ello')), findsOneWidget);
      expect($(RegExp('.*ell.*')), findsOneWidget);
    });

    patrolTest('icon', ($) async {
      await smallPump($);
      expect($(Icons.front_hand), findsOneWidget);
    });

    patrolTest('text using PatrolFinder', ($) async {
      await smallPump($);
      expect($('Hello'), findsOneWidget);
    });

    patrolTest(
      'text using 2 nested PatrolFinders',
      ($) async {
        await smallPump($);
        expect($($('Hello')), findsOneWidget);
      },
    );

    patrolTest(
      'text using many nested PatrolFinders',
      ($) async {
        await smallPump($);
        expect($($($($($('Hello'))))), findsOneWidget);
      },
    );

    patrolTest('text using Flutter Finder', ($) async {
      await smallPump($);
      expect($(find.text('Hello')), findsOneWidget);
    });
  });

  group('smoke tests', () {
    patrolTest('finds by parent', ($) async {
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

    patrolTest('finds by parent and with descendant', ($) async {
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

    patrolTest(
      'visible() throws exception when widget is not hit testable',
      ($) async {
        await pumpWithOverlays($);

        expect(find.text('non-visible text'), findsOneWidget);

        await expectLater(
          () => $('non-visible text').waitUntilVisible(),
          throwsA(isA<WaitUntilVisibleTimeoutException>()),
        );
      },
      config: const PatrolTestConfig(
        visibleTimeout: Duration(milliseconds: 300),
      ),
    );

    patrolTest('finds RichText', ($) async {
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

    patrolTest('text returns the nearest visible Text widget (1)', ($) async {
      await smallPump($);

      expect($(#helloText), findsOneWidget);
      expect($(#helloText).text, 'Hello');
    });

    patrolTest('text returns the nearest visible Text widget (2)', ($) async {
      await pumpWithOverlays($);

      expect($(#visibleText), findsOneWidget);
      expect($(#hiddenText), findsOneWidget);

      expect($(#visibleText).text, 'visible text');
      expect(
        () => $(#someWrongKey).text,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'No element',
          ),
        ),
      );
    });
  });
}

Future<void> smallPump(PatrolTester $) async {
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

Future<void> mediumPump(PatrolTester $) async {
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

Future<void> bigPump(PatrolTester $) async {
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

Future<void> pumpWithOverlays(PatrolTester $) async {
  await $.pumpWidgetAndSettle(
    MaterialApp(
      key: const Key('app'),
      home: Scaffold(
        body: Stack(
          children: [
            const Center(
              child: Text('non-visible text', key: Key('hiddenText')),
            ),
            Center(
              child: Container(
                width: 150,
                height: 150,
                color: Colors.blue,
              ),
            ),
            const Text('visible text', key: Key('visibleText')),
          ],
        ),
      ),
    ),
  );
}
