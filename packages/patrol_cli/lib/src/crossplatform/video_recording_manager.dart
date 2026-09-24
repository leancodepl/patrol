import 'dart:async';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:patrol_log/patrol_log.dart';

/// Starts and stops video recording for individual test cases based on test
/// lifecycle events. Platform-specific recording is provided by subclasses.
abstract class VideoRecordingManager {
  /// Chain serializing start/stop operations so that log events arriving in
  /// quick succession cannot interleave recording state changes.
  Future<void> _operations = Future<void>.value();

  final List<String> _savedVideos = [];

  /// Records that a video was successfully saved at [videoPath].
  @protected
  void addSavedVideo(String videoPath) => _savedVideos.add(videoPath);

  /// One-line summary of saved recordings for the CLI summary, or `null` if
  /// nothing was recorded.
  String? get recordingSummary => videoRecordingSummary(_savedVideos);

  /// Starts video recording for a test case.
  Future<void> startRecording(String testName);

  /// Stops video recording and saves the file.
  Future<void> stopRecording();

  /// Returns an `onLogEntry` callback that triggers video recording on test
  /// lifecycle events and then delegates to [next].
  void Function(Entry entry) wrapOnLogEntry(void Function(Entry entry)? next) {
    return (entry) {
      if (entry is TestEntry) {
        handleTestEntry(entry);
      } else if (entry is ConfigEntry &&
          entry.config[ConfigEntry.developCompletedKey] == true) {
        // `patrol develop` signals a passing run's end with this entry (no
        // `success` event), so stop here to save the video right away.
        _operations = _operations.then((_) => stopRecording());
      }
      next?.call(entry);
    };
  }

  /// Handles test entry events from PatrolLogReader.
  void handleTestEntry(TestEntry testEntry) {
    switch (testEntry.status) {
      case TestEntryStatus.start:
        _operations = _operations.then((_) => startRecording(testEntry.name));
      case TestEntryStatus.success:
      case TestEntryStatus.failure:
        _operations = _operations.then((_) => stopRecording());
      case TestEntryStatus.skip:
        // No recording needed for skipped tests
        break;
    }
  }

  /// Cleanup method to stop any ongoing recording.
  Future<void> dispose() async {
    await _operations;
    await stopRecording();
  }
}

/// One-line summary of [savedVideos] for the CLI summary, or `null` if the
/// list is empty. Shared by the per-test recorders and the iOS `.xcresult`
/// extractor so every platform reports recordings the same way.
String? videoRecordingSummary(List<String> savedVideos) {
  if (savedVideos.isEmpty) {
    return null;
  }
  final count = savedVideos.length;
  final directory = path.dirname(savedVideos.first);
  return 'Recorded $count video${count == 1 ? '' : 's'} to $directory';
}
