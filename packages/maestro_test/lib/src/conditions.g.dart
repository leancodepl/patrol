// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conditions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Conditions _$$_ConditionsFromJson(Map<String, dynamic> json) =>
    _$_Conditions(
      clazz: json['clazz'] as String?,
      enabled: json['enabled'] as bool?,
      focused: json['focused'] as bool?,
      text: json['text'] as String?,
      textContains: json['textContains'] as String?,
      contentDescription: json['contentDescription'] as String?,
    );

Map<String, dynamic> _$$_ConditionsToJson(_$_Conditions instance) =>
    <String, dynamic>{
      'clazz': instance.clazz,
      'enabled': instance.enabled,
      'focused': instance.focused,
      'text': instance.text,
      'textContains': instance.textContains,
      'contentDescription': instance.contentDescription,
    };
