import 'dart:io';

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

  void clearPreviousLine() {
    // Move the cursor up one line and clear the line
    stdout.write('\x1B[A\x1B[K');
  }

  @override
  String pretty() {
    if (status != StepEntryStatus.start) {
      clearPreviousLine();
    }
    return '        ${status.name}: $action';
  }

  @override
  String toString() => 'StepEntry(${toJson()})';
}

enum StepEntryStatus {
  start,
  success,
  failure;

  String get name {
    switch (this) {
      case StepEntryStatus.start:
        return '⏳';
      case StepEntryStatus.success:
        return '✅';
      case StepEntryStatus.failure:
        return '❌';
    }
  }
}
