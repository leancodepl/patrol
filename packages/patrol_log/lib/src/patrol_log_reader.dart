import 'dart:async';
import 'dart:convert';
import 'package:dispose_scope/dispose_scope.dart';
import 'package:patrol_log/patrol_log.dart';

class PatrolLogReader {
  PatrolLogReader({
    required DisposeScope scope,
    required this.listenStdOut,
    required this.log,
    required this.reportPath,
  }) : _scope = scope;

  final DisposeScope _scope;
  final StreamSubscription<void> Function(
    void Function(String) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) listenStdOut;
  final void Function(String) log;
  final String reportPath;
  final stopwatch = Stopwatch();

  final List<PatrolSingleTestEntry> _singleEntries = [];
  final List<String> _skippedTests = [];

  final StreamController<Entry> _controller =
      StreamController<Entry>.broadcast();
  late final StreamSubscription<Entry> _streamSubscription;

  void listen() {
    read();
    listenStdOut(parse).disposedBy(_scope);
  }

  /// Starts the timer measuring whole tests duration.
  void startTimer() => stopwatch.start();

  /// Stops the timer measuring whole tests duration.
  void stopTimer() => stopwatch.stop();

  int get totalTests => _singleEntries.length;
  int get successfulTests =>
      _singleEntries.where((e) => e.status == TestEntryStatus.success).length;
  int get failedTests =>
      _singleEntries.where((e) => e.status == TestEntryStatus.failure).length;
  int get skippedTests =>
      _singleEntries.where((e) => e.status == TestEntryStatus.skip).length;

  void parse(String line) {
    if (line.contains('PATROL_LOG')) {
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
    return;
  }

  static Entry parseEntry(String entryJson) {
    final json = jsonDecode(entryJson) as Map<String, dynamic>;
    final type = EntryType.values[json['type'] as int];
    switch (type) {
      case EntryType.step:
        return StepEntry.fromJson(json);
      case EntryType.test:
        return TestEntry.fromJson(json);
      case EntryType.log:
        return LogEntry.fromJson(json);
    }
  }

  Future<void> read() async {
    _streamSubscription = _controller.stream.listen((entry) {
      if (entry is TestEntry && entry.status == TestEntryStatus.success) {
        final executionTime = entry
            .executionTime(_singleEntries.last.entries.first.timestamp)
            .inSeconds;
        log('${entry.pretty()} \u001b[30m(${executionTime}s)\u001b[0m');
      } else {
        log(entry.pretty());
      }

      if (entry is TestEntry &&
          (entry.status == TestEntryStatus.skip ||
              entry.status == TestEntryStatus.start)) {
        _singleEntries.add(PatrolSingleTestEntry([entry]));
      } else if (entry is TestEntry) {
        final lastEntry = _singleEntries.last;
        lastEntry.entries.add(entry);
      } else {
        final lastEntry = _singleEntries.last;
        lastEntry.entries.add(entry);
      }
    });
  }

  /// Returns a summary of the test results.
  String get summary => 'Test summary:\n'
      '📝 Total: $totalTests\n'
      '✅ Successful: $successfulTests\n'
      '❌ Failed: $failedTests\n'
      '⏩ Skipped: $skippedTests\n'
      '📊 Report: $reportPath\n'
      '⏱️  Duration: ${stopwatch.elapsed.inSeconds}s\n';

  void close() {
    _streamSubscription.cancel();
    _controller.close();
  }
}

class PatrolSingleTestEntry {
  PatrolSingleTestEntry(this.entries);

  final List<Entry> entries;

  String get name =>
      (entries.firstWhere((t) => t is TestEntry) as TestEntry).name;

  TestEntryStatus get status =>
      (entries.lastWhere((t) => t is TestEntry) as TestEntry).status;
}
