/// Outcome of a hot restart requested during a develop session.
///
/// A successful restart only means the app was recompiled and `main()` re-ran.
/// Whether the test then passed is reported separately, over PATROL_LOG.
class HotRestartResult {
  const HotRestartResult.succeeded() : success = true, error = null;

  const HotRestartResult.failed(String this.error) : success = false;

  /// The restart never reached `flutter run` (no session attached yet, another
  /// restart still in flight, or the process is gone).
  const HotRestartResult.dropped(String this.error) : success = false;

  final bool success;

  /// Why the restart failed, ready to surface to the caller.
  final String? error;
}
