import 'package:flutter/foundation.dart';

typedef K = Keys;

class Keys {
  const Keys();

  static const topText = Key('topText');
  static const bottomText = Key('bottomText');
  static const backButton = Key('backButton');

  // autofocus text field flow
  static const usernameTextField = Key('usernameTextField');
  static const usernameNextButton = Key('usernameNextButton');
  static const passwordTextField = Key('passwordTextField');
  static const passwordNextButton = Key('passwordNextButton');
  static const welcomeText = Key('welcomeText');
}
