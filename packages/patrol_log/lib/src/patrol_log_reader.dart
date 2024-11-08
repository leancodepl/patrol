import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/src/emojis.dart';

class PatrolLogReader {
  PatrolLogReader({
    required DisposeScope scope,
    required this.listenStdOut,
    required this.log,
    required this.reportPath,
    required this.showFlutterLogs,
    required this.hideTestSteps,
  }) : _scope = scope;

  final void Function(String) log;
  final String reportPath;
  final bool showFlutterLogs;
  final bool hideTestSteps;
  final StreamSubscription<void> Function(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) listenStdOut;
  final DisposeScope _scope;

  /// Stopwatch measuring the whole tests duration.
  final _stopwatch = Stopwatch();

  /// List of tests entries.
  final List<PatrolSingleTestEntry> _singleEntries = [];

  /// List of tests names that were skipped.
  final List<String> _skippedTests = [];

  final StreamController<Entry> _controller =
      StreamController<Entry>.broadcast();
  late final StreamSubscription<Entry> _streamSubscription;

  void listen() {
    // Listen to the entry stream and pretty print the patrol logs.
    readEntries();

    // Parse the output from the process.
    listenStdOut(parse).disposedBy(_scope);
  }

  /// Starts the timer measuring whole tests duration.
  void startTimer() => _stopwatch.start();

  /// Stops the timer measuring whole tests duration.
  void stopTimer() => _stopwatch.stop();

  /// Returns the total number of tests.
  int get totalTests => _singleEntries.length;

  /// Returns the number of tests that passed.
  int get successfulTests =>
      _singleEntries.where((e) => e.status == TestEntryStatus.success).length;

  /// Return list of failed tests.
  List<PatrolSingleTestEntry> get failedTests =>
      _singleEntries.where((e) => e.status == TestEntryStatus.failure).toList();

  /// Returns the number of failed tests.
  int get failedTestsCount => failedTests.length;

  /// Returns the number of skipped tests.
  int get skippedTests =>
      _singleEntries.where((e) => e.status == TestEntryStatus.skip).length;

  /// Returns `String` that have printed in bullet points name of failed tests
  /// with relative path to file that contains the test.
  String get failedTestsList =>
      failedTests.map((e) => '  - ${e.nameWithPath}').join('\n');

  /// Parse the line from the process output.
  void parse(String line) {
    if (line.contains('PATROL_LOG')) {
      _parsePatrolLog(line);
    } else if (showFlutterLogs && line.contains('Runner: (Flutter) flutter:')) {
      _parseFlutterIOsLog(line);
    } else if (showFlutterLogs && line.contains('I flutter :')) {
      _parseFlutterAndroidLog(line);
    }
  }

  /// Take line containg PATROL_LOG tag, parse it to [Entry] and add to stream.
  void _parsePatrolLog(String line) {
    final regExp = RegExp(r'PATROL_LOG \{(.*?)\}');
    final match = regExp.firstMatch(line);
    if (match != null) {
      final matchedText = match.group(1)!;
      final json = '{$matchedText}';
      final entry = parseEntry(json);

      if (entry case TestEntry _) {
        final testEntry = entry;
        // Skip info test is returned multiple times, so we need to filter it
        if (testEntry.status == TestEntryStatus.skip &&
            !_skippedTests.contains(testEntry.name)) {
          _skippedTests.add(testEntry.name);
          _controller.add(entry);
        } else if (testEntry.status != TestEntryStatus.skip) {
          _controller.add(entry);
        }
      } else {
        _controller.add(entry);
      }
    }
  }

  /// Parse the line containing Flutter logs on iOS and print them.
  void _parseFlutterIOsLog(String line) {
    final regExp = RegExp(r'Runner: \(Flutter\) (.*)');
    final match = regExp.firstMatch(line);
    if (match != null) {
      final matchedText = match.group(1)!;
      log(matchedText);
    }
  }

  /// Parse the line containing Flutter logs on Android and print them.
  void _parseFlutterAndroidLog(String line) {
    final regExp = RegExp('I (.*)');
    final match = regExp.firstMatch(line);
    if (match != null) {
      final matchedText = match.group(1)!;
      log(matchedText);
    }
  }

  /// Parses patrol log entry from JSON.
  static Entry parseEntry(String entryJson) {
    final json = jsonDecode(entryJson) as Map<String, dynamic>;

    final type = EntryType.byName(json['type'] as String);
    return switch (type) {
      EntryType.step => StepEntry.fromJson(json),
      EntryType.test => TestEntry.fromJson(json),
      EntryType.log => LogEntry.fromJson(json),
      EntryType.error => ErrorEntry.fromJson(json),
    };
  }

  /// Read the entries from the stream and print them to the console.
  Future<void> readEntries() async {
    var stepsCounter = 0;
    var logsCounter = 0;

    _streamSubscription = _controller.stream.listen(
      (entry) {
        switch (entry) {
          case TestEntry()
              when entry.status == TestEntryStatus.skip ||
                  entry.status == TestEntryStatus.start:
            // Create a new single test entry for the test that is starting or is skipped.
            _singleEntries.add(PatrolSingleTestEntry(entry));

            // Print the test entry to the console.
            log(entry.pretty());

            // Reset the counters needed for clearing the lines.
            stepsCounter = 0;
            logsCounter = 0;
          case TestEntry():
            // Close the single test entry for the test that is finished.
            _singleEntries.last.closeTest(entry);

            // Optionally clear all printed [StepEntry] and [LogEntry].
            if (!showFlutterLogs && entry.status != TestEntryStatus.failure) {
              _clearLines(stepsCounter + logsCounter + 1);
            }

            final executionTime = _singleEntries.last.executionTime.inSeconds;
            // Print test entry summary to console.
            log('${entry.pretty()} ${AnsiCodes.gray}(${executionTime}s)${AnsiCodes.reset}');
          case StepEntry():
            _singleEntries.last.addEntry(entry);
            if (!hideTestSteps) {
              // Clear the previous line it's not the new step, or increment counter
              // for new step
              if (entry.status != StepEntryStatus.start) {
                _clearPreviousLine();
              } else {
                stepsCounter++;
              }

              // Print the step entry to the console.
              log(entry.pretty(number: stepsCounter));
            }
          case LogEntry():
            _singleEntries.last.addEntry(entry);
            logsCounter++;

            // Print the log entry to the console.
            log(entry.pretty());

          case ErrorEntry():
            log(entry.pretty());
        }
      },
    );
  }

  /// Returns a summary of the test results. That contains:
  ///
  /// - Total number of tests
  /// - Number of successful tests
  /// - Number of failed tests
  /// - List of failed tests
  /// - Number of skipped tests
  /// - Path to the report file
  /// - Duration of the tests
  String get summary => '\n${AnsiCodes.bold}Test summary:${AnsiCodes.reset}\n'
      '${Emojis.total} Total: $totalTests\n'
      '${Emojis.success} Successful: $successfulTests\n'
      '${Emojis.failure} Failed: $failedTestsCount\n'
      '${failedTestsCount > 0 ? '$failedTestsList\n' : ''}'
      '${Emojis.skip} Skipped: $skippedTests\n'
      '${Emojis.report} Report: $reportPath\n'
      '${Emojis.duration} Duration: ${_stopwatch.elapsed.inSeconds}s\n';

  /// Closes the stream subscription and the stream controller.
  void close() {
    _streamSubscription.cancel();
    _controller.close();
  }

  /// Clears `number` of lines from the console output.
  void _clearLines(int number) {
    for (var i = 0; i < number; i++) {
      _clearPreviousLine();
    }
  }

  /// Clears the previous line from the console output.
  void _clearPreviousLine() {
    // Move the cursor up one line and clear the line
    stdout.write('\x1B[A\x1B[K');
  }
}
