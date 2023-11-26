import 'package:flutter/material.dart';
import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

import '../common.dart';

String get currentTest => Invoker.current!.fullCurrentTestName();

void _print(String text) => print('TEST_DEBUG: $text');

void main() {
  patrolSetUp(() async {
    await Future<void>.delayed(Duration(seconds: 1));
    _print('ran patrolSetUp (1) up before "$currentTest"');
  });

  patrolTearDown(() async {
    await Future<void>.delayed(Duration(seconds: 1));
    _print('ran patrolTearDown (1) after "$currentTest"');
  });

  patrolTest('testFirst', _body);

  group('groupA', () {
    patrolSetUp(() async {
      if (currentTest == 'internal.callbacks_test groupA testB') {
        throw Exception('TEST_DEBUG: "$currentTest" crashed on purpose');
      }

      _print('ran patrolSetUp (2) before "$currentTest"');
    });

    patrolTearDown(() async {
      _print('ran patrolTearDown (2) after "$currentTest"');
    });

    patrolTest('testA', _body);
    patrolTest('testB', _body);
    patrolTest('testC', _body);
  });

  patrolTest('testLast', _body);
}

Future<void> _body(PatrolIntegrationTester $) async {
  final testName = Invoker.current!.fullCurrentTestName();
  _print('ran body of test "$testName"');

  await createApp($);

  await $(FloatingActionButton).tap();
  expect($(#counterText).text, '1');

  await $(#textField).enterText(testName);

  await $.pumpAndSettle(duration: Duration(seconds: 2));
}
