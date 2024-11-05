part of 'entry.dart';

@JsonSerializable(explicitToJson: true)
class LogEntry extends Entry {
  LogEntry({
    required this.message,
    DateTime? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.log,
        );

  @override
  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

  final String message;

  @override
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);

  @override
  String pretty() {
    return '$indentation${Emojis.log} $message';
  }

  @override
  String toString() => 'LogEntry(${toJson()})';
}
