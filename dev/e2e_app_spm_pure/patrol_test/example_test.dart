import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('app launches', ($) async {
    await $.pumpWidgetAndSettle(
      const MaterialApp(home: Scaffold(body: Text('hello spm'))),
    );
    expect(find.text('hello spm'), findsOneWidget);
  });
}
