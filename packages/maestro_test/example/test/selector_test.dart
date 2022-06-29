import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    await tester.tap(
      find.descendant(
        matching: find.byIcon(Icons.add),
        of: find.descendant(
          matching: find.byType(ListTile).first,
          of: find.byKey(const Key('box 1')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2'), findsOneWidget);

    await tester.tap(
      find.descendant(
        matching: find.byIcon(Icons.remove),
        of: find.descendant(
          matching: find.byKey(const Key('tile 2')),
          of: find.byKey(const Key('box 1')),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
