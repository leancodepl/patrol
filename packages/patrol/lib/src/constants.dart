import 'package:meta/meta.dart';

/// Whether Hot Restart is enabled.
@internal
const hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');

/// Whether a native screenshot should be captured automatically when a test
/// fails. Opt-in, controlled by `screenshot_on_failure` in the pubspec's
/// `patrol` section. Used for BrowserStack failure screenshots on Android.
@internal
const screenshotOnFailureEnabled = bool.fromEnvironment(
  'PATROL_SCREENSHOT_ON_FAILURE',
);
