import 'dart:async';

import 'package:example/main_web.dart';
import 'package:example/ui/components/button/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('test that completes the great testing tool test', ($) async {
    await $.pumpWidgetAndSettle(const WebAutomatorShowcaseApp());
    await $.platform.web.resizeWindow(size: const Size(1200, 900));

    // Verify we're on the home page
    expect($('WEB TESTING TOOL CHALLENGE'), findsOneWidget);
    expect($('Start the test'), findsOneWidget);

    // Start the test
    await $('Start the test').tap();
    await $.pumpAndSettle();

    // Verify we're on Test1Screen
    expect($('Test 1'), findsOneWidget);
    expect($('Change the theme to dark'), findsOneWidget);

    // Button should not be visible in light mode
    expect($('Continue to next test'), findsNothing);

    // Enable dark mode
    await $.platform.web.enableDarkMode();
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Now the button should be visible
    expect($('Continue to next test'), findsOneWidget);

    // Continue to next test
    await $('Continue to next test').tap();
    await $.pumpAndSettle();

    // Verify we're on Test2Screen
    expect($('Test 2'), findsOneWidget);
    expect($('Secret Key Combination'), findsOneWidget);

    // Button should not be visible initially
    expect($('Continue to next test'), findsNothing);

    // Press Ctrl + L to reveal the button
    await $.platform.web.pressKeyCombo(keys: ['Shift', 'L', 'C']);
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Now the button should be visible
    expect($('Continue to next test'), findsOneWidget);

    // Continue to next test
    await $('Continue to next test').tap();
    await $.pumpAndSettle();

    // Verify we're on Test3Screen
    expect($('Test 3'), findsOneWidget);
    expect($('Responsive Layout'), findsOneWidget);

    // In expanded view, button should not be visible
    expect($('You are in expanded view.'), findsOneWidget);
    expect($('Continue to next test'), findsNothing);

    // Resize window to compact view (< 600 width)
    await $.platform.web.resizeWindow(size: const Size(500, 600));
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Now in compact view, button should be visible
    expect($('You are in compact view.'), findsOneWidget);
    expect($('Continue to next test'), findsOneWidget);

    // Continue to next test
    await $('Continue to next test').tap();
    await $.pumpAndSettle();

    // Verify we're on Test4Screen
    expect($('Test 4'), findsOneWidget);
    expect($('Cookie Challenge'), findsOneWidget);
    await $.platform.web.resizeWindow(size: const Size(1200, 900));

    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    // Button should not be visible initially
    expect($('Continue to next test'), findsNothing);

    // Get the secret code from cookies
    final cookies = await $.platform.web.getCookies();
    final secretCodeCookie = cookies.firstWhere(
      (cookie) => cookie['name'] == 'secret_code',
    );
    final secretCode = secretCodeCookie['value']! as String;

    // Enter the secret code in the text field
    await $(TextField).enterText(secretCode);
    await $.pumpAndSettle();

    // Now the button should be visible
    expect($('Continue to next test'), findsOneWidget);

    // Continue to next test
    await $('Continue to next test').tap();
    await $.pumpAndSettle();

    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    // Verify we're on Test5Screen
    expect($('Test 5'), findsOneWidget);
    expect($('IFrame Challenge'), findsOneWidget);

    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Define iframe selector
    final iframeSelector = WebSelector(cssOrXpath: 'iframe');

    // Scroll down inside the iframe to find the password field
    await $.platform.web.scrollTo(
      WebSelector(cssOrXpath: '#password-input'),
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Enter the password in the iframe's text field
    await $.platform.web.enterText(
      WebSelector(cssOrXpath: '#password-input'),
      text: '12345',
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle();

    // Click the submit button inside the iframe to trigger postMessage
    await $.platform.web.tap(
      WebSelector(cssOrXpath: '#submit-btn'),
      iframeSelector: iframeSelector,
    );
    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    // Verify we're on Test6Screen (navigated after postMessage)
    expect($('Test 6'), findsOneWidget);
    expect($('Clipboard Challenge'), findsOneWidget);

    // Grant clipboard permissions
    await $.platform.web.grantPermissions(
      permissions: ['clipboard-read', 'clipboard-write'],
    );
    await $.pumpAndSettle();

    // Click the button to copy password to clipboard
    await $('Copy password to clipboard').tap();

    await $.pumpAndSettle(duration: const Duration(seconds: 2));

    // Get the password from clipboard
    final password = await $.platform.web.getClipboard();

    // Enter the password in the text field
    await $(TextField).enterText(password);
    await $.pumpAndSettle();

    // Verify we're on Test7Screen (auto-navigates on correct password)
    expect($('Test 7'), findsOneWidget);
    expect($('Dialog Challenge'), findsOneWidget);

    unawaited($.platform.web.acceptNextDialog());

    // Click the button to show dialog
    await $('Show dialog').tap();

    await $.pumpAndSettle(duration: const Duration(seconds: 1));

    await $(
      PTElevatedButton,
    ).which<PTElevatedButton>((widget) => widget.caption == 'Fluttercon').tap();

    await $(ListTile).containing($(Icons.flutter_dash)).$('click').tap();

    await $(
      ElevatedButton,
    ).which<ElevatedButton>((widget) => widget.enabled).at(2).scrollTo().tap();

    // Verify we're on Test8Screen (navigated after accepting dialog)
    expect($('Test 8'), findsOneWidget);
    expect($('Test 8 - Coming soon'), findsOneWidget);
  });
}
