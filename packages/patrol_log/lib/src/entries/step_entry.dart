part of 'entry.dart';

@JsonSerializable()
class StepEntry extends Entry {
  StepEntry({
    required this.action,
    required this.status,
    this.data,
    DateTime? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.step,
        );

  factory StepEntry.fromJson(Map<String, dynamic> json) =>
      _$StepEntryFromJson(json);

  final String action;
  final StepEntryStatus status;
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
    return switch (number) {
      == null => '',
      < 10 => '  $number.',
      < 100 => ' $number.',
      _ => '$number.',
    };
  }

  @override
  String toString() => 'StepEntry(${toJson()})';

  @override
  List<Object?> get props => [action, status, data, timestamp, type];
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
