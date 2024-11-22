part of 'entry.dart';

@JsonSerializable()
class WarningEntry extends Entry {
  WarningEntry({
    required this.message,
    DateTime? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.warning,
        );

  @override
  factory WarningEntry.fromJson(Map<String, dynamic> json) =>
      _$WarningEntryFromJson(json);

  final String message;

  @override
  Map<String, dynamic> toJson() => _$WarningEntryToJson(this);

  @override
  String pretty() {
    return '${AnsiCodes.yellow}$message${AnsiCodes.reset}';
  }

  @override
  String toString() => 'WarningEntry(${toJson()})';

  @override
  List<Object?> get props => [message, timestamp, type];
}
