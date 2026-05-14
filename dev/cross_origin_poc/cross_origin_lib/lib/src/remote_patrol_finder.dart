import 'remote_app.dart';

/// Finder-like object returned by `$(matching)` inside `patrolRemoteTest`.
///
/// Mirrors a subset of `PatrolFinder` action API but every action executes
/// **in the remote app's isolate** over postMessage RPC, not against the
/// controller's local widget tree.
///
/// Why a subset: only operations expressible as `(serialized_finder, action)`
/// can cross the postMessage boundary. Patrol operations relying on direct
/// widget tree access (e.g. `.evaluate()`, `.state<T>()`) are intentionally
/// absent so the compiler stops the user from writing tests that can't work
/// remotely.
class RemotePatrolFinder {
  RemotePatrolFinder({required this.matching, required this.app});

  /// The argument that was passed to `$(...)`. See [RemoteApp.tap] for the
  /// accepted shapes.
  final Object matching;

  /// Underlying remote-app handle.
  final RemoteApp app;

  /// Taps the widget. Fire-and-forget on the remote side: the ack returns
  /// before the gesture actually dispatches, because a tap may trigger
  /// cross-origin top-level navigation that destroys the remote isolate
  /// mid-action.
  Future<void> tap() => app.tap(matching);

  /// Writes [text] into a `TextField`/`EditableText`'s
  /// `TextEditingController`. Note: `onChanged` does not fire in this PoC —
  /// see README for the production roadmap.
  Future<void> enterText(String text) => app.enterText(matching, text);

  /// Number of widgets in the remote app's tree currently matching this
  /// finder. Use with `expect`:
  ///
  /// ```dart
  /// expect(await $(#status).count, 1);
  /// ```
  Future<int> get count => app.findCount(matching);
}
