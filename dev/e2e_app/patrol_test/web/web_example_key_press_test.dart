import 'package:flutter/material.dart';

import '../common.dart';

import 'web_example_app.dart';

String _getTextFieldValue(PatrolIntegrationTester $) {
  final editableText =
      $(EditableText).evaluate().first.widget as EditableText;
  return editableText.controller.text;
}

void main() {
  patrol('key press and key combo', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    // Tap the TextField to focus it
    await $(TextField).scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    // Type individual characters using pressKey
    await $.platform.web.pressKey(key: 'a');
    await $.platform.web.pressKey(key: 'b');
    await $.platform.web.pressKey(key: 'c');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(_getTextFieldValue($), 'abc');

    // Backspace deletes the last character
    await $.platform.web.pressKey(key: 'Backspace');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(_getTextFieldValue($), 'ab');

    // Shift+ArrowLeft selects the last character, then typing replaces it
    await $.platform.web.pressKeyCombo(keys: ['Shift', 'ArrowLeft']);
    await $.platform.web.pressKey(key: 'X');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(_getTextFieldValue($), 'aX');

    // Type more characters and verify
    await $.platform.web.pressKey(key: '1');
    await $.platform.web.pressKey(key: '2');
    await $.platform.web.pressKey(key: '3');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(_getTextFieldValue($), 'aX123');
  });
}
