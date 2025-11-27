// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_selector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebSelector _$WebSelectorFromJson(Map<String, dynamic> json) => WebSelector(
  role: json['role'] as String?,
  label: json['label'] as String?,
  placeholder: json['placeholder'] as String?,
  text: json['text'] as String?,
  altText: json['altText'] as String?,
  title: json['title'] as String?,
  testId: json['testId'] as String?,
  cssOrXpath: json['cssOrXpath'] as String?,
);

Map<String, dynamic> _$WebSelectorToJson(WebSelector instance) =>
    <String, dynamic>{
      'role': instance.role,
      'label': instance.label,
      'placeholder': instance.placeholder,
      'text': instance.text,
      'altText': instance.altText,
      'title': instance.title,
      'testId': instance.testId,
      'cssOrXpath': instance.cssOrXpath,
    };
