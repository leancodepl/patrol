import 'package:flutter/material.dart';

import '../common.dart';

import 'web_example_app.dart';

void main() {
  patrol('clipboard and clicks', ($) async {
    await $.pumpWidgetAndSettle(const WebExampleApp());

    await $(TextField).scrollTo().tap();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.pressKey(key: 'a');
    await $.platform.web.pressKey(key: 'b');
    await $.platform.web.pressKeyCombo(keys: ['Control', 'a']);
    await $.platform.web.pressKeyCombo(keys: ['Control', 'c']);
    await $.platform.web.pressKeyCombo(keys: ['Control', 'v']); // ab
    await $.platform.web.pressKeyCombo(keys: ['Control', 'v']); // abab
    await $.platform.web.pressKeyCombo(keys: ['Control', 'a']);
    await $.platform.web.pressKeyCombo(keys: ['Control', 'c']);

    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.grantPermissions(
      permissions: ['clipboard-read', 'clipboard-write'],
    );
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(await $.platform.web.getClipboard(), 'abab');
    await $.platform.web.setClipboard(text: 'test');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(await $.platform.web.getClipboard(), 'test');
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));

    await $.platform.web.clearPermissions();
    await $.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 1));
  });
}
