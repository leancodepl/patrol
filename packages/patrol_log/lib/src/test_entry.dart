import 'package:patrol_log/src/entry.dart';

class TestEntry extends Entry {
  TestEntry({
    required this.name,
    required this.status,
    DateTime? timestamp,
    this.error,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.test,
        );

  @override
  factory TestEntry.fromJson(Map<String, dynamic> json) => TestEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        name: json['name'] as String,
        status: TestEntryStatus.values[json['status'] as int],
        error: json['error'] as String?,
      );

  final String name;
  final TestEntryStatus status;
  final String? error;

  Duration executionTime(DateTime start) => timestamp.difference(start);

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status.index,
        'type': type.index,
        'timestamp': timestamp.toIso8601String(),
        'error': error,
      };

  @override
  String pretty() {
    if (status == TestEntryStatus.skip) {
      return '${status.name} $_testName';
    }
    return '${status.name} $_testName \u001b[30m(integration_test/$_filePath.dart)\u001b[0m';
  }

  String get nameWithPath =>
      '$_testName \u001b[30m(integration_test/$_filePath.dart)\u001b[0m';

  String get _filePath => name.split(' ').first.replaceAll('.', '/');
  String get _testName => name.split(' ').skip(1).join(' ');

  @override
  String toString() => 'TestEntry(${toJson()})';
}

enum TestEntryStatus {
  start,
  success,
  failure,
  skip;

  String get name {
    switch (this) {
      case TestEntryStatus.start:
        return '⏳';
      case TestEntryStatus.success:
        return '✅';
      case TestEntryStatus.failure:
        return '❌';
      case TestEntryStatus.skip:
        return '⏩';
    }
  }
}
