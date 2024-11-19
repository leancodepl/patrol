part of 'entry.dart';

@JsonSerializable()
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
  factory TestEntry.fromJson(Map<String, dynamic> json) =>
      _$TestEntryFromJson(json);

  final String name;
  final TestEntryStatus status;
  final String? error;

  Duration executionTime(DateTime start) => timestamp.difference(start);

  @override
  Map<String, dynamic> toJson() => _$TestEntryToJson(this);

  @override
  String pretty() {
    if (!isFinished) {
      return '${status.name} $_testName';
    }
    return '${status.name} $_testName ${AnsiCodes.gray}(integration_test/$_filePath.dart)${AnsiCodes.reset}${error != null ? '\n$error' : ''}';
  }

  String get nameWithPath =>
      '$_testName ${AnsiCodes.gray}(integration_test/$_filePath.dart)${AnsiCodes.reset}';

  String get _filePath => name.split(' ').first.replaceAll('.', '/');
  String get _testName => name.split(' ').skip(1).join(' ');

  @override
  String toString() => 'TestEntry(${toJson()})';

  @override
  List<Object?> get props => [name, status, error, timestamp, type];

  /// Returns `true` if the test is finished successfully or with a failure.
  bool get isFinished =>
      status == TestEntryStatus.success || status == TestEntryStatus.failure;
}

enum TestEntryStatus {
  start,
  success,
  failure,
  skip;

  String get name => switch (this) {
        TestEntryStatus.start => Emojis.testStart,
        TestEntryStatus.success => Emojis.success,
        TestEntryStatus.failure => Emojis.failure,
        TestEntryStatus.skip => Emojis.skip,
      };
}
