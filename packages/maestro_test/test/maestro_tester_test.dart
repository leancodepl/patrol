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
  });
}
