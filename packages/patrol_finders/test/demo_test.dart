import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/src/custom_finders/custom_finders.dart';

void main() {
  const app = MaterialApp(
    home: Row(
      children: [
        Icon(Icons.front_hand, key: ValueKey({'key': 'icon'})),
        Text('Hello', key: Key('helloText')),
      ],
    ),
  );

  patrolWidgetTest('find by key', ($) async {
    await $.pumpWidget(app);

    expect($(#helloText), findsOneWidget);
    expect($(const Symbol('helloText')), findsOneWidget);
    expect($(const Key('helloText')), findsOneWidget);

    expect($(const ValueKey({'key': 'icon'})), findsOneWidget);
    expect($(const ValueKey({'key': 'icon1'})), findsNothing);
  });
}
