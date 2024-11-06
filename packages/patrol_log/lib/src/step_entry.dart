part of 'entry.dart';

@JsonSerializable()
class StepEntry extends Entry {
  StepEntry({
    required this.action,
    required this.status,
    this.exception,
    this.data,
    DateTime? timestamp,
    super.type = EntryType.step,
  }) : super(timestamp: timestamp ?? DateTime.now());

  factory StepEntry.fromJson(Map<String, dynamic> json) =>
      _$StepEntryFromJson(json);

  final String action;
  final StepEntryStatus status;
  final String? exception;
  final Map<String, dynamic>? data;

  @override
  Map<String, dynamic> toJson() => _$StepEntryToJson(this);

  @override
  String pretty({int? number}) {
    return '$indentation${status.name} ${printIndex(number)} $action';
  }

  /// Returns the index of the step with the correct number of spaces,
  /// to format the output.
  String printIndex(int? number) {
    if (number != null) {
      if (number < 10) {
        return '  $number.';
      } else if (number < 100) {
        return ' $number.';
      } else {
        return '$number.';
      }
    }

    return '';
  }

  @override
  String toString() => 'StepEntry(${toJson()})';

  @override
  List<Object?> get props => [action, status, exception, data, timestamp, type];
}

enum StepEntryStatus {
  start,
  success,
  failure;

  String get name => switch (this) {
        StepEntryStatus.start => Emojis.waiting,
        StepEntryStatus.success => Emojis.success,
        StepEntryStatus.failure => Emojis.failure,
      };
}
