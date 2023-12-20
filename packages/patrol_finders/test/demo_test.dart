import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/src/custom_finders/custom_finders.dart';

void main() {
  final app = MaterialApp(
    home: Row(
      children: [
        const Icon(Icons.front_hand, key: ValueKey({'key': 'icon'})),
        const Text('Hello', key: Key('helloText')),
        TextButton(
          onPressed: () {
            final up = Exception('This is an exception');
            throw up; // haha
          },
          child: const Text('button'),
        ),
      ],
    ),
  );

  patrolWidgetTest('find by key', ($) async {
    await $.pumpWidget(app);

    //await $.enterText($(#nonExistentTextField), 'username');
    // exit(69);

    expect($(#helloText), findsOneWidget);
    expect($(const Symbol('helloText')), findsOneWidget);
    expect($(const Key('helloText')), findsOneWidget);

    expect($(const ValueKey({'key': 'icon'})), findsOneWidget);
    expect($(const ValueKey({'key': 'icon1'})), findsNothing);
  });

  patrolWidgetTest('bad app that throws exception', ($) async {
    await $.pumpWidget(app);
    await $('button').tap();
  });
}
