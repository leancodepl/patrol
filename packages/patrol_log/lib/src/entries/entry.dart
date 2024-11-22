import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/src/emojis.dart';

part 'error_entry.dart';
part 'log_entry.dart';
part 'step_entry.dart';
part 'test_entry.dart';
part 'warning_entry.dart';
part 'config_entry.dart';

part 'entry.g.dart';

sealed class Entry with EquatableMixin {
  Entry({required this.timestamp, required this.type});

  // This is a base sealed class, so it should not be instantiated.
  // ignore: avoid_unused_constructor_parameters
  factory Entry.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson is not implemented');
  }

  final DateTime timestamp;

  @JsonKey(includeToJson: true)
  final EntryType type;

  Map<String, dynamic> toJson();

  String pretty();

  @override
  String toString() => throw UnimplementedError('toString is not implemented');

  @override
  List<Object?> get props => [timestamp, type];
}

enum EntryType {
  error,
  step,
  test,
  log,
  warning,
  config;

  static EntryType byName(String name) {
    return switch (name) {
      'error' => EntryType.error,
      'step' => EntryType.step,
      'test' => EntryType.test,
      'log' => EntryType.log,
      'warning' => EntryType.warning,
      'config' => EntryType.config,
      _ => throw ArgumentError('Unknown EntryType: $name')
    };
  }
}

/// The number of spaces used for indentation in the pretty print.
/// Used in LogEntry and StepEntry.
const indentation = '        ';
