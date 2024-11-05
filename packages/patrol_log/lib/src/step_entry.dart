import 'package:patrol_log/src/emojis.dart';
import 'package:patrol_log/src/entry.dart';

class StepEntry extends Entry {
  StepEntry({
    required this.action,
    required this.status,
    this.exception,
    this.data,
    DateTime? timestamp,
  }) : super(
          timestamp: timestamp ?? DateTime.now(),
          type: EntryType.step,
        );

  @override
  factory StepEntry.fromJson(Map<String, dynamic> json) => StepEntry(
        action: json['action'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: StepEntryStatus.values[json['status'] as int],
        exception: json['exception'] as String?,
        data: json['data'] as Map<String, dynamic>?,
      );

  final String action;
  final StepEntryStatus status;
  final String? exception;
  final Map<String, dynamic>? data;

  @override
  Map<String, dynamic> toJson() => {
        'action': action,
        'status': status.index,
        'type': type.index,
        'timestamp': timestamp.toIso8601String(),
        'exception': exception,
        'data': data,
      };

  @override
  String pretty({int? number}) {
    return '$indentation${status.name} ${printNumber(number)} $action';
  }

  String printNumber(int? number) {
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
