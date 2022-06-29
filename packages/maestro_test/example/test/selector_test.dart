import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(
      find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('1'), findsOneWidget);

    // equivalent of #('#box1 > .ListTile > .IconButton');
    await tester.tap(
      find.descendant(
        matching: find.byType(IconButton),
        of: find.descendant(
          matching: find.byType(ListTile).first,
          of: find.byKey(const Key('box1')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2'), findsOneWidget);

    // equivalent of $('#box1 > #tile2 > .IconButton');
    await tester.tap(
      find.descendant(
        matching: find.byType(IconButton),
        of: find.descendant(
          matching: find.byKey(const Key('tile2')),
          of: find.byKey(const Key('box1')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1'), findsOneWidget);

    // equivalent of $('.Scaffold > #box1 > .ListTile > .IconButton');
    await tester.tap(
      find.descendant(
        matching: find.byType(IconButton),
        of: find.descendant(
          matching: find.byKey(const Key('tile2')),
          of: find.descendant(
            matching: find.byKey(const Key('box1')),
            of: find.byType(Scaffold),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('0'), findsOneWidget);

    final sel = $('#scaffold > #box1 > #tile2 > #icon2');
    await tester.tap(sel);
    await tester.pump();

    expect(find.text('-1'), findsOneWidget);

    await tester.tap(sel);
    await tester.pump();
    expect(find.text('-2'), findsOneWidget);
  });
}
