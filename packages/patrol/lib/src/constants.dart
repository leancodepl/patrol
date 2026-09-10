import 'package:meta/meta.dart';

/// Whether Hot Restart is enabled.
@internal
const hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');

/// Whether to auto-capture a native screenshot on test failure (`screenshot_on_failure`).
@internal
const screenshotOnFailureEnabled = bool.fromEnvironment(
  'PATROL_SCREENSHOT_ON_FAILURE',
);

/// Whether the bundle runs in build-time test discovery mode, driven by a host
/// `flutter test` run.
///
/// In this mode Patrol tests are only *registered* (so the group tree can be
/// built and serialized into a manifest); their bodies are skipped and
/// `PatrolBinding` is never initialized (it's a Live binding, incompatible with
/// the automated binding used by `flutter test` on the host).
@internal
const testDiscoveryEnabled = bool.fromEnvironment('PATROL_TEST_DISCOVERY');

/// The platform the tests are being discovered for, as reported by `patrol_cli`
/// during build-time test discovery: `android`, `ios`, `macos` or `web`. Empty
/// outside discovery, and when the CLI is too old to report it.
@internal
const testDiscoveryPlatform = String.fromEnvironment(
  'PATROL_TEST_DISCOVERY_PLATFORM',
);
