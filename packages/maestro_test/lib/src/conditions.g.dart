// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Conditions _$$_ConditionsFromJson(Map<String, dynamic> json) =>
    _$_Conditions(
      className: json['className'] as String?,
      enabled: json['enabled'] as bool?,
      focused: json['focused'] as bool?,
      text: json['text'] as String?,
      textContains: json['textContains'] as String?,
      contentDescription: json['contentDescription'] as String?,
    );

Map<String, dynamic> _$$_ConditionsToJson(_$_Conditions instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('className', instance.className);
  writeNotNull('enabled', instance.enabled);
  writeNotNull('focused', instance.focused);
  writeNotNull('text', instance.text);
  writeNotNull('textContains', instance.textContains);
  writeNotNull('contentDescription', instance.contentDescription);
  return val;
}
