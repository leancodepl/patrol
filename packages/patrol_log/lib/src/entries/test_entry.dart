part of 'entry.dart';

@JsonSerializable()
class TestEntry extends Entry {
  TestEntry({
    required this.name,
    required this.status,
    DateTime? timestamp,
    this.error,
  }) : super(timestamp: timestamp ?? DateTime.now(), type: EntryType.test);

  factory TestEntry.fromJson(Map<String, dynamic> json) =>
      _$TestEntryFromJson(json);

  final String name;
  final TestEntryStatus status;
  final String? error;

  /// Returns the execution time between [start] and TestEntry [timestamp].
  Duration executionTime(DateTime start) => timestamp.difference(start);

  @override
  Map<String, dynamic> toJson() => _$TestEntryToJson(this);

  /// The default value of `patrol.test_file_suffix` in `pubspec.yaml`.
  static const defaultTestFileSuffix = '_test.dart';

  /// Returns the suffix that the file prefix of a test name ends with for
  /// test files ending with [testFileSuffix], e.g. `_spec` for `_spec.dart`.
  ///
  /// Mirrors how `patrol_cli` turns a test file path into a group name: the
  /// `.dart` extension is dropped and non-identifier characters are replaced
  /// with `_`.
  static String fileNameSuffix(String testFileSuffix) {
    var suffix = testFileSuffix;
    if (suffix.endsWith('.dart')) {
      suffix = suffix.substring(0, suffix.length - '.dart'.length);
    }
    return suffix.replaceAll(RegExp('[^a-zA-Z0-9_]'), '_');
  }

  /// Pass the project's `patrol.test_file_suffix` as [testFileSuffix] so that
  /// the file prefix of a finished test is recognized.
  @override
  String pretty({String testFileSuffix = defaultTestFileSuffix}) {
    if (!isFinished) {
      return '${status.name} $name';
    }
    final nameWithPath = nameWithPathFor(testFileSuffix: testFileSuffix);
    return '${status.name} $nameWithPath${error != null ? '\n$error' : ''}';
  }

  /// The test name with its file path rendered next to it, e.g.
  /// `signs in (patrol_test/app_test.dart)`.
  ///
  /// Assumes the default `patrol.test_file_suffix`. Use [nameWithPathFor] for
  /// projects that override it.
  String get nameWithPath =>
      nameWithPathFor(testFileSuffix: defaultTestFileSuffix);

  /// The test name with its file path rendered next to it, for test files
  /// ending with [testFileSuffix].
  ///
  /// Falls back to the raw [name] when it has no file prefix, so the
  /// description is preserved intact instead of losing its first word to
  /// [_filePath].
  String nameWithPathFor({required String testFileSuffix}) {
    if (!_hasFilePathPrefix(testFileSuffix)) {
      return name;
    }
    const testDirectory = String.fromEnvironment('PATROL_TEST_DIRECTORY');
    final filePath = _filePath(testFileSuffix);
    return '$_testName ${AnsiCodes.gray}($testDirectory/$filePath)${AnsiCodes.reset}';
  }

  /// Whether [name] starts with a test file prefix, e.g. `example_test` or
  /// `permissions.permissions_location_test`, followed by the test
  /// description.
  ///
  /// Test files end with [testFileSuffix] (`_test.dart` by default), so a
  /// prefix ends with its [fileNameSuffix] (`_test`), also for nested paths
  /// (`.` separates directory names). Without this guard, a name logged
  /// without the prefix would lose the first word of its description to
  /// [_filePath].
  bool _hasFilePathPrefix(String testFileSuffix) {
    final firstSpace = name.indexOf(' ');
    if (firstSpace == -1) {
      return false;
    }
    final firstToken = name.substring(0, firstSpace);
    final suffix = fileNameSuffix(testFileSuffix);
    // A suffix like `.dart` leaves nothing to tell a file prefix apart.
    return suffix.isNotEmpty && firstToken.endsWith(suffix);
  }

  /// Returns the file path of the test, for test files ending with
  /// [testFileSuffix].
  ///
  /// The file path is the first part of the test name.
  /// '.' is replaced with '/' to create a valid file path, and the sanitized
  /// suffix is replaced with [testFileSuffix], e.g. `example_spec` becomes
  /// `example.spec.dart` for the `.spec.dart` suffix.
  String _filePath(String testFileSuffix) {
    final prefix = name.split(' ').first.replaceAll('.', '/');
    final base = prefix.substring(
      0,
      prefix.length - fileNameSuffix(testFileSuffix).length,
    );
    return '$base$testFileSuffix';
  }

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
