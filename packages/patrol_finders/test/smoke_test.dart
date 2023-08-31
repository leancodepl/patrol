import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/src/custom_finders/custom_finders.dart';

void main() {
  patrolWidgetTest('finds by parent', ($) async {
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

  patrolWidgetTest('finds by parent and with descendant', ($) async {
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

  patrolWidgetTest(
    'visible() throws exception when widget is not hit testable',
    ($) async {
      await pumpWithOverlays($);

      expect(find.text('non-visible text'), findsOneWidget);

      await expectLater(
        () => $('non-visible text').waitUntilVisible(),
        throwsA(isA<WaitUntilVisibleTimeoutException>()),
      );
    },
    config: const PatrolTesterConfig(
      visibleTimeout: Duration(milliseconds: 300),
    ),
  );

  patrolWidgetTest('finds RichText', ($) async {
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

  patrolWidgetTest('text returns the nearest visible Text widget (1)',
      ($) async {
    await smallPump($);

    expect($(#helloText), findsOneWidget);
    expect($(#helloText).text, 'Hello');
  });

  patrolWidgetTest('text returns the nearest visible Text widget (2)',
      ($) async {
    await pumpWithOverlays($);

    expect($(#visibleText), findsOneWidget);
    expect($(#hiddenText), findsOneWidget);

    expect($(#visibleText).text, 'visible text');
    expect(
      () => $(#someWrongKey).text,
      throwsA(
        isA<PatrolFinderException>().having(
          (error) => error.message,
          'message',
          "Finder \"zero widgets with key [<'someWrongKey'>] (ignoring offstage widgets)\" found no widgets",
        ),
      ),
    );
  });

  patrolWidgetTest(
    'never settles when an invisible child of InexedStack is requesting frames',
    ($) async {
      await expectLater(
        () async => $.pumpWidgetAndSettle(
          MaterialApp(
            home: Scaffold(
              body: IndexedStack(
                children: const [
                  Center(child: Text('first child')),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
        throwsA(
          isA<AssertionError>().having(
            (err) => err.message,
            'message',
            'pumpAndSettle timed out',
          ),
        ),
      );
    },
  );

  patrolWidgetTest('can tap() on widget scrolled to by scrollTo()', ($) async {
    // Regression test for https://github.com/leancodepl/patrol/issues/1046

    var count = 0;
    await $.pumpWidgetAndSettle(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ListView(
                children: [
                  Stack(
                    children: [
                      const Center(child: Text('Text')),
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => count++),
                    child: const Text('Text'),
                  ),
                  Text('Count: $count'),
                ],
              );
            },
          ),
        ),
      ),
    );

    await $('Text').scrollTo().tap();
    expect($('Count: 1'), findsOneWidget);
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
