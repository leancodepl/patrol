import 'package:flutter/material.dart';

import 'common.dart';

void main() {
  patrolTest(
    'enterText test. Using PatrolTester',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      // Start the app
      await createApp($);

      // Open login flow screen
      await $('Open login flow screen').scrollTo().tap();
      await $.pumpAndSettle();

      // Enter username and tap next
      await $(Key('username_text_field')).enterText('test');
      await $(Key('username_text_field')).enterText('test123');
      await $.tap(find.byKey(Key('username_next_button')));

      // Enter password and tap next
      await $(Key('password_text_field')).enterText('123456');
      await $(Key('password_text_field')).enterText('123456789');

      await $(Key('password_back_button')).tap();

      await $.tap(find.byKey(Key('username_next_button')));

      // Enter password and tap next
      await $(Key('password_text_field')).enterText('123456');
      await $(Key('password_text_field')).enterText('123456789');

      await $.tap(find.byKey(Key('password_next_button')));

      // Verify we're on the welcome page with correct username
      expect(find.byKey(Key('welcome_text')), findsOneWidget);
    },
    tags: ['enterText'],
  );
}
