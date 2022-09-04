import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/custom_finders.dart';

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

      expect(tester('count: 1'), findsOneWidget);
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
        expect(tester('count: 1'), findsOneWidget);
      },
    );
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
          tester.enterText(find.text('not a TextField'), 'some text'),
          throwsStateError,
        );
      },
    );

    maestroTest(
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

  group('dragUntilExists', () {
    maestroTest(
      'throws exception when no Scrollable is found within timeout',
      ($) async {
        await $.pumpWidget(const MaterialApp());

        await expectLater(
          () => $.dragUntilExists(
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
      ($) async {
        await $.pumpWidget(
          MaterialApp(
            home: ListView(
              children: const [Text('one'), Text('two')],
            ),
          ),
        );

        await expectLater(
          () => $.dragUntilExists(
            finder: find.text('three'),
            view: find.byType(Scrollable),
            moveStep: const Offset(0, 16),
          ),
          throwsStateError,
        );
      },
    );

    maestroTest('drags to existing and visible widget', ($) async {
      await $.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: const [Text('some text')],
            ),
          ),
        ),
      );

      expect($('some text').exists, true);
      expect($('some text').visible, true);

      await $.dragUntilExists(
        finder: find.text('some text'),
        view: find.byType(Scrollable),
        moveStep: const Offset(0, 16),
      );

      expect($('some text').visible, true);
      expect($('some text').visible, true);
    });

    maestroTest(
      'drags to existing and visible widget in the first Scrollable',
      ($) async {
        await $.pumpWidget(
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

        expect($('text 1').visible, true);
        expect($('text 2').visible, true);

        await $.dragUntilExists(
          finder: find.text('text 1'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, 16),
        );

        expect($('text 1').visible, true);
        expect($('text 2').visible, true);

        await $.dragUntilExists(
          finder: find.text('text 2'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, 16),
        );

        expect($('text 1').visible, true);
        expect($('text 2').visible, true);
      },
    );

    maestroTest(
      'drags to the first existing widget in the first Scrollable',
      ($) async {
        await $.pumpWidget(
          MaterialApp(
            home: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: const [
                  Text('text 1'),
                  Text('text 1'),
                ],
              ),
            ),
          ),
        );

        expect($('text 1').visible, true);

        await $.dragUntilExists(
          finder: find.text('text 1'),
          view: find.byType(Scrollable),
          moveStep: const Offset(0, 16),
        );

        expect($('text 1').visible, true);
      },
    );
  });
}
