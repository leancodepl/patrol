// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_widget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_NativeWidget _$$_NativeWidgetFromJson(Map<String, dynamic> json) =>
    _$_NativeWidget(
      className: json['className'] as String?,
      text: json['text'] as String?,
      contentDescription: json['contentDescription'] as String?,
      enabled: json['enabled'] as bool?,
      focused: json['focused'] as bool?,
    );

Map<String, dynamic> _$$_NativeWidgetToJson(_$_NativeWidget instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('className', instance.className);
  writeNotNull('text', instance.text);
  writeNotNull('contentDescription', instance.contentDescription);
  writeNotNull('enabled', instance.enabled);
  writeNotNull('focused', instance.focused);
  return val;
}
