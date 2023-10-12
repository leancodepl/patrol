import 'package:flutter/material.dart';
import 'package:patrol/src/extensions.dart';
// ignore: implementation_imports
import 'package:patrol/src/logs.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

import '../common.dart';

String get currentTest => Invoker.current!.fullCurrentTestName();

void main() {
  group('parent', () {
    patrolSetUpAll(() async {
      await Future<void>.delayed(Duration(seconds: 1));
      patrolDebug('setting up all (1) before $currentTest');
    });

    patrolSetUpAll(() async {
      await Future<void>.delayed(Duration(seconds: 1));
      patrolDebug('setting up all (2) before $currentTest');
    });

    patrolTest('testA', nativeAutomation: true, _body);
    patrolTest('testB', nativeAutomation: true, _body);
    patrolTest('testC', nativeAutomation: true, _body);
  });
}

Future<void> _body(PatrolTester $) async {
  final testName = Invoker.current!.fullCurrentTestName();
  patrolDebug('test body: name=$testName');

  await createApp($);

  await $(FloatingActionButton).tap();
  expect($(#counterText).text, '1');

  await $(#textField).enterText(testName);

  await $.pumpAndSettle(duration: Duration(seconds: 2));
}
