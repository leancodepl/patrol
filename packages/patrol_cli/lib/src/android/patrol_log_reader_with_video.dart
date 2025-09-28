import 'dart:async';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_cli/src/android/video_recording_manager.dart';
import 'package:patrol_log/patrol_log.dart';

/// Interface for patrol log readers.
abstract class PatrolLogReaderInterface {
  void listen();
  void startTimer();
  void stopTimer();
  String get summary;
}

/// Extended PatrolLogReader that supports video recording per test case.
class PatrolLogReaderWithVideo implements PatrolLogReaderInterface {
  PatrolLogReaderWithVideo({
    required DisposeScope scope,
    required this.listenStdOut,
    required this.log,
    required this.reportPath,
    required this.showFlutterLogs,
    required this.hideTestSteps,
    required this.clearTestSteps,
    this.videoRecordingManager,
  }) : _scope = scope;

  final void Function(String) log;
  final String reportPath;
  final bool showFlutterLogs;
  final bool hideTestSteps;
  final bool clearTestSteps;
  final VideoRecordingManager? videoRecordingManager;
  final StreamSubscription<void> Function(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  })
  listenStdOut;
  final DisposeScope _scope;

  late final PatrolLogReader _patrolLogReader;

  @override
  void listen() {
    // Create the underlying PatrolLogReader
    _patrolLogReader = PatrolLogReader(
      scope: _scope,
      listenStdOut: _wrapListenStdOut,
      log: log,
      reportPath: reportPath,
      showFlutterLogs: showFlutterLogs,
      hideTestSteps: hideTestSteps,
      clearTestSteps: clearTestSteps,
    );

    _patrolLogReader.listen();
  }

  /// Wraps the listenStdOut to intercept and handle video recording.
  StreamSubscription<void> _wrapListenStdOut(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return listenStdOut(
      (line) {
        // First, let the original PatrolLogReader handle the line
        onData(line);

        // Then, handle video recording if enabled
        if (videoRecordingManager != null && line.contains('PATROL_LOG')) {
          _handleVideoRecording(line);
        }
      },
      onError: onError,
      onDone: () {
        // Stop any ongoing recording when done
        videoRecordingManager?.dispose();
        onDone?.call();
      },
      cancelOnError: cancelOnError,
    );
  }

  /// Handles video recording based on patrol log entries.
  void _handleVideoRecording(String line) {
    try {
      final regExp = RegExp('PATROL_LOG (.*)');
      final match = regExp.firstMatch(line);

      if (match?.group(1) case final firstMatch?) {
        // \134 is the octal representation of backslash
        const octalBackslash = r'\134';
        final json = firstMatch.replaceAll(octalBackslash, r'\');
        final entry = PatrolLogReader.parseEntry(json);

        if (entry is TestEntry) {
          videoRecordingManager?.handleTestEntry(entry);
        }
      }
    } catch (err) {
      log('Error handling video recording for line: $line');
    }
  }

  /// Starts the timer measuring whole tests duration.
  @override
  void startTimer() => _patrolLogReader.startTimer();

  /// Stops the timer measuring whole tests duration.
  @override
  void stopTimer() => _patrolLogReader.stopTimer();

  /// Returns the summary from the underlying PatrolLogReader.
  @override
  String get summary => _patrolLogReader.summary;

  /// Cleanup method.
  Future<void> dispose() async {
    await videoRecordingManager?.dispose();
  }
}

/// Wrapper for standard PatrolLogReader to implement the interface.
class StandardPatrolLogReaderWrapper implements PatrolLogReaderInterface {
  StandardPatrolLogReaderWrapper({
    required DisposeScope scope,
    required StreamSubscription<void> Function(
      void Function(String) onData, {
      Function? onError,
      void Function()? onDone,
      bool? cancelOnError,
    })
    listenStdOut,
    required void Function(String) log,
    required String reportPath,
    required bool showFlutterLogs,
    required bool hideTestSteps,
    required bool clearTestSteps,
  }) : _patrolLogReader = PatrolLogReader(
         scope: scope,
         listenStdOut: listenStdOut,
         log: log,
         reportPath: reportPath,
         showFlutterLogs: showFlutterLogs,
         hideTestSteps: hideTestSteps,
         clearTestSteps: clearTestSteps,
       );

  final PatrolLogReader _patrolLogReader;

  @override
  void listen() => _patrolLogReader.listen();

  @override
  void startTimer() => _patrolLogReader.startTimer();

  @override
  void stopTimer() => _patrolLogReader.stopTimer();

  @override
  String get summary => _patrolLogReader.summary;
}
