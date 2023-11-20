import 'package:flutter/material.dart';
import 'package:patrol/src/extensions.dart';
// ignore: depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

import '../common.dart';

String get currentTest => Invoker.current!.fullCurrentTestName();

void _print(String text) => print('TEST_DEBUG: $text');

void main() {
  group('parent', () {
    patrolSetUpAll(() async {
      await Future<void>.delayed(Duration(seconds: 1));
      _print('ran patrolSetUpAll (1) before "$currentTest"');
    });

    patrolSetUpAll(() async {
      await Future<void>.delayed(Duration(seconds: 1));
      _print('ran patrolSetUpAll (2) before "$currentTest"');
    });

    patrolTest('testA', _body);
    patrolTest('testB', _body);
    patrolTest('testC', _body);
  });
}

Future<void> _body(PatrolIntegrationTester $) async {
  final testName = Invoker.current!.fullCurrentTestName();
  _print('ran body of test "$testName"');

  await createApp($);

  await $(FloatingActionButton).tap();
  expect($(#counterText).text, '1');

  await $(#textField).enterText(testName);
}
