import 'package:e2e_app/cursor_blink_screen.dart';
import 'package:e2e_app/keys.dart';
import 'package:flutter/foundation.dart';

import 'common.dart';

Future<void> _tapWhileFocused(PatrolIntegrationTester $, Key field) async {
  await $.pumpWidgetAndSettle(const CursorBlinkScreen());
  await $(field).tap();

  // A blinking cursor used to keep this settle busy for several seconds.
  await $(K.cursorBlinkCounterButton).tap(
    settlePolicy: SettlePolicy.settle,
    settleTimeout: const Duration(seconds: 2),
  );

  expect($('taps: 1'), findsOneWidget);
}

void main() {
  patrol(
    'settles quickly while a Material TextField is focused',
    ($) => _tapWhileFocused($, K.materialTextField),
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );

  patrol(
    'settles quickly while a CupertinoTextField is focused',
    ($) => _tapWhileFocused($, K.cupertinoTextField),
    tags: ['android', 'emulator', 'ios', 'simulator'],
  );
}
