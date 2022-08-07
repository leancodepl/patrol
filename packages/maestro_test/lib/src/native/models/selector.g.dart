// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Selector _$$_SelectorFromJson(Map<String, dynamic> json) => _$_Selector(
      text: json['text'] as String?,
      textStartsWith: json['textStartsWith'] as String?,
      textContains: json['textContains'] as String?,
      className: json['className'] as String?,
      contentDescription: json['contentDescription'] as String?,
      contentDescriptionStartsWith:
          json['contentDescriptionStartsWith'] as String?,
      contentDescriptionContains: json['contentDescriptionContains'] as String?,
      resourceId: json['resourceId'] as String?,
      instance: json['instance'] as int?,
      enabled: json['enabled'] as bool?,
      focused: json['focused'] as bool?,
      packageName: json['packageName'] as String?,
    );

Map<String, dynamic> _$$_SelectorToJson(_$_Selector instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('text', instance.text);
  writeNotNull('textStartsWith', instance.textStartsWith);
  writeNotNull('textContains', instance.textContains);
  writeNotNull('className', instance.className);
  writeNotNull('contentDescription', instance.contentDescription);
  writeNotNull(
    'contentDescriptionStartsWith',
    instance.contentDescriptionStartsWith,
  );
  writeNotNull(
    'contentDescriptionContains',
    instance.contentDescriptionContains,
  );
  writeNotNull('resourceId', instance.resourceId);
  writeNotNull('instance', instance.instance);
  writeNotNull('enabled', instance.enabled);
  writeNotNull('focused', instance.focused);
  writeNotNull('packageName', instance.packageName);
  return val;
}
