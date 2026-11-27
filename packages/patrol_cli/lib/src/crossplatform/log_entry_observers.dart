import 'package:patrol_cli/src/crossplatform/video_recording_manager.dart';
import 'package:patrol_cli/src/dashboard/dashboard_reporter.dart';
import 'package:patrol_log/patrol_log.dart';

/// Chains the observers of a run's `patrol_log` entries in front of
/// [onLogEntry], skipping the ones that are not active.
///
/// Every backend that builds a `PatrolLogReader` needs the same chain, so the
/// order lives here instead of being repeated per platform.
void Function(Entry entry)? observeLogEntries(
  void Function(Entry entry)? onLogEntry, {
  DashboardReporter? dashboard,
  VideoRecordingManager? videos,
}) {
  var chained = onLogEntry;
  if (dashboard != null) {
    chained = dashboard.wrapOnLogEntry(chained);
  }
  if (videos != null) {
    chained = videos.wrapOnLogEntry(chained);
  }
  return chained;
}
