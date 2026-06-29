import 'package:meta/meta.dart';

/// Whether Hot Restart is enabled.
@internal
const hotRestartEnabled = bool.fromEnvironment('PATROL_HOT_RESTART');

/// Whether the bundle runs in build-time test discovery mode, driven by a host
/// `flutter test` run.
///
/// In this mode Patrol tests are only *registered* (so the group tree can be
/// built and serialized into a manifest); their bodies are skipped and
/// `PatrolBinding` is never initialized (it's a Live binding, incompatible with
/// the automated binding used by `flutter test` on the host).
@internal
const testDiscoveryEnabled = bool.fromEnvironment('PATROL_TEST_DISCOVERY');
