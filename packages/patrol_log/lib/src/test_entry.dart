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
    return 'Test ${status.name} $name';
  }

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
        return 'started ⏳';
      case TestEntryStatus.success:
        return 'succeeded ✅';
      case TestEntryStatus.failure:
        return 'failed ❌';
      case TestEntryStatus.skip:
        return 'skipped ⏩';
    }
  }
}
