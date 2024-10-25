import 'package:patrol_log/src/entry.dart';

class LogEntry extends Entry {
  LogEntry({
    required this.message,
    DateTime? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.log,
        );

  @override
  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        message: json['message'] as String,
      );

  final String message;

  @override
  Map<String, dynamic> toJson() => {
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'type': type.index,
      };

  @override
  String pretty() {
    return '        📝 $message';
  }

  @override
  String toString() => 'LogEntry(${toJson()})';
}
