import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_test/src/custom_finders/custom_finders.dart';

// See how finders are tested in `package:flutter_test`:
// https://github.com/flutter/flutter/blob/master/packages/flutter_test/test/finders_test.dart

void main() {
  group('PatrolFinder', () {
    group("works identically to Flutter's finders (1)", () {
      patrolTest('(simple case 1)', ($) async {
        final flutterFinder = find.byType(Text);
        final patrolFinder = $(Text);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolTest('(simple case 2)', ($) async {
        final flutterFinder = find.byKey(const Key('someKey'));
        final patrolFinder = $(#someKey);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolTest('(simple case 3)', ($) async {
        final flutterFinder = find.byIcon(Icons.home);
        final patrolFinder = $(Icons.home);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolTest('(complex case 1)', ($) async {
        final flutterFinder = find.descendant(
          of: find.byType(Container),
          matching: find.byType(Text),
        );

        final patrolFinder = $(Container).$(Text);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolTest('(complex case 2)', ($) async {
        final flutterFinder = find.descendant(
          of: find.descendant(
            of: find.byType(MaterialApp),
            matching: find.byType(Container),
          ),
          matching: find.byType(Text),
        );

        final patrolFinder = $(MaterialApp).$(Container).$(Text);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolTest('(complex case 3)', ($) async {
        final flutterFinder = find.descendant(
          of: find.ancestor(
            of: find.text('layer'),
            matching: find.byType(MaterialApp),
          ),
          matching: find.byKey(const Key('SomeKey')),
        );

        final patrolFinder = $(MaterialApp).containing('layer').$(#SomeKey);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolTest('(complex case 4)', ($) async {
        final flutterFinder = find.ancestor(
          of: find.ancestor(
            of: find.byKey(const Key('SomeKey')),
            matching: find.text('layer'),
          ),
          matching: find.byType(MaterialApp),
        );

        final patrolFinder =
            $(MaterialApp).containing($('layer').containing(#SomeKey));

        expect(flutterFinder.toString(), patrolFinder.toString());
      });
    });

    group("works identically to Flutter's finders (1)", () {
      Future<void> pump(PatrolTester $) async {
        await $.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: Text('data'),
          ),
        );
      }

      patrolTest('first', ($) async {
        await pump($);
        expect($(Text).first.toString(), find.byType(Text).first.toString());
        expect(
          $('data').first.toString(),
          find.text('data', findRichText: true).first.toString(),
        );
      });

      patrolTest('last', ($) async {
        await pump($);
        expect($(Text).last.toString(), find.byType(Text).last.toString());
        expect(
          $('data').last.toString(),
          find.text('data', findRichText: true).last.toString(),
        );
      });

      patrolTest('at index', ($) async {
        await pump($);
        expect($(Text).at(0).toString(), find.byType(Text).at(0).toString());
        expect(
          $('data').at(0).toString(),
          find.text('data', findRichText: true).at(0).toString(),
        );
      });
    });

    group('text', () {
      patrolTest('throws StateError if no widget is found', ($) async {
        await $.pumpWidget(const MaterialApp());
        expect(() => $('some text').text, throwsStateError);
      });

      patrolTest(
        'throws Exception if the first found widget is not Text or RichText',
        ($) async {
          await $.pumpWidget(
            const MaterialApp(
              home: SizedBox(key: Key('someKey')),
            ),
          );

          expect(() => $(#someKey).text, throwsException);
        },
      );

      patrolTest(
        'returns data when the first found widget is Text',
        ($) async {
          await $.pumpWidget(
            const MaterialApp(
              home: Text(
                'some data',
                key: Key('someKey'),
              ),
            ),
          );

          expect($(#someKey).text, 'some data');
        },
      );

      patrolTest(
        'returns data when the first found widget is RichText',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: RichText(
                key: const Key('someKey'),
                text: const TextSpan(
                  text: 'some data',
                  children: [
                    TextSpan(text: 'some data in child'),
                  ],
                ),
              ),
            ),
          );

          expect($(#someKey).text, 'some datasome data in child');
        },
      );
    });

    group('tap', () {
      patrolTest(
        'throws exception when no widget to tap on is found',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').tap,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolTest('taps on widget and pumps', ($) async {
        var count = 0;
        await $.pumpWidget(
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

        await $('Tap').tap();
        expect($('count: 1'), findsOneWidget);
      });

      patrolTest('taps on the first widget by default and pumps', ($) async {
        var count = 0;
        await $.pumpWidget(
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

        await $('Tap').tap();
        expect($('count: 1'), findsOneWidget);
      });
    });

    group('enterText', () {
      patrolTest(
        'throws exception when no widget to enter text in is found',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            () => $('some text').enterText('some text'),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolTest(
        'throws StateError when widget is not EditableText',
        ($) async {
          await $.pumpWidget(
            const MaterialApp(
              home: Text('not a TextField'),
            ),
          );

          await expectLater(
            () => $('not a TextField').enterText('some text'),
            throwsStateError,
          );
        },
      );

      patrolTest(
        'enters text when the target widget has EditableText descendant',
        ($) async {
          var content = '';

          await $.pumpWidgetAndSettle(
            MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (state, setState) => Column(
                    key: const Key('columnKey'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('You entered: $content'),
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

          await $(#columnKey).enterText('some input');
          expect($('You entered: some input'), findsOneWidget);
        },
      );

      patrolTest('enters text in widget and pumps', ($) async {
        var content = '';
        await $.pumpWidgetAndSettle(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (state, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('You entered: $content'),
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

        await $(TextField).enterText('some input');
        expect($('You entered: some input'), findsOneWidget);
      });

      patrolTest(
        'enters text in the first widget by default and pumps',
        ($) async {
          var content = '';
          await $.pumpWidgetAndSettle(
            MaterialApp(
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (state, setState) => Column(
                    children: [
                      Text('You entered: $content'),
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

          await $(TextField).enterText('some text');
          expect($('You entered: some text'), findsOneWidget);
        },
      );
    });

    group('waitUntilExists', () {
      patrolTest(
        'throws exception when no widget is found within timeout',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').waitUntilExists,
            throwsA(isA<WaitUntilExistsTimeoutException>()),
          );
        },
      );

      patrolTest('waits until widget exists', ($) async {
        await $.pumpWidget(
          MaterialApp(
            home: FutureBuilder(
              future: Future<void>.delayed(const Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const Text('done');
                } else {
                  return const Text('in progress');
                }
              },
            ),
          ),
        );

        expect($('done').visible, false);

        await $('done').waitUntilExists();

        expect($('done').visible, true);
      });
    });

    group('waitUntilVisible', () {
      patrolTest(
        'throws exception when no visible widget is found within timeout',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').waitUntilVisible,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolTest('waits until widget is visible', ($) async {
        await $.pumpWidget(
          MaterialApp(
            home: FutureBuilder(
              future: Future<void>.delayed(const Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const Text('done');
                } else {
                  return const Text('in progress');
                }
              },
            ),
          ),
        );

        expect($('done').visible, false);
        await $('done').waitUntilVisible();
        expect($('done').visible, true);
      });
    });

    group('scrollTo', () {
      patrolTest(
        'throws exception when no Scrollable is found within timeout',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').waitUntilVisible,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolTest(
        'throws StateError when no widget is found after reaching maxScrolls',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: ListView(
                children: const [Text('one'), Text('two')],
              ),
            ),
          );

          await expectLater(
            $('three').scrollTo,
            throwsStateError,
          );
        },
      );

      patrolTest('scrolls to existing and visible widget', ($) async {
        await $.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              child: Column(
                children: const [Text('some text')],
              ),
            ),
          ),
        );

        expect($('some text').visible, true);

        await $('some text').scrollTo();

        expect($('some text').visible, true);
      });

      patrolTest(
        'scrolls to existing and visible widget in the first Scrollable',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: LayoutBuilder(
                builder: (_, constraints) {
                  return Column(
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
                  );
                },
              ),
            ),
          );

          expect($('text 1').visible, true);
          expect($('text 2').visible, true);

          await $('text 1').scrollTo();
          await $('text 2').scrollTo();

          expect($('text 1').visible, true);
          expect($('text 2').visible, true);
        },
      );

      patrolTest(
        'scrolls to existing and visible widget in the first Scrollable when '
        'many same widgets are present',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: LayoutBuilder(
                builder: (_, constraints) {
                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: const [
                            Text('text 1'),
                            Text('text 1'),
                          ],
                        ),
                      ),
                      const SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text('text 1'),
                      ),
                    ],
                  );
                },
              ),
            ),
          );

          expect($(Column).$('text 1').visible, true);

          await $('text 1').scrollTo();

          expect($('text 1').visible, true);
        },
      );

      patrolTest('scrolls to existing but not visible widget', ($) async {
        await $.pumpWidget(
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

        expect($('top text').visible, true);

        expect($('bottom text').exists, true);
        expect($('bottom text').visible, false);

        await $('bottom text').scrollTo();

        expect($('top text').visible, false);
        expect($('bottom text').visible, true);
      });

      patrolTest(
        'scrolls to existing but not visible widget in Scrollable appearing late',
        ($) async {
          await $.pumpWidget(
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
                            SizedBox(height: constraints.maxHeight),
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

          expect($('top text').exists, false);
          expect($('bottom text').exists, false);

          await $('top text').scrollTo();
          await $('bottom text').scrollTo();

          expect($('top text').visible, false);
          expect($('bottom text').visible, true);
        },
      );

      patrolTest(
        'scrolls to the first existing but not visible widget',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: LayoutBuilder(
                builder: (_, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text('top text'),
                        SizedBox(height: constraints.maxHeight),
                        const Text('bottom text'),
                        const Text('bottom text'),
                      ],
                    ),
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
        },
      );

      patrolTest('scrolls to non-existent and not visible widget', ($) async {
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
  });

  group('ActionCombiner', () {
    group('tap', () {
      patrolTest('can be chained with scrollTo', ($) async {
        var count = 0;

        await $.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('count: $count'),
                      GestureDetector(
                        child: const Text('Tap'),
                        onTap: () => setState(() => count++),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await $('Tap').scrollTo().tap();
        expect($('count: 1'), findsOneWidget);
      });
    });

    group('enterText', () {
      patrolTest('can be chained with scrollTo', ($) async {
        var content = '';

        await $.pumpWidgetAndSettle(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (state, setState) => SingleChildScrollView(
                  child: Column(
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
          ),
        );

        await $(TextField).scrollTo().enterText('some input');
        expect($('content: some input'), findsOneWidget);
      });
    });
  });
}
