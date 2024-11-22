import 'package:patrol_log/patrol_log.dart';

/// Represents a single test entry.
///
/// A single test entry is a collection of entries that belong to the same test.
/// It starts with a [TestEntry] with status [TestEntryStatus.start] or
/// [TestEntryStatus.skip].
/// Entry with skip status contains only one entry.
/// Entry with start status contains also [StepEntry] and [LogEntry] entries.
/// The last entry in the collection is a test entry with status
/// [TestEntryStatus.success] or [TestEntryStatus.failure].
class PatrolSingleTestEntry {
  PatrolSingleTestEntry(this.openingTestEntry);

  final TestEntry openingTestEntry;
  TestEntry? closingTestEntry;

  /// List contains StepEntry and LogEntry entries.
  final List<Entry> _entries = [];

  void addEntry(Entry entry) {
    _entries.add(entry);
  }

  void closeTest(TestEntry testEntry) {
    closingTestEntry = testEntry;
  }

  /// The name of the test.
  String get name => openingTestEntry.name;

  /// The status of the test.
  TestEntryStatus get status =>
      closingTestEntry?.status ?? openingTestEntry.status;

  /// The name of the test with the path.
  ///
  /// If test is not closed yet, the path is unknown, so return only test name.
  String get nameWithPath => closingTestEntry?.nameWithPath ?? name;

  /// The execution time of the test.
  Duration get executionTime {
    final testEntry = closingTestEntry;
    if (testEntry == null) {
      throw StateError('The test is not closed yet.');
    }
    return testEntry.executionTime(openingTestEntry.timestamp);
  }
}
