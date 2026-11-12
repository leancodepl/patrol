# patrol_challenge

App with the quiz for Fluttercon

### Set up

This project is a simple quiz Flutter app. It uses flavors.

To run tests:

```
dart run patrol test
```

### Google credentials

This app allows the user to sign in with Google. This requires some
configuration, but it's not needed if you don't plan on using this feature.

Firebase is configured in `lib/firebase_options.dart` and is initialized only
when the app is built with `--dart-define=FIREBASE_ENABLED=true`. Google sign-in
also needs OAuth client IDs from your own Firebase project (`serverClientId` on
Android, `clientId` and the reversed client ID URL scheme on iOS).
