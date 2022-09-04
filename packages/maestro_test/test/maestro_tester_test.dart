import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/common.dart';
import 'package:maestro_test/src/custom_finders/exceptions.dart';

void main() {
  group('tap', () {
    maestroTest(
      'throws exception when no widget to tap on is found',
      (tester) async {
        await tester.pumpWidget(const MaterialApp());

        await expectLater(
          () => tester.tap(find.text('some text')),
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
    );

    maestroTest('taps on widget and pumps', (tester) async {
      var count = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (state, setState) => Column(
              children: [
                Text('count: $count'),
                GestureDetector(
                  onTap: () => setState(() => count++),
                  child: const Text('Tap'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));

      expect(find.text('count: 1'), findsOneWidget);
    });

    maestroTest(
      'taps on the first widget by default and pumps',
      (tester) async {
        var count = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (state, setState) => Column(
                children: [
                  Text('count: $count'),
                  GestureDetector(
                    onTap: () => setState(() => count++),
                    child: const Text('Tap'),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('Tap'),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.text('Tap'));
        expect(find.text('count: 1'), findsOneWidget);
      },
    );

    maestroTest('is guarded', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Text('Tap')));

      expect(
        () {
          unawaited(tester.tap(find.text('Tap')));
          unawaited(tester.tap(find.text('Tap')));
        },
        throwsAssertionError,
      );
    });
  });

  group('enterText', () {
    maestroTest(
      'throws exception when no widget to enter text in is found',
      (tester) async {
        await tester.pumpWidget(const MaterialApp());

        await expectLater(
          () => tester.enterText(find.text('some text'), 'some text'),
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
    );

    maestroTest(
      'throws StateError when widget is not EditableText',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Text('not a TextField')),
        );

        await expectLater(
          () => tester.enterText(find.text('not a TextField'), 'some text'),
          throwsStateError,
        );
      },
    );

    maestroTest(
      'enters text when the target widget has an EditableText descendant',
      (tester) async {
        var content = '';
        await tester.pumpWidgetAndSettle(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (state, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('content: $content'),
                    TextField(
                      onChanged: (newValue) {
                        setState(() => content = newValue);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(Scaffold), 'some input');
        expect(find.text('content: some input'), findsOneWidget);
      },
    );

    maestroTest('enters text in widget and pumps', (tester) async {
      var content = '';
      await tester.pumpWidgetAndSettle(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (state, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('content: $content'),
                  TextField(
                    onChanged: (newValue) => setState(() => content = newValue),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'some input');
      expect(find.text('content: some input'), findsOneWidget);
    });

    maestroTest(
      'enters text in the first widget by default and pumps',
      (tester) async {
        var content = '';
        await tester.pumpWidgetAndSettle(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (state, setState) => Column(
                  children: [
                    Text('content: $content'),
                    TextField(
                      onChanged: (newValue) =>
                          setState(() => content = newValue),
                    ),
                    TextField(
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'some text');
        expect(find.text('content: some text'), findsOneWidget);
      },
    );

    maestroTest('is guarded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TextField())),
      );

      expect(
        () {
          unawaited(tester.enterText(find.byType(TextField), 'some text'));
          unawaited(tester.enterText(find.byType(TextField), 'some text'));
        },
        throwsAssertionError,
      );
    });
  });

  group('dragUntilExists', () {
    maestroTest(
      'throws exception when no Scrollable is found within timeout',
      (tester) async {
        await tester.pumpWidget(const MaterialApp());

        await expectLater(
          () => tester.dragUntilExists(
            finder: find.text('text'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, 16),
          ),
          // because it was waiting for a Scrollable to appear
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
    );

    maestroTest(
      'throws StateError when no widget is found after reaching maxIteration',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ListView(
              children: const [Text('one'), Text('two')],
            ),
          ),
        );

        await expectLater(
          () => tester.dragUntilExists(
            finder: find.text('three'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, 16),
          ),
          throwsStateError,
        );
      },
    );

    maestroTest('drags to existing and visible widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: const [Text('some text')],
            ),
          ),
        ),
      );

      expect(find.text('some text').hitTestable(), findsOneWidget);

      await tester.dragUntilExists(
        finder: find.text('some text'),
        view: find.byType(Scrollable),
        moveStep: const Offset(0, 16),
      );

      expect(find.text('some text').hitTestable(), findsOneWidget);
    });

    maestroTest(
      'drags to existing but not visible widget in Scrollable appearing late',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: FutureBuilder(
              future: Future<void>.delayed(const Duration(milliseconds: 300)),
              builder: (context, snapshot) {
                return LayoutBuilder(
                  builder: (_, constraints) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const CircularProgressIndicator();
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text('top text'),
                          SizedBox(height: constraints.maxHeight * 2),
                          const Text('bottom text'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );

        expect(find.text('top text').hitTestable(), findsNothing);
        expect(find.text('bottom text').hitTestable(), findsNothing);

        await tester.dragUntilExists(
          finder: find.text('top text'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, 16),
        );
        final initialScrollPosition = tester.tester
            .firstWidget<Scrollable>(find.byType(Scrollable))
            .controller
            ?.position
            .pixels;

        await tester.dragUntilExists(
          finder: find.text('bottom text'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, 16),
        );

        final finalScrollPosition = tester.tester
            .firstWidget<Scrollable>(find.byType(Scrollable))
            .controller
            ?.position
            .pixels;

        expect(find.text('top text').hitTestable(), findsNothing);
        expect(find.text('bottom text').hitTestable(), findsOneWidget);
        expect(initialScrollPosition, isZero);
        expect(finalScrollPosition, isPositive);
      },
    );

    maestroTest(
      'drags to existing and visible widget in the first Scrollable',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: const [Text('text 1')],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: const [Text('text 2')],
                  ),
                ),
              ],
            ),
          ),
        );

        expect(find.text('text 1').hitTestable(), findsOneWidget);
        expect(find.text('text 2').hitTestable(), findsOneWidget);

        await tester.dragUntilExists(
          finder: find.text('text 1'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, 16),
        );

        expect(find.text('text 1').hitTestable(), findsOneWidget);
        expect(find.text('text 2').hitTestable(), findsOneWidget);

        await tester.dragUntilExists(
          finder: find.text('text 2'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, 16),
        );

        expect(find.text('text 1').hitTestable(), findsOneWidget);
        expect(find.text('text 2').hitTestable(), findsOneWidget);
      },
    );

    maestroTest(
      'is a no-op when dragging to the first existing widget in the first Scrollable',
      (tester) async {
        await tester.pumpWidgetAndSettle(
          // TODO: finish this test
          MaterialApp(
            home: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      Text('some text'),
                      SizedBox(width: 801),
                      Text('xd text'),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      Text('some text'),
                      Text('some text'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        expect(find.text('xd text').hitTestable(), findsNothing);

        await tester.dragUntilExists(
          finder: find.text('xd text'),
          view: find.byType(Scrollable),
          moveStep: const Offset(16, 0),
        );

        final finalScrollPosition = tester.tester
            .firstWidget<Scrollable>(find.byType(Scrollable))
            .controller
            ?.position
            .pixels;

        expect(find.text('xd text').hitTestable(), findsOneWidget);
        // expect(finalScrollPosition, isZero);
      },
    );
  });
}
