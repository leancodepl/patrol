import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/src/custom_finders/custom_finders.dart';

void main() {
  group('PatrolTester', () {
    group('tap()', () {
      patrolWidgetTest(
        'throws exception when no widget to tap on is found',
        (tester) async {
          await tester.pumpWidget(const MaterialApp());

          await expectLater(
            () => tester.tap(find.text('some text')),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('taps on widget and pumps', (tester) async {
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

      patrolWidgetTest(
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

      patrolWidgetTest('is guarded', (tester) async {
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

    group('enterText()', () {
      patrolWidgetTest(
        'throws exception when no widget to enter text in is found',
        (tester) async {
          await tester.pumpWidget(const MaterialApp());

          await expectLater(
            () => tester.enterText(find.text('some text'), 'some text'),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest(
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

      patrolWidgetTest(
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

      patrolWidgetTest('enters text in widget and pumps', (tester) async {
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
                      onChanged: (newValue) =>
                          setState(() => content = newValue),
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

      patrolWidgetTest(
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

      patrolWidgetTest('is guarded', (tester) async {
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

    group('dragUntilExists()', () {
      patrolWidgetTest(
        'throws exception when no Scrollable is found within timeout',
        (tester) async {
          await tester.pumpWidget(const MaterialApp());

          await expectLater(
            () => tester.dragUntilExists(
              finder: find.text('text'),
              view: find.byType(Scrollable),
              moveStep: const Offset(0, defaultScrollDelta),
            ),
            // because it was waiting for a Scrollable to appear
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest(
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
              moveStep: const Offset(0, defaultScrollDelta),
            ),
            throwsA(isA<WaitUntilExistsTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('drags to existing and visible widget', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: Column(
                children: [Text('some text')],
              ),
            ),
          ),
        );

        expect(find.text('some text').hitTestable(), findsOneWidget);

        await tester.dragUntilExists(
          finder: find.text('some text'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, defaultScrollDelta),
        );

        expect(find.text('some text').hitTestable(), findsOneWidget);
      });

      patrolWidgetTest(
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

                      return ListView(
                        children: [
                          const Text('top text'),
                          SizedBox(height: constraints.maxHeight * 2),
                          const Text('bottom text'),
                        ],
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
            moveStep: const Offset(0, -defaultScrollDelta),
          );
          expect(find.text('top text').hitTestable(), findsOneWidget);
          expect(find.text('bottom text'), findsNothing);

          final initialScrollPosition = tester.tester
              .firstWidget<Scrollable>(find.byType(Scrollable))
              .controller
              ?.position
              .pixels;

          await tester.dragUntilExists(
            finder: find.text('bottom text'),
            view: find.byType(Scrollable),
            // defaultScrollDelta can't be used, because it not possible
            // to achieve a state, in which 'bottom text' exists, but
            // is not visible
            moveStep: const Offset(0, -16),
            maxIteration: 100,
          );

          final finalScrollPosition = tester.tester
              .firstWidget<Scrollable>(find.byType(Scrollable))
              .controller
              ?.position
              .pixels;

          expect(find.text('top text').hitTestable(), findsNothing);
          expect(find.text('bottom text'), findsOneWidget);
          expect(find.text('bottom text').hitTestable(), findsNothing);
          expect(initialScrollPosition, isZero);
          expect(finalScrollPosition, isPositive);
        },
      );

      patrolWidgetTest(
        'drags to existing and visible widget in the first Scrollable',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Text('text 1'),
                        Text('text 1'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [Text('text 2')],
                    ),
                  ),
                ],
              ),
            ),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(find.text('text 2').hitTestable(), findsOneWidget);

          await tester.dragUntilExists(
            finder: find.text('text 1'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, defaultScrollDelta),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(find.text('text 2').hitTestable(), findsOneWidget);

          await tester.dragUntilExists(
            finder: find.text('text 2'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, defaultScrollDelta),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(find.text('text 2').hitTestable(), findsOneWidget);
        },
      );
    });

    group('dragUntilVisible()', () {
      patrolWidgetTest(
        'throws exception when no Scrollable is found within timeout',
        (tester) async {
          await tester.pumpWidget(const MaterialApp());

          await expectLater(
            () => tester.dragUntilVisible(
              finder: find.text('text'),
              view: find.byType(Scrollable),
              moveStep: const Offset(0, defaultScrollDelta),
            ),
            // because it was waiting for a Scrollable to appear
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest(
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
            () => tester.dragUntilVisible(
              finder: find.text('three'),
              view: find.byType(Scrollable),
              moveStep: const Offset(0, defaultScrollDelta),
            ),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('drags to existing and visible widget', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: Column(
                children: [Text('some text')],
              ),
            ),
          ),
        );

        expect(find.text('some text').hitTestable(), findsOneWidget);

        await tester.dragUntilVisible(
          finder: find.text('some text'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, -defaultScrollDelta),
        );

        expect(find.text('some text').hitTestable(), findsOneWidget);
      });

      patrolWidgetTest(
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

          await tester.dragUntilVisible(
            finder: find.text('top text'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, -defaultScrollDelta),
          );
          final initialScrollPosition = tester.tester
              .firstWidget<Scrollable>(find.byType(Scrollable))
              .controller
              ?.position
              .pixels;

          await tester.dragUntilVisible(
            finder: find.text('bottom text'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, -defaultScrollDelta),
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

      patrolWidgetTest(
        'drags to existing and visible widget in the first Scrollable',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('text 1'),
                        Text('text 1'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [Text('text 2')],
                    ),
                  ),
                ],
              ),
            ),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(find.text('text 2').hitTestable(), findsOneWidget);

          await tester.dragUntilVisible(
            finder: find.text('text 1'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, -defaultScrollDelta),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(find.text('text 2').hitTestable(), findsOneWidget);

          await tester.dragUntilVisible(
            finder: find.text('text 2'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, -defaultScrollDelta),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(find.text('text 2').hitTestable(), findsOneWidget);
        },
      );

      patrolWidgetTest(
        'drags to non-existent and non-visible widget in the first Scrollable',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: FutureBuilder<void>(
                future: Future.delayed(const Duration(milliseconds: 300)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }

                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            SizedBox(width: 2000),
                            Text('text 1'),
                            Text('text 1'),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            SizedBox(width: 2000),
                            Text('text 2'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );

          expect(find.text('text 1').hitTestable(), findsNothing);
          expect(find.text('text 2').hitTestable(), findsNothing);

          // scroll the first scrollable
          await tester.dragUntilVisible(
            finder: find.text('text 1'),
            view: find.byType(Scrollable),
            moveStep: const Offset(-defaultScrollDelta, 0),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(
            find.text('text 2').hitTestable(),
            findsNothing, // not scrolled yet
          );

          // scroll the second scrollable
          await tester.dragUntilVisible(
            finder: find.text('text 2'),
            view: find.byType(Scrollable).at(1),
            moveStep: const Offset(-defaultScrollDelta, 0),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(2));
          expect(find.text('text 2').hitTestable(), findsOneWidget);
        },
      );
    });

    patrolWidgetTest(
      'returns a finder matching the first widget that was dragged to',
      (tester) async {
        var count = 0;
        await tester.pumpWidget(
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
                      const Text('Text'),
                      Text('Count: $count'),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        final returnedFinder = await tester.dragUntilVisible(
          finder: find.text('Text'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, defaultScrollDelta),
        );
        await tester.tester.tap(returnedFinder); // tap without safety checks
        await tester.pump();
        expect(find.text('Count: 1'), findsOneWidget);
      },
    );

    group('scrollUntilExists()', () {
      patrolWidgetTest(
        'throws exception when no Scrollable is found within timeout',
        (tester) async {
          await tester.pumpWidget(const MaterialApp());

          await expectLater(
            () => tester.scrollUntilExists(finder: find.text('some text')),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest(
        'throws StateError when no widget is found after reaching maxScrolls',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: ListView(
                children: const [Text('one'), Text('two')],
              ),
            ),
          );

          await expectLater(
            () => tester.scrollUntilExists(finder: find.text('three')),
            throwsA(isA<WaitUntilExistsTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('scrolls to existing and visible widget',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: Column(
                children: [Text('some text')],
              ),
            ),
          ),
        );

        expect(find.text('some text').hitTestable(), findsOneWidget);

        await tester.scrollUntilExists(finder: find.text('some text'));

        expect(find.text('some text').hitTestable(), findsOneWidget);
      });

      patrolWidgetTest(
        'scrolls to existing and visible widget in the first Scrollable',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [Text('text 1')],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [Text('text 2')],
                    ),
                  ),
                ],
              ),
            ),
          );

          expect(find.text('text 1').hitTestable(), findsOneWidget);
          expect(find.text('text 2').hitTestable(), findsOneWidget);

          await tester.scrollUntilExists(finder: find.text('text 1'));
          await tester.scrollUntilExists(finder: find.text('text 2'));

          expect(find.text('text 1').hitTestable(), findsOneWidget);
          expect(find.text('text 2').hitTestable(), findsOneWidget);
        },
      );

      patrolWidgetTest(
        'scrolls to existing and visible widget in the first Scrollable when '
        'many same widgets are present',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Text('text 1'),
                        Text('text 1'),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text('text 1'),
                  ),
                ],
              ),
            ),
          );

          expect(find.text('text 1').hitTestable(), findsNWidgets(3));

          await tester.scrollUntilExists(finder: find.text('text 1'));

          expect(find.text('text 1').hitTestable(), findsNWidgets(3));
        },
      );

      patrolWidgetTest('scrolls to existing but not visible widget',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LayoutBuilder(
              builder: (_, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('top text'),
                      SizedBox(height: constraints.maxHeight),
                      const Text('bottom text'),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('top text').hitTestable(), findsOneWidget);

        expect(find.text('bottom text'), findsOneWidget);
        expect(find.text('bottom text').hitTestable(), findsNothing);

        await tester('bottom text').scrollTo();

        expect(find.text('top text').hitTestable(), findsNothing);
        expect(find.text('bottom text').hitTestable(), findsOneWidget);
      });

      patrolWidgetTest(
        'scrolls to existing but not visible widget in Scrollable appearing late',
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

                      return ListView(
                        children: [
                          const Text('top text'),
                          SizedBox(height: constraints.maxHeight * 2),
                          const Text('bottom text'),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );

          expect(find.text('top text').hitTestable(), findsNothing);
          expect(find.text('bottom text').hitTestable(), findsNothing);

          await tester.scrollUntilExists(
            finder: find.text('top text'),
          );
          expect(find.text('top text').hitTestable(), findsOneWidget);
          expect(find.text('bottom text'), findsNothing);
          await tester.scrollUntilExists(
            finder: find.text('bottom text'),
            // defaultScrollDelta can't be used, because it not possible
            // to achieve a state, in which 'bottom text' exists, but
            // is not visible
            delta: 16,
            maxScrolls: 100,
          );

          expect(find.text('top text').hitTestable(), findsNothing);
          expect(find.text('bottom text'), findsOneWidget);
          expect(find.text('bottom text').hitTestable(), findsNothing);
        },
      );

      patrolWidgetTest(
        'scrolls to the first existing but not visible widget',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: LayoutBuilder(
                builder: (_, constraints) {
                  return ListView(
                    children: [
                      const Text('top text'),
                      SizedBox(height: constraints.maxHeight),
                      const Text('bottom text'),
                      SizedBox(height: constraints.maxHeight),
                      const Text('bottom text'),
                    ],
                  );
                },
              ),
            ),
          );

          expect(find.text('top text').hitTestable(), findsOneWidget);
          expect(find.text('bottom text'), findsNothing);

          await tester.scrollUntilExists(finder: find.text('bottom text'));

          expect(find.text('top text').hitTestable(), findsNothing);
          expect(find.text('bottom text'), findsOneWidget);
        },
      );

      patrolWidgetTest('scrolls to non-existent and not visible widget',
          ($) async {
        await $.pumpWidget(
          MaterialApp(
            home: LayoutBuilder(
              builder: (_, constraints) {
                return ListView(
                  children: [
                    const Text('top text'),
                    SizedBox(height: constraints.maxHeight),
                    const Text('bottom text'), // not built
                  ],
                );
              },
            ),
          ),
        );

        expect($('top text').visible, true);
        expect($('bottom text').visible, false);

        await $('bottom text').scrollTo();

        expect($('top text').visible, false);
        expect($('bottom text').visible, true);
      });
    });

    group('pumpAndTrySettle()', () {
      late int count;
      late int state;

      setUp(() {
        count = 0;
        state = 0;
      });

      final appWithInfiniteAnimation = MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    const CircularProgressIndicator(),
                    Text('count: $count'),
                    ElevatedButton(
                      onPressed: () => setState(() => count++),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Enabled button'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final appWithAnimationOnTap = MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text('count: $count'),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        state = 1;
                        Timer(const Duration(seconds: 5), () {
                          setState(() {
                            state = 0;
                            count++;
                          });
                        });
                      }),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: state != 0
                          ? const CircularProgressIndicator()
                          : const Text('Enabled button'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      patrolWidgetTest(
        "doesn't throw an exception when trying to settle an infinite animation",
        ($) async {
          await $.pumpWidget(appWithInfiniteAnimation);

          // 10 seconds is verbatim here to guard against changing the default
          final end =
              $.tester.binding.clock.now().add(const Duration(seconds: 10));

          await $(ElevatedButton).tap(settlePolicy: SettlePolicy.trySettle);

          // Verify that the default timeout has passed
          final now = $.tester.binding.clock.now();
          expect(now.isAfter(end), true);

          expect($('count: 1'), findsOneWidget);
        },
      );

      patrolWidgetTest('settles when there is short animation', ($) async {
        await $.pumpWidgetAndSettle(appWithAnimationOnTap);

        await $(ElevatedButton).tap(
          settlePolicy: SettlePolicy.trySettle,
          settleTimeout: const Duration(seconds: 10),
        );

        expect($('count: 1'), findsOneWidget);
      });

      patrolWidgetTest('is used by default', ($) async {
        await $.pumpWidget(appWithInfiniteAnimation);

        await $('count: 0').waitUntilVisible();
        await $(ElevatedButton).tap();
        await $('count: 1').waitUntilVisible();
      });
    });
  });
}
