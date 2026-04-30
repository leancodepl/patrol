import 'dart:io';

import 'package:e2e_app/keys.dart';
import 'common.dart';

final _iosTextInputActions = TextInputAction.values
    .where(
      (action) =>
          action != TextInputAction.none && action != TextInputAction.previous,
    )
    .toList();
final _androidTextInputActions = TextInputAction.values
    .where(
      (action) =>
          action != TextInputAction.continueAction &&
          action != TextInputAction.join &&
          action != TextInputAction.route &&
          action != TextInputAction.emergencyCall,
    )
    .toList();

void main() {
  patrol(
    'mobile keyboard enter on text fields',
    ($) async {
      final textInputActions = Platform.isAndroid
          ? _androidTextInputActions
          : _iosTextInputActions;

      await createApp($);

      await $(K.textfieldsScreenButton).scrollTo().tap();

      for (var index = 0; index < textInputActions.length; index++) {
        final textField = $(K.textFields[index]);
        await textField.scrollTo().enterText(
          'test_${textInputActions[index].name}',
        );
        await textField.tap();
        await Future<void>.delayed(const Duration(seconds: 1));
        await $.platform.mobile.sendKeyboardEnter();
      }
    },
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
