import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/custom_finders.dart';

// See how finders are tested in `package:flutter_test`:
// https://github.com/flutter/flutter/blob/master/packages/flutter_test/test/finders_test.dart

void main() {
  group('Maestro finders work the same as Flutter finders (1)', () {
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

    maestroTest('(simple case 3)', ($) async {
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

  group('Maestro finders work the same as Flutter finders (2)', () {
    Future<void> pump(MaestroTester $) async {
      await $.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Text('data'),
        ),
      );
    }

    maestroTest('first', ($) async {
      await pump($);
      expect($(Text).first.toString(), find.byType(Text).first.toString());
      expect(
        $('data').first.toString(),
        find.text('data', findRichText: true).first.toString(),
      );
    });

    maestroTest('last', ($) async {
      await pump($);
      expect($(Text).last.toString(), find.byType(Text).last.toString());
      expect(
        $('data').last.toString(),
        find.text('data', findRichText: true).last.toString(),
      );
    });

    maestroTest('at index', ($) async {
      await pump($);
      expect($(Text).at(0).toString(), find.byType(Text).at(0).toString());
      expect(
        $('data').at(0).toString(),
        find.text('data', findRichText: true).at(0).toString(),
      );
    });
  });

  group('waitUntilExists', () {
    maestroTest(
      'throws exception when no widget is found within timeout',
      ($) async {
        await $.pumpWidget(const MaterialApp());

        await expectLater(
          $('some text').waitUntilExists,
          throwsA(isA<WaitUntilExistsTimedOutException>()),
        );
      },
    );

    maestroTest('waits until widget exists', ($) async {
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

  group('tap', () {
    maestroTest(
      'throws exception when no widget to tap on is found',
      ($) async {
        await $.pumpWidget(const MaterialApp());

        await expectLater(
          $('some text').tap,
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
    );

    maestroTest('taps on widget and pumps', ($) async {
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

    maestroTest('taps on the first widget by default and pumps', ($) async {
      var firstCount = 0;
      var secondCount = 0;

      await $.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (state, setState) => Column(
              children: [
                Text('firstCount: $firstCount'),
                GestureDetector(
                  onTap: () => setState(() => firstCount++),
                  child: const Text('Tap'),
                ),
                Text('secondCount: $secondCount'),
                GestureDetector(
                  onTap: () => setState(() => secondCount++),
                  child: const Text('Tap'),
                ),
              ],
            ),
          ),
        ),
      );

      await $('Tap').tap();
      expect($('firstCount: 1'), findsOneWidget);
    });
  });
  group('enterText', () {
    maestroTest(
      'throws exception when no widget to enter text in is found',
      ($) async {
        await $.pumpWidget(const MaterialApp());

        await expectLater(
          () => $('some text').enterText('some text'),
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
    );

    maestroTest('enters text in widget and pumps', ($) async {
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
                    onChanged: (newValue) => setState(() => content = newValue),
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

    maestroTest(
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

  group('waitUntilVisible', () {
    maestroTest(
      'throws exception when no visible widget is found within timeout',
      ($) async {
        await $.pumpWidget(const MaterialApp());

        await expectLater(
          $('some text').waitUntilVisible,
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
    );

    maestroTest('waits until widget is visible', ($) async {
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
    maestroTest(
      'throws exception when no Scrollable is found within timeout',
      ($) async {
        await $.pumpWidget(const MaterialApp());

        await expectLater(
          $('some text').waitUntilVisible,
          throwsA(isA<WaitUntilVisibleTimedOutException>()),
        );
      },
    );

    maestroTest(
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

    maestroTest('scrolls to existing and visible widget', ($) async {
      await $.pumpWidget(
        MaterialApp(
          home: LayoutBuilder(
            builder: (_, constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: const [Text('some text')],
                ),
              );
            },
          ),
        ),
      );

      expect($('some text').exists, true);
      expect($('some text').visible, true);

      await $('some text').scrollTo();

      expect($('some text').visible, true);
      expect($('some text').visible, true);
    });

    maestroTest(
      'scrolls to existing and visible widget in first Scrollable',
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

        expect($('text 1').exists, true);
        expect($('text 2').visible, true);

        await $('text 1').scrollTo();
        await $('text 2').scrollTo();

        expect($('text 1').visible, true);
        expect($('text 2').visible, true);
      },
    );

    maestroTest('scrolls to existing but not visible widget', ($) async {
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

      expect($('top text').exists, true);
      expect($('top text').visible, true);

      expect($('bottom text').exists, true);
      expect($('bottom text').visible, false);

      await $('bottom text').scrollTo();

      expect($('top text').visible, false);
      expect($('bottom text').visible, true);
    });

    maestroTest(
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
        expect($('top text').visible, false);

        expect($('bottom text').exists, false);
        expect($('bottom text').visible, false);

        await $('top text').scrollTo();
        await $('bottom text').scrollTo();

        expect($('top text').visible, false);
        expect($('bottom text').visible, true);
      },
    );

    maestroTest('scrolls  to non-existent and non-visible widget', ($) async {
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

      expect($('top text').exists, true);
      expect($('top text').visible, true);

      expect($('bottom text').exists, false);
      expect($('bottom text').visible, false);

      await $('bottom text').scrollTo();

      expect($('bottom text').exists, true);
      expect($('bottom text').visible, true);
    });
  });
}
