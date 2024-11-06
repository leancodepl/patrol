part of 'entry.dart';

@JsonSerializable()
class LogEntry extends Entry {
  LogEntry({
    required this.message,
    DateTime? timestamp,
    super.type = EntryType.log,
  }) : super(timestamp: timestamp ?? DateTime.now());

  @override
  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);

  final String message;

  @override
  Map<String, dynamic> toJson() => _$LogEntryToJson(this);

  @override
  String pretty() {
    return '$indentation${Emojis.log}   $message';
  }

  @override
  String toString() => 'LogEntry(${toJson()})';

  @override
  List<Object?> get props => [message, timestamp, type];
}
