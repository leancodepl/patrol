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
  ..webRoots = (json['webRoots'] as List<dynamic>)
      .map((e) => WebNativeView.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$GetNativeUITreeResponseToJson(
  GetNativeUITreeResponse instance,
) => <String, dynamic>{
  'iOSroots': instance.iOSroots.map((e) => e.toJson()).toList(),
  'androidRoots': instance.androidRoots.map((e) => e.toJson()).toList(),
  'webRoots': instance.webRoots.map((e) => e.toJson()).toList(),
};

NativeView _$NativeViewFromJson(Map<String, dynamic> json) => NativeView(
  className: json['className'] as String?,
  text: json['text'] as String?,
  contentDescription: json['contentDescription'] as String?,
  isFocused: json['isFocused'] as bool,
  isEnabled: json['isEnabled'] as bool,
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
      'isFocused': instance.isFocused,
      'isEnabled': instance.isEnabled,
      'childCount': instance.childCount,
      'resourceName': instance.resourceName,
      'applicationPackage': instance.applicationPackage,
      'children': instance.children.map((e) => e.toJson()).toList(),
    };

WebNativeView _$WebNativeViewFromJson(Map<String, dynamic> json) =>
    WebNativeView()
      ..tagName = json['tagName'] as String
      ..id = json['id'] as String?
      ..role = json['role'] as String?
      ..ariaLabel = json['ariaLabel'] as String?
      ..testId = json['testId'] as String?
      ..text = json['text'] as String?
      ..isEnabled = json['isEnabled'] as bool
      ..isFocused = json['isFocused'] as bool
      ..isVisible = json['isVisible'] as bool
      ..bounds = json['bounds'] == null
          ? null
          : WebViewBounds.fromJson(json['bounds'] as Map<String, dynamic>)
      ..childCount = (json['childCount'] as num).toInt()
      ..children = (json['children'] as List<dynamic>)
          .map((e) => WebNativeView.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$WebNativeViewToJson(WebNativeView instance) =>
    <String, dynamic>{
      'tagName': instance.tagName,
      'id': instance.id,
      'role': instance.role,
      'ariaLabel': instance.ariaLabel,
      'testId': instance.testId,
      'text': instance.text,
      'isEnabled': instance.isEnabled,
      'isFocused': instance.isFocused,
      'isVisible': instance.isVisible,
      'bounds': instance.bounds?.toJson(),
      'childCount': instance.childCount,
      'children': instance.children.map((e) => e.toJson()).toList(),
    };

WebViewBounds _$WebViewBoundsFromJson(Map<String, dynamic> json) =>
    WebViewBounds()
      ..x = (json['x'] as num).toDouble()
      ..y = (json['y'] as num).toDouble()
      ..width = (json['width'] as num).toDouble()
      ..height = (json['height'] as num).toDouble();

Map<String, dynamic> _$WebViewBoundsToJson(WebViewBounds instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };
