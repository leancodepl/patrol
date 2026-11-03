// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_native_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebNativeView _$WebNativeViewFromJson(Map<String, dynamic> json) =>
    WebNativeView(
      tagName: json['tagName'] as String,
      isEnabled: json['isEnabled'] as bool,
      isFocused: json['isFocused'] as bool,
      isVisible: json['isVisible'] as bool,
      childCount: (json['childCount'] as num).toInt(),
      children: (json['children'] as List<dynamic>)
          .map((e) => WebNativeView.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String?,
      role: json['role'] as String?,
      ariaLabel: json['ariaLabel'] as String?,
      testId: json['testId'] as String?,
      text: json['text'] as String?,
      bounds: json['bounds'] == null
          ? null
          : WebViewBounds.fromJson(json['bounds'] as Map<String, dynamic>),
    );

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
    WebViewBounds(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$WebViewBoundsToJson(WebViewBounds instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

WebGetNativeViewsResponse _$WebGetNativeViewsResponseFromJson(
  Map<String, dynamic> json,
) => WebGetNativeViewsResponse(
  roots: (json['roots'] as List<dynamic>)
      .map((e) => WebNativeView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WebGetNativeViewsResponseToJson(
  WebGetNativeViewsResponse instance,
) => <String, dynamic>{'roots': instance.roots.map((e) => e.toJson()).toList()};
