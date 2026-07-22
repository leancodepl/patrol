import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:windows_poc/main.dart';

import 'fixture_helper.dart';

/// Capability showcase for Patrol on Windows.
///
/// Story (visible on screen while it runs):
/// 1. Automate Flutter UI like on Android/iOS
/// 2. Spawn a separate native Win32 "security" dialog
/// 3. Discover it with UI Automation (find / wait)
/// 4. Type into the native field + press keys
/// 5. Click Allow on the native dialog (outside Flutter)
/// 6. Prove both worlds completed successfully
void main() {
  patrolTest(
    'Flutter + native Windows dialog in one test',
    ($) async {
      // ── 1. Flutter app under test (same idea as mobile Patrol) ──────────
      await $.pumpWidgetAndSettle(const WindowsPocApp());
      expect($(#appTitle), findsOneWidget);
      expect($(#actionCount).text, '0');

      await $(#recordAction).tap();
      expect($(#actionCount).text, '1');
      expect($(#statusText).text, 'Flutter button tapped');

      await $(#recordAction).tap();
      expect($(#actionCount).text, '2');

      // ── 2. Outside-the-app: launch native desktop dialog ───────────────
      final fixture = await startFixture();
      addTearDown(fixture.kill);

      // ── 3. Discover native UI (UIA — like UiAutomator / XCUITest) ──────
      await $.platform.windows.waitUntilVisible(name: 'Allow access');
      expect(
        await $.platform.windows.isElementVisible(
          automationId: 'poc_identity_field',
        ),
        isTrue,
      );

      final allow = await $.platform.windows.findElement(
        automationId: 'poc_allow_button',
      );
      expect(allow, isNotNull);
      expect(allow!.name, 'Allow access');
      expect(allow.width, greaterThan(100));

      final fields = await $.platform.windows.findElements(
        automationId: 'poc_identity_field',
      );
      expect(fields, isNotEmpty);

      // ── 4. Type into the native (non-Flutter) text field ───────────────
      // pressKey into an empty native field, then set the full identity.
      await $.platform.windows.enterText(
        '',
        automationId: 'poc_identity_field',
      );
      await $.platform.windows.pressKey(0x48, shift: true); // H
      await $.platform.windows.pressKey(0x49, shift: true); // I
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(File(textMarkerPath).readAsStringSync(), 'HI');

      await $.platform.windows.enterText(
        'demo@example.com',
        automationId: 'poc_identity_field',
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(File(textMarkerPath).readAsStringSync(), 'demo@example.com');

      // ── 5. Click the native Allow button (outside Flutter) ─────────────
      await $.platform.windows.tap(name: 'Allow access');
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final marker = File(markerPath).readAsStringSync();
      expect(marker, contains('allowed:demo@example.com'));
      expect(
        await $.platform.windows.isElementVisible(name: 'Access granted'),
        isTrue,
      );

      // ── 6. Back to Flutter — one test spanned both worlds ──────────────
      await $(#recordAction).tap();
      expect($(#actionCount).text, '3');
    },
  );
}
