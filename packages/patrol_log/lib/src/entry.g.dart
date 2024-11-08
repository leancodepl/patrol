// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogEntry _$LogEntryFromJson(Map<String, dynamic> json) => LogEntry(
      message: json['message'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$LogEntryToJson(LogEntry instance) => <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$EntryTypeEnumMap[instance.type]!,
      'message': instance.message,
    };

const _$EntryTypeEnumMap = {
  EntryType.step: 'step',
  EntryType.test: 'test',
  EntryType.log: 'log',
};

StepEntry _$StepEntryFromJson(Map<String, dynamic> json) => StepEntry(
      action: json['action'] as String,
      status: $enumDecode(_$StepEntryStatusEnumMap, json['status']),
      exception: json['exception'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$StepEntryToJson(StepEntry instance) => <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$EntryTypeEnumMap[instance.type]!,
      'action': instance.action,
      'status': _$StepEntryStatusEnumMap[instance.status]!,
      'exception': instance.exception,
      'data': instance.data,
    };

const _$StepEntryStatusEnumMap = {
  StepEntryStatus.start: 'start',
  StepEntryStatus.success: 'success',
  StepEntryStatus.failure: 'failure',
};

TestEntry _$TestEntryFromJson(Map<String, dynamic> json) => TestEntry(
      name: json['name'] as String,
      status: $enumDecode(_$TestEntryStatusEnumMap, json['status']),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$TestEntryToJson(TestEntry instance) => <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$EntryTypeEnumMap[instance.type]!,
      'name': instance.name,
      'status': _$TestEntryStatusEnumMap[instance.status]!,
      'error': instance.error,
    };

const _$TestEntryStatusEnumMap = {
  TestEntryStatus.start: 'start',
  TestEntryStatus.success: 'success',
  TestEntryStatus.failure: 'failure',
  TestEntryStatus.skip: 'skip',
};
