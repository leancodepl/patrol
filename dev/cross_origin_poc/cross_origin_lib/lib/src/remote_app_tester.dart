import 'remote_app.dart';
import 'remote_apps_lookup.dart';
import 'remote_patrol_finder.dart';

/// Test-side `$` for [patrolRemoteTest].
///
/// Mirrors the shape of `PatrolTester` (the `$` in regular `patrolTest`):
/// callable as `$(matching)` to obtain a finder. The finder returned is a
/// [RemotePatrolFinder] whose actions execute in the remote app's isolate
/// over postMessage RPC instead of locally.
///
/// Additionally exposes tab-level operations like [waitForOrigin].
class RemoteAppTester {
  RemoteAppTester(this.app);

  /// Underlying remote-app handle. Exposed for power users who need direct
  /// RPC access (e.g. `app.findCount(...)` without going through a finder).
  final RemoteApp app;

  /// `$(matching)` — accepts the same matching kinds as `PatrolTester.call()`:
  /// `PatrolFinder`, `Finder`, `ValueKey`, `Symbol`, `String`,
  /// or `SerializedFinder`. Returns a [RemotePatrolFinder] whose actions
  /// execute in the remote app.
  RemotePatrolFinder call(Object matching) =>
      RemotePatrolFinder(matching: matching, app: app);

  /// Waits for the remote app to broadcast `patrol_ready` from [origin].
  /// Use this when you have the exact URL and want to gate on it.
  Future<String> waitForOrigin(
    String origin, {
    Duration timeout = const Duration(seconds: 30),
  }) => app.waitForReady(expectedOrigin: origin, timeout: timeout);

  /// Waits for the remote app to land on the origin of the remote app named
  /// [name] (as declared in `patrol.remote.apps` in the controller's
  /// pubspec.yaml). Prefer this over [waitForOrigin] — tests stay portable
  /// across port allocations.
  Future<String> waitForApp(
    String name, {
    Duration timeout = const Duration(seconds: 30),
  }) => waitForOrigin(RemoteApps.origin(name), timeout: timeout);
}
