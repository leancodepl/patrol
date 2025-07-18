// It's just a test. We can ignore this rule here.
// ignore_for_file: avoid_single_child_in_multi_child_widgets
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/src/custom_finders/custom_finders.dart';

import 'utils/long_screen_with_partially_visible_widget.dart';
import 'utils/screen_with_partially_visible_widget.dart';
import 'utils/set_physical_size.dart';
import 'utils/text_fields_screen.dart';

// See how finders are tested in `package:flutter_test`:
// https://github.com/flutter/flutter/blob/master/packages/flutter_test/test/finders_test.dart

void main() {
  group('PatrolFinder', () {
    group('finds widget by', () {
      const app = MaterialApp(
        home: Row(
          children: [
            Icon(Icons.front_hand, key: ValueKey({'key': 'icon'})),
            Text('Hello', key: Key('helloText')),
          ],
        ),
      );

      patrolWidgetTest('type', ($) async {
        await $.pumpWidget(app);
        expect($(Text), findsOneWidget);
        expect($(Icon), findsOneWidget);
        expect($(Row), findsOneWidget);
      });

      patrolWidgetTest('key', ($) async {
        await $.pumpWidget(app);

        expect($(#helloText), findsOneWidget);
        expect($(const Symbol('helloText')), findsOneWidget);
        expect($(const Key('helloText')), findsOneWidget);

        expect($(const ValueKey({'key': 'icon'})), findsOneWidget);
        expect($(const ValueKey({'key': 'icon1'})), findsNothing);
      });

      patrolWidgetTest('text', ($) async {
        await $.pumpWidget(app);
        expect($('Hello'), findsOneWidget);
      });

      patrolWidgetTest('text it contains', ($) async {
        await $.pumpWidget(app);
        expect($(RegExp('Hello')), findsOneWidget);
        expect($(RegExp('Hell.*')), findsOneWidget);
        expect($(RegExp('.*ello')), findsOneWidget);
        expect($(RegExp('.*ell.*')), findsOneWidget);
      });

      patrolWidgetTest('icon', ($) async {
        await $.pumpWidget(app);
        expect($(Icons.front_hand), findsOneWidget);
      });

      patrolWidgetTest('widget', ($) async {
        await $.pumpWidget(app);
        final widget = $('Hello').evaluate().first.widget;
        expect($(widget), findsOneWidget);
      });

      patrolWidgetTest('text using PatrolFinder', ($) async {
        await $.pumpWidget(app);
        expect($('Hello'), findsOneWidget);
      });

      patrolWidgetTest('text using 2 nested PatrolFinders', ($) async {
        await $.pumpWidget(app);
        expect($($('Hello')), findsOneWidget);
      });

      patrolWidgetTest('text using many nested PatrolFinders', ($) async {
        await $.pumpWidget(app);
        expect($($($($($('Hello'))))), findsOneWidget);
      });

      patrolWidgetTest('text using Flutter Finder', ($) async {
        await $.pumpWidget(app);
        expect($(find.text('Hello')), findsOneWidget);
      });

      patrolWidgetTest('invalid type and throws error', ($) async {
        await $.pumpWidget(app);
        expect(() => $(<String, dynamic>{}), throwsArgumentError);
      });
    });

    group("works identically to Flutter's finders (1)", () {
      patrolWidgetTest('(simple case 1)', ($) async {
        final flutterFinder = find.byType(Text);
        final patrolFinder = $(Text);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolWidgetTest('(simple case 2)', ($) async {
        final flutterFinder = find.byKey(const Key('someKey'));
        final patrolFinder = $(#someKey);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolWidgetTest('(simple case 3)', ($) async {
        final flutterFinder = find.byIcon(Icons.home);
        final patrolFinder = $(Icons.home);

        expect(flutterFinder.toString(), patrolFinder.toString());
      });

      patrolWidgetTest('(complex case 1)', ($) async {
        final flutterFinder = find.descendant(
          of: find.byType(Container),
          matching: find.byType(Text),
        );

        final patrolFinder = $(Container).$(Text);

        expect(flutterFinder.toString(), patrolFinder.toString());
        expect(
          flutterFinder.toString(describeSelf: true),
          patrolFinder.toString(describeSelf: true),
        );
      });

      patrolWidgetTest('(complex case 2)', ($) async {
        final flutterFinder = find.descendant(
          of: find.descendant(
            of: find.byType(MaterialApp),
            matching: find.byType(Container),
          ),
          matching: find.byType(Text),
        );

        final patrolFinder = $(MaterialApp).$(Container).$(Text);

        expect(flutterFinder.toString(), patrolFinder.toString());
        expect(
          flutterFinder.toString(describeSelf: true),
          patrolFinder.toString(describeSelf: true),
        );
      });

      patrolWidgetTest('(complex case 3)', ($) async {
        final flutterFinder = find.descendant(
          of: find.ancestor(
            of: find.text('layer'),
            matching: find.byType(MaterialApp),
          ),
          matching: find.byKey(const Key('SomeKey')),
        );

        final patrolFinder = $(MaterialApp).containing('layer').$(#SomeKey);

        expect(flutterFinder.toString(), patrolFinder.toString());
        expect(
          flutterFinder.toString(describeSelf: true),
          patrolFinder.toString(describeSelf: true),
        );
      });

      patrolWidgetTest('(complex case 4)', ($) async {
        final flutterFinder = find.ancestor(
          of: find.ancestor(
            of: find.byKey(const Key('SomeKey')),
            matching: find.text('layer'),
          ),
          matching: find.byType(MaterialApp),
        );

        final patrolFinder = $(
          MaterialApp,
        ).containing($('layer').containing(#SomeKey));

        expect(flutterFinder.toString(), patrolFinder.toString());
        expect(
          flutterFinder.toString(describeSelf: true),
          patrolFinder.toString(describeSelf: true),
        );
      });
    });

    group('text', () {
      patrolWidgetTest(
        'throws PatrolFinderException when no widgets are found',
        ($) async {
          await $.pumpWidget(const MaterialApp());
          expect(
            () => $('some text').text,
            throwsA(isA<PatrolFinderException>()),
          );
        },
      );

      patrolWidgetTest(
        'throws PatrolFinderException if the first widget found is not Text or RichText',
        ($) async {
          await $.pumpWidget(
            const MaterialApp(home: SizedBox(key: Key('someKey'))),
          );

          expect(() => $(#someKey).text, throwsA(isA<PatrolFinderException>()));
        },
      );

      patrolWidgetTest('returns data when the first found widget is Text', (
        $,
      ) async {
        await $.pumpWidget(
          const MaterialApp(home: Text('some data', key: Key('someKey'))),
        );

        expect($(#someKey).text, 'some data');
      });

      patrolWidgetTest('returns data when the first found widget is RichText', (
        $,
      ) async {
        await $.pumpWidget(
          MaterialApp(
            home: RichText(
              key: const Key('someKey'),
              text: const TextSpan(
                text: 'some data',
                children: [TextSpan(text: 'some data in child')],
              ),
            ),
          ),
        );

        expect($(#someKey).text, 'some datasome data in child');
      });
    });

    group('tap()', () {
      patrolWidgetTest('throws exception when no widget to tap on is found', (
        $,
      ) async {
        await $.pumpWidget(const MaterialApp());

        await expectLater(
          $('some text').tap,
          throwsA(isA<WaitUntilVisibleTimeoutException>()),
        );
      });

      patrolWidgetTest('taps on widget and pumps', ($) async {
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

      patrolWidgetTest('taps on the first widget by default and pumps', (
        $,
      ) async {
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
                  GestureDetector(onTap: () {}, child: const Text('Tap')),
                ],
              ),
            ),
          ),
        );

        await $('Tap').tap();
        expect($('count: 1'), findsOneWidget);
      });

      group('with alignment', () {
        patrolWidgetTest('finds no widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          await $.pumpWidget(
            ScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: ElevatedButton(
                onPressed: () {},
                child: const Text('some text'),
              ),
            ),
          );

          await expectLater(
            () => $(ElevatedButton).tap(alignment: Alignment.centerRight),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        });

        patrolWidgetTest('finds widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          var counter = 0;

          await $.pumpWidget(
            ScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: ElevatedButton(
                onPressed: () {
                  counter++;
                },
                child: const Text('some text'),
              ),
            ),
          );

          await $(ElevatedButton).tap(alignment: Alignment.centerLeft);

          expect(counter, 1);
        });
      });
    });

    group('longPress()', () {
      patrolWidgetTest(
        'throws exception when no widget to make longPress gesture on is found',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').longPress,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('makes longPress gesture on widget and pumps', (
        $,
      ) async {
        var count = 0;
        await $.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (state, setState) => Column(
                children: [
                  Text('count: $count'),
                  GestureDetector(
                    onLongPress: () => setState(() => count++),
                    child: const Text('Long press'),
                  ),
                ],
              ),
            ),
          ),
        );

        await $('Long press').longPress();
        expect($('count: 1'), findsOneWidget);
      });

      patrolWidgetTest(
        'makes longPress gesture on the first widget by default and pumps',
        ($) async {
          var count = 0;
          await $.pumpWidget(
            MaterialApp(
              home: StatefulBuilder(
                builder: (state, setState) => Column(
                  children: [
                    Text('count: $count'),
                    GestureDetector(
                      onLongPress: () => setState(() => count++),
                      child: const Text('Long press'),
                    ),
                    GestureDetector(
                      onLongPress: () {},
                      child: const Text('Long press'),
                    ),
                  ],
                ),
              ),
            ),
          );

          await $('Long press').longPress();
          expect($('count: 1'), findsOneWidget);
        },
      );

      group('with alignment', () {
        patrolWidgetTest('finds no widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          await $.pumpWidget(
            ScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: ElevatedButton(
                onPressed: () {},
                child: const Text('some text'),
              ),
            ),
          );

          await expectLater(
            () => $(ElevatedButton).longPress(alignment: Alignment.centerRight),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        });

        patrolWidgetTest('finds widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          var counter = 0;

          await $.pumpWidget(
            ScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: ElevatedButton(
                onLongPress: () {
                  counter++;
                },
                onPressed: () {},
                child: const Text('some text'),
              ),
            ),
          );

          await $(ElevatedButton).longPress(alignment: Alignment.centerLeft);

          expect(counter, 1);
        });
      });
    });

    group('enterText()', () {
      patrolWidgetTest(
        'throws exception when no widget to enter text in is found',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            () => $('some text').enterText('some text'),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('throws StateError when widget is not EditableText', (
        $,
      ) async {
        await $.pumpWidget(const MaterialApp(home: Text('not a TextField')));

        await expectLater(
          () => $('not a TextField').enterText('some text'),
          throwsStateError,
        );
      });

      patrolWidgetTest(
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

      patrolWidgetTest('enters text in widget and pumps', ($) async {
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

      patrolWidgetTest('enters text in the first widget by default and pumps', (
        $,
      ) async {
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
                    TextField(onChanged: (_) {}),
                  ],
                ),
              ),
            ),
          ),
        );

        await $(TextField).enterText('some text');
        expect($('You entered: some text'), findsOneWidget);
      });

      group('with alignment', () {
        patrolWidgetTest('finds no widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          await $.pumpWidget(
            const ScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: TextField(),
            ),
          );

          await expectLater(
            () => $(
              TextField,
            ).enterText('text', alignment: Alignment.centerRight),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        });

        patrolWidgetTest('finds widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          final controller = TextEditingController();

          await $.pumpWidget(
            ScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: TextField(controller: controller),
            ),
          );

          const input = 'text';

          await $(TextField).enterText(input, alignment: Alignment.centerLeft);

          expect(controller.text, input);
        });
      });
    });

    group('waitUntilExists()', () {
      patrolWidgetTest(
        'throws exception when no widget is found within timeout',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').waitUntilExists,
            throwsA(isA<WaitUntilExistsTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('waits until widget exists', ($) async {
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

    group('waitUntilVisible()', () {
      patrolWidgetTest(
        'throws exception when no visible widget is found within timeout',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').waitUntilVisible,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('waits until widget is visible', ($) async {
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

      patrolWidgetTest(
        'waits until widget is only visible at the topCenter alignment',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: FutureBuilder(
                future: Future<void>.delayed(const Duration(seconds: 3)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return const Column(
                      children: [
                        Text('some text'),
                        SizedBox(height: 60),
                        Text('some other text'),
                      ],
                    );
                  } else {
                    return const Text('in progress');
                  }
                },
              ),
            ),
          );
          await $(Column).waitUntilVisible(alignment: Alignment.topCenter);
          expect($(Column).visible, false);
          expect($(Column).isVisibleAt(alignment: Alignment.topCenter), true);
          await expectLater(
            $(Column).waitUntilVisible,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );
    });

    group('scrollTo()', () {
      patrolWidgetTest(
        'throws exception when no Scrollable is found within timeout',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          await expectLater(
            $('some text').waitUntilVisible,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest(
        'throws StateError when no widget is found after reaching maxScrolls',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: ListView(children: const [Text('one'), Text('two')]),
            ),
          );

          await expectLater(
            $('three').scrollTo,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        },
      );

      patrolWidgetTest('scrolls to existing and visible widget', ($) async {
        await $.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: Column(children: [Text('some text')]),
            ),
          ),
        );

        expect($('some text').visible, true);

        await $('some text').scrollTo();

        expect($('some text').visible, true);
      });

      patrolWidgetTest(
        'scrolls to existing and visible widget in the first Scrollable',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: LayoutBuilder(
                builder: (_, constraints) {
                  return const Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(children: [Text('text 1')]),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(children: [Text('text 2')]),
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

      patrolWidgetTest(
        'scrolls to existing and visible widget in the first Scrollable when '
        'many same widgets are present',
        ($) async {
          await $.pumpWidget(
            MaterialApp(
              home: LayoutBuilder(
                builder: (_, constraints) {
                  return const Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [Text('text 1'), Text('text 1')],
                        ),
                      ),
                      SingleChildScrollView(
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

      patrolWidgetTest('scrolls to existing but not visible widget', ($) async {
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

      patrolWidgetTest(
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

      patrolWidgetTest('scrolls to the first existing but not visible widget', (
        $,
      ) async {
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
      });

      patrolWidgetTest('scrolls to non-existent and not visible widget', (
        $,
      ) async {
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

      final app = MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: ListView(key: const Key('listView1'))),
              Expanded(
                child: ListView.builder(
                  key: const Key('listView2'),
                  itemCount: 101,
                  itemBuilder: (context, index) => Text('index: $index'),
                ),
              ),
            ],
          ),
        ),
      );

      patrolWidgetTest(
        'fails when target widget is not in the first, default Scrollable',
        ($) async {
          await $.pumpWidget(app);

          expect($('index: 1'), findsOneWidget);
          expect($('index: 100').hitTestable(), findsNothing);

          await expectLater(
            $('index: 100').scrollTo,
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
          expect($('index: 100').hitTestable(), findsNothing);
        },
      );

      patrolWidgetTest(
        'succeeds when target widget is in the second, explicitly specified Scrollable',
        ($) async {
          await $.pumpWidget(app);

          expect($('index: 1'), findsOneWidget);
          expect($('index: 100').hitTestable(), findsNothing);

          await $('index: 100').scrollTo(view: $(#listView2).$(Scrollable));

          expect($('index: 100').hitTestable(), findsOneWidget);
        },
      );

      group('with alignment', () {
        patrolWidgetTest('finds no widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          await $.pumpWidget(
            ScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: ElevatedButton(
                onPressed: () {},
                child: const Text('some text'),
              ),
            ),
          );

          await expectLater(
            () => $(ElevatedButton).scrollTo(alignment: Alignment.centerRight),
            throwsA(isA<WaitUntilVisibleTimeoutException>()),
          );
        });

        patrolWidgetTest('finds widgets', ($) async {
          const width = 300.0;
          setPhysicalSize($.tester, width);

          await $.pumpWidget(
            LongScreenWithPartiallyVisibleWidget(
              width: width,
              testedWidget: ElevatedButton(
                onPressed: () {},
                child: const Text('some text'),
              ),
            ),
          );

          expect(
            $(ElevatedButton).hitTestable(at: Alignment.centerLeft),
            findsNothing,
          );

          await $(ElevatedButton).scrollTo(alignment: Alignment.centerLeft);

          expect(
            $(ElevatedButton).hitTestable(at: Alignment.centerLeft),
            findsOneWidget,
          );
        });
      });
    });

    group('which()', () {
      late int count;

      setUp(() => count = 0);

      final app = MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  key: const Key('column'),
                  children: [
                    const Row(children: [Column()]),
                    Text('count: $count'),
                    const ElevatedButton(
                      onPressed: null,
                      child: Text('Disabled button'),
                    ),
                    const ElevatedButton(
                      onPressed: null,
                      child: Text('Disabled button'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => count++),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Enabled button'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => count += 10),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.red),
                      ),
                      child: const Text('Enabled button with color'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      patrolWidgetTest('finds button by its active status', ($) async {
        await $.pumpWidget(app);

        await $(
          ElevatedButton,
        ).which<ElevatedButton>((button) => button.enabled).tap();

        expect($('count: 1'), findsOneWidget);
      });

      patrolWidgetTest('finds button by its font size', ($) async {
        await $.pumpWidget(app);

        await $(ElevatedButton)
            .which<ElevatedButton>(
              (button) => button.style?.textStyle?.resolve({})?.fontSize == 20,
            )
            .tap();

        expect($('count: 1'), findsOneWidget);
      });

      patrolWidgetTest('finds button by its active status and color', (
        $,
      ) async {
        await $.pumpWidget(app);

        await $(ElevatedButton)
            .which<ElevatedButton>((button) => button.enabled)
            .which<ElevatedButton>(
              (btn) => btn.style?.backgroundColor?.resolve({}) == Colors.red,
            )
            .tap();

        expect($('count: 10'), findsOneWidget);
      });

      patrolWidgetTest('finds 2 buttons by their inactive status', ($) async {
        await $.pumpWidget(app);

        expect(
          $(ElevatedButton).which<ElevatedButton>((button) => !button.enabled),
          findsNWidgets(2),
        );
      });

      patrolWidgetTest('finds zero widgets if type does not match', ($) async {
        await $.pumpWidget(app);

        expect(
          $(#column).which<ElevatedButton>((button) => !button.enabled),
          findsNothing,
        );
      });

      patrolWidgetTest(
        'finds one widget if there are 2 widgets of the same type in the subtree',
        ($) async {
          await $.pumpWidget(app);

          expect(
            $(#column).which<Column>(
              (column) => column.mainAxisAlignment == MainAxisAlignment.start,
            ),
            findsOneWidget,
          );
        },
      );
    });

    group('at()', () {
      patrolWidgetTest('finds single widget at index', ($) async {
        await $.pumpWidget(
          const MaterialApp(
            home: Column(children: [Text('text'), Text('text'), Text('text')]),
          ),
        );

        expect($('text').at(0), findsOneWidget);
        expect($('text').at(1), findsOneWidget);
        expect($('text').at(2), findsOneWidget);
      });

      patrolWidgetTest("works identically to Flutter's finders", ($) async {
        await $.pumpWidget(
          const MaterialApp(home: Column(children: [Text('text')])),
        );

        expect($(Text).at(0).toString(), find.byType(Text).at(0).toString());
        expect(
          $('text').at(0).toString(),
          find.text('text', findRichText: true).at(0).toString(),
        );
      });

      patrolWidgetTest(
        'throws IndexError when widget at index does not exist',
        ($) async {
          await $.pumpWidget(const MaterialApp(home: Text('some text')));

          expect(() => $('some text').at(1), throwsA(isA<IndexError>()));
        },
      );
    });

    group('first', () {
      patrolWidgetTest('finds first widget', ($) async {
        await $.pumpWidget(
          const MaterialApp(
            home: Column(children: [Text('text'), Text('text')]),
          ),
        );

        expect($('text').first, findsOneWidget);
      });

      patrolWidgetTest("works identically to Flutter's finders", ($) async {
        await $.pumpWidget(const MaterialApp(home: Text('text')));

        expect($(Text).first.toString(), find.byType(Text).first.toString());
        expect(
          $('text').first.toString(),
          find.text('text', findRichText: true).first.toString(),
        );
      });

      patrolWidgetTest(
        'throws StateError when widget at index does not exist',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          expect(
            () => $('some text').last,
            throwsA(
              isA<StateError>().having(
                (err) => err.message,
                'message',
                'No element',
              ),
            ),
          );
        },
      );
    });

    group('last', () {
      patrolWidgetTest('finds last widget', ($) async {
        await $.pumpWidget(
          const MaterialApp(
            home: Column(children: [Text('text'), Text('text')]),
          ),
        );

        expect($('text').last, findsOneWidget);
      });

      patrolWidgetTest("works identically to Flutter's finders", ($) async {
        await $.pumpWidget(const MaterialApp(home: Text('text')));

        expect($(Text).last.toString(), find.byType(Text).last.toString());
        expect(
          $('text').last.toString(),
          find.text('text', findRichText: true).last.toString(),
        );
      });

      patrolWidgetTest(
        'throws StateError when widget at index does not exist',
        ($) async {
          await $.pumpWidget(const MaterialApp());

          expect(
            () => $('some text').last,
            throwsA(
              isA<StateError>().having(
                (err) => err.message,
                'message',
                'No element',
              ),
            ),
          );
        },
      );
    });

    patrolWidgetTest(
      'can enter text into the same field, after focusing on button',
      ($) async {
        await $.pumpWidgetAndSettle(const TextFieldsScreen());

        await $(const Key('textField1')).enterText('User');
        await $(const Key('buttonFocus')).tap();
        expect($('User'), findsOneWidget);

        await $(const Key('textField1')).enterText('User2');
        expect($('User'), findsNothing);
        expect($('User2'), findsOneWidget);
      },
    );

    patrolWidgetTest('can enter text into same field, after unfocusing', (
      $,
    ) async {
      await $.pumpWidgetAndSettle(const TextFieldsScreen());

      await $(const Key('textField1')).enterText('User2');
      await $(const Key('buttonUnfocus')).tap();
      expect($('User2'), findsOneWidget);

      await $(const Key('textField1')).enterText('User3');
      expect($('User2'), findsNothing);
      expect($('User3'), findsOneWidget);
    });

    patrolWidgetTest(
      'can enter text into same field, after entering text in another field',
      ($) async {
        await $.pumpWidgetAndSettle(const TextFieldsScreen());

        await $(const Key('textField1')).enterText('User3');
        expect($('User3'), findsOneWidget);

        await $(const Key('textField2')).enterText('User4');
        await $(const Key('textField1')).enterText('User5');
        expect($('User3'), findsNothing);
        expect($('User4'), findsOneWidget);
        expect($('User5'), findsOneWidget);
      },
    );
  });
}
