// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_views.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetNativeUITreeResponse _$GetNativeUITreeResponseFromJson(
  Map<String, dynamic> json,
) => GetNativeUITreeResponse()
  ..iOSroots = (json['iOSroots'] as List<dynamic>)
      .map((e) => IOSNativeView.fromJson(e as Map<String, dynamic>))
      .toList()
  ..androidRoots = (json['androidRoots'] as List<dynamic>)
      .map((e) => AndroidNativeView.fromJson(e as Map<String, dynamic>))
      .toList()
  ..roots = (json['roots'] as List<dynamic>)
      .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$GetNativeUITreeResponseToJson(
  GetNativeUITreeResponse instance,
) => <String, dynamic>{
  'iOSroots': instance.iOSroots.map((e) => e.toJson()).toList(),
  'androidRoots': instance.androidRoots.map((e) => e.toJson()).toList(),
  'roots': instance.roots.map((e) => e.toJson()).toList(),
};

NativeView _$NativeViewFromJson(Map<String, dynamic> json) => NativeView(
  className: json['className'] as String?,
  text: json['text'] as String?,
  contentDescription: json['contentDescription'] as String?,
  focused: json['focused'] as bool,
  enabled: json['enabled'] as bool,
  childCount: (json['childCount'] as num?)?.toInt(),
  resourceName: json['resourceName'] as String?,
  applicationPackage: json['applicationPackage'] as String?,
  children: (json['children'] as List<dynamic>)
      .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NativeViewToJson(NativeView instance) =>
    <String, dynamic>{
      'className': instance.className,
      'text': instance.text,
      'contentDescription': instance.contentDescription,
      'focused': instance.focused,
      'enabled': instance.enabled,
      'childCount': instance.childCount,
      'resourceName': instance.resourceName,
      'applicationPackage': instance.applicationPackage,
      'children': instance.children.map((e) => e.toJson()).toList(),
    };
