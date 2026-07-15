part of 'entry.dart';

@JsonSerializable()
class TestEntry extends Entry {
  TestEntry({
    required this.name,
    required this.status,
    DateTime? timestamp,
    this.error,
  }) : super(timestamp: timestamp ?? DateTime.now(), type: EntryType.test);

  @override
  factory TestEntry.fromJson(Map<String, dynamic> json) =>
      _$TestEntryFromJson(json);

  final String name;
  final TestEntryStatus status;
  final String? error;

  /// Returns the execution time between [start] and TestEntry [timestamp].
  Duration executionTime(DateTime start) => timestamp.difference(start);

  @override
  Map<String, dynamic> toJson() => _$TestEntryToJson(this);

  @override
  String pretty() {
    if (!isFinished) {
      return '${status.name} $name';
    }
    if (!_hasFilePathPrefix) {
      return '${status.name} $name${error != null ? '\n$error' : ''}';
    }
    return '${status.name} $nameWithPath${error != null ? '\n$error' : ''}';
  }

  String get nameWithPath {
    const testDirectory = String.fromEnvironment('PATROL_TEST_DIRECTORY');
    return '$_testName ${AnsiCodes.gray}($testDirectory/$_filePath.dart)${AnsiCodes.reset}';
  }

  /// Whether [name] starts with a test file prefix, e.g. `example_test` or
  /// `permissions.permissions_location_test`, followed by the test
  /// description.
  ///
  /// Test files always match `*_test.dart`, so a prefix either ends with
  /// `_test` or contains a `.` separating directory names. Without this guard,
  /// a name logged without the prefix would lose the first word of its
  /// description to [_filePath].
  bool get _hasFilePathPrefix {
    final firstSpace = name.indexOf(' ');
    if (firstSpace == -1) {
      return false;
    }
    final firstToken = name.substring(0, firstSpace);
    return firstToken.contains('.') || firstToken.endsWith('_test');
  }

  /// Returns the file path of the test.
  ///
  /// The file path is the first part of the test name.
  /// '.' is replaced with '/' to create a valid file path.
  String get _filePath => name.split(' ').first.replaceAll('.', '/');

  /// Returns the test name without the file path.
  ///
  /// When test is finished, then first part of the name is the file name.
  /// So we skip the first part.
  String get _testName => name.split(' ').skip(1).join(' ');

  @override
  String toString() => 'TestEntry(${toJson()})';

  @override
  List<Object?> get props => [name, status, error, timestamp, type];

  /// Returns `true` if the test is finished, successfully or with a failure.
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
