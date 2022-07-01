import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  maestroTest('Counter increments smoke test', ($) async {
    await $.pumpWidgetAndSettle(const MyApp());

    // equivalent of await $(ListTile).$(Icons.add).tap();
    await $.tester.tap(
      find.descendant(
        of: find.byType(ListTile).first,
        matching: find.byIcon(Icons.add),
      ),
    );
    await $.tester.pump();

    expect($('1'), findsOneWidget);

    // equivalent of $(#box1).$(ListTile).$(IconButton).tap();
    await $.tester.tap(
      find.descendant(
        matching: find.byType(IconButton),
        of: find.descendant(
          matching: find.byType(ListTile).first,
          of: find.byKey(const Key('box1')),
        ),
      ),
    );
    await $.tester.pump();

    expect($('2'), findsOneWidget);

    // equivalent of $(#box1).$(#tile2).$(IconButton).tap();
    await $.tester.tap(
      find.descendant(
        matching: find.byType(IconButton),
        of: find.descendant(
          matching: find.byKey(const Key('tile2')),
          of: find.byKey(const Key('box1')),
        ),
      ),
    );
    await $.tester.pump();

    expect($('1'), findsOneWidget);

    // equivalent of $(Scaffold).$(#box1).$(ListTile).$(IconButton).tap();
    await $.tester.tap(
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
    await $.tester.pump();

    expect($('0'), findsOneWidget);

    final sel1V1 = $(Scaffold).$(#box1).$(#tile2).$(#icon2);
    final sel1V2 = $(#box1).$(#tile2).$(#icon2);
    final sel1V3 = $(#box1).$(#tile2).$(IconButton);
    final sel2 = $(#box1).$(ListTile).withDescendant(#icon1);
    final sel3 = $(ListTile).withDescendant('Add');

    await sel1V1.tap();
    expect($('-1'), findsOneWidget);

    await sel1V2.tap();
    expect($('-2'), findsOneWidget);

    await sel1V3.tap();
    expect($('-3'), findsOneWidget);

    await sel1V3.tap();
    expect($('-4'), findsOneWidget);

    await sel1V3.tap();
    expect($('-5'), findsOneWidget);

    await sel1V3.tap();
    expect($('-6'), findsOneWidget);

    await sel2.tap();
    expect($('4'), findsOneWidget);

    await sel3.tap();
    expect($('14'), findsOneWidget);
  });
}
