import 'package:flutter/material.dart';
import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

import '../common.dart';

String get currentTest => Invoker.current!.fullCurrentTestName();

void _print(String text) => print('PATROL_DEBUG: $text');

void main() {
  patrolSetUpAll(() async {
    await Future<void>.delayed(Duration(seconds: 1));
    _print('setting up all before $currentTest');
  });

  patrolTest('testA', nativeAutomation: true, _body);
  patrolTest('testB', nativeAutomation: true, _body);
  patrolTest('testC', nativeAutomation: true, _body);
}

Future<void> _body(PatrolTester $) async {
  final testName = Invoker.current!.fullCurrentTestName();
  _print('test body: name=$testName');

  await createApp($);

  await $(FloatingActionButton).tap();
  expect($(#counterText).text, '1');

  await $(#textField).enterText(testName);

  await $.pumpAndSettle(duration: Duration(seconds: 2));
}
