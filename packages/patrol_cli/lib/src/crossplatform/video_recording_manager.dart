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
  String? get recordingSummary {
    if (_savedVideos.isEmpty) {
      return null;
    }
    final count = _savedVideos.length;
    final directory = path.dirname(_savedVideos.first);
    return 'Recorded $count video${count == 1 ? '' : 's'} to $directory';
  }

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

  /// Sanitizes test name for use in filename.
  @protected
  String sanitizeTestName(String testName) {
    // Remove file path prefix and keep only the actual test name
    final parts = testName.split(' ');
    if (parts.length > 1) {
      // Skip the first part which is usually the file path
      return parts.skip(1).join(' ').replaceAll(RegExp(r'[^\w\-\s]'), '_');
    }
    return testName.replaceAll(RegExp(r'[^\w\-\s]'), '_');
  }

  /// Cleanup method to stop any ongoing recording.
  Future<void> dispose() async {
    await _operations;
    await stopRecording();
  }
}
