import 'package:flutter/material.dart';
import 'package:patrol/src/global_state.dart' as global_state;

import '../common.dart';

String get currentTest => global_state.currentTestFullName;

void _print(String text) => print('PATROL_DEBUG: $text');

void main() {
  patrolSetUp(() async {
    await Future<void>.delayed(Duration(seconds: 1));
    _print('setUp 1 (level 1) before $currentTest');
  });

  patrolTearDown(() async {
    await Future<void>.delayed(Duration(seconds: 1));
    _print('tearDown 1 (level 1) after $currentTest');
  });

  patrolTest('testFirst', _body);

  group('groupA', () {
    patrolSetUp(() async {
      if (currentTest == 'internal.callbacks_test groupA testB') {
        throw Exception('PATROL_DEBUG: Crashing testB on purpose!');
      }
      _print('setUp 1 (level 2) before $currentTest');
    });

    patrolTearDown(() async {
      _print('tearDown 1 (level 2) after $currentTest');
    });

    patrolTest('testA', _body);
    patrolTest('testB', _body);
    patrolTest('testC', _body);
  });

  patrolTest('testLast', _body);
}

Future<void> _body(PatrolIntegrationTester $) async {
  _print('test body: name=${global_state.currentTestFullName}');

  await createApp($);

  await $(FloatingActionButton).tap();
  expect($(#counterText).text, '1');

  await $(#textField).enterText(global_state.currentTestFullName);

  await $.pumpAndSettle(duration: Duration(seconds: 2));
}
