import 'package:e2e_app/keys.dart';

import 'common.dart';

void main() {
  patrolTest(
    'enterText() on autofocused text fields',
    framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
    ($) async {
      // Start the app
      await createApp($);

      // Open login flow screen
      await $('Open login flow screen').scrollTo().tap();
      await $.pumpAndSettle();

      // Enter username and tap next
      await $(K.usernameTextField).enterText('test');
      await $(K.usernameTextField).enterText('test123');
      expect($('test123'), findsOneWidget);

      await $(K.usernameNextButton).tap();

      // Enter password and tap next
      await $(K.passwordTextField).enterText('123456');
      await $(K.passwordTextField).enterText('123456789');
      expect($('123456789'), findsOneWidget);

      await $(K.passwordNextButton).tap();

      // Verify we're on the welcome page with correct username
      expect($(K.welcomeText), findsOneWidget);
    },
    tags: ['enterText'],
  );
}
