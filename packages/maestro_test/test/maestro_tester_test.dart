import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/src/custom_finders/custom_finders.dart';

void main() {
  
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
