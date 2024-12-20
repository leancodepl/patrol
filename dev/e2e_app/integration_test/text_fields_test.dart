import 'package:e2e_app/text_fields_screen.dart';
import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrol('Can enter text into same field twice', ($) async {
    await $.pumpWidgetAndSettle(const TextFieldsScreen());
    await $.pumpAndSettle();

    // Enter text into the first text field.
    await $(const Key('textField1')).enterText('User');
    await $(const Key('buttonFocus')).tap();
    expect($('User'), findsOneWidget);

    // Enter text into the first text field again. After focusing on the button.
    await $(const Key('textField1')).enterText('User2');
    await $(const Key('buttonUnfocus')).tap();
    expect($('User'), findsNothing);
    expect($('User2'), findsOneWidget);

    // Enter text into the first text field again. After unfocusing the button.
    // Then enter text into the second text field and into the first field again.
    await $(const Key('textField1')).enterText('User3');
    await $(const Key('textField2')).enterText('User4');
    await $(const Key('textField1')).enterText('User5');
    expect($('User2'), findsNothing);
    expect($('User3'), findsNothing);
    expect($('User4'), findsOneWidget);
    expect($('User5'), findsOneWidget);
  });
}
