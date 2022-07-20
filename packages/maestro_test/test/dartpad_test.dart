import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestro_test/maestro_test.dart';

void main() {
  maestroTest('when does the finder evaluate?', ($) async {
    final finder = find.text('Hello');
    print('here');
    await smallPump($);

    //expect(finder, findsOneWidget);
  });
}

Future<void> smallPump(MaestroTester $) async {
  await $.pumpWidgetAndSettle(
    MaterialApp(
      home: Row(
        children: const [
          Icon(Icons.front_hand),
          Text('Hello'),
        ],
      ),
    ),
  );
}
