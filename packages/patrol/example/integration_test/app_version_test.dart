import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  // This test must be run with correct build-name (1.2.3) and
  // build-number (123) flags.
  patrolTest('displays correct app version', ($) async {
    const key = Key('homePage_appVersion');

    await $.pumpWidgetAndSettle(const MyApp());

    await $(key).waitUntilVisible();

    expect($(key).text, equals('App version: 1.2.3+123'));
  }, skip: true);
}
