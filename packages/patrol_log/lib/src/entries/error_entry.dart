part of 'entry.dart';

@JsonSerializable()
class ErrorEntry extends Entry {
  ErrorEntry({
    required this.message,
    DateTime? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.error,
        );

  @override
  factory ErrorEntry.fromJson(Map<String, dynamic> json) =>
      _$ErrorEntryFromJson(json);

  final String message;

  @override
  Map<String, dynamic> toJson() => _$ErrorEntryToJson(this);

  @override
  String pretty() {
    return '${AnsiCodes.red}$message${AnsiCodes.reset}';
  }

  @override
  String toString() => 'ErrorEntry(${toJson()})';

  @override
  List<Object?> get props => [message, timestamp, type];
}
