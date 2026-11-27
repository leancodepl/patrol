part of 'entry.dart';

@JsonSerializable()
class WarningEntry extends Entry {
  WarningEntry({required this.message, this.retriedTest, DateTime? timestamp})
    : super(timestamp: timestamp ?? DateTime.now(), type: EntryType.warning);

  factory WarningEntry.fromJson(Map<String, dynamic> json) =>
      _$WarningEntryFromJson(json);

  final String message;

  /// The name of a test whose attempt ended without a result and will be
  /// retried, e.g. when Playwright times out a web test.
  ///
  /// `PatrolLogReader` then drops the attempt's open test entry, so only the
  /// last attempt is counted.
  final String? retriedTest;

  @override
  Map<String, dynamic> toJson() => _$WarningEntryToJson(this);

  @override
  String pretty() {
    return '${AnsiCodes.yellow}$message${AnsiCodes.reset}';
  }

  @override
  String toString() => 'WarningEntry(${toJson()})';

  @override
  List<Object?> get props => [message, retriedTest, timestamp, type];
}
