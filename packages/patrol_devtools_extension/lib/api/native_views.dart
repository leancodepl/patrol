import 'package:json_annotation/json_annotation.dart';
import 'package:patrol_devtools_extension/api/contracts.dart';

part 'native_views.g.dart';

@JsonSerializable()
class GetNativeUITreeResponse {
  GetNativeUITreeResponse();

  factory GetNativeUITreeResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNativeUITreeResponseFromJson(json);

  late List<IOSNativeView> iOSroots;
  late List<AndroidNativeView> androidRoots;
  late List<WebNativeView> webRoots;

  Map<String, dynamic> toJson() => _$GetNativeUITreeResponseToJson(this);
}

// this is copy paste from patrol/lib/src/native/native_automator.dart but don't have time/idea to make it better currently
@JsonSerializable()
class NativeView {
  NativeView({
    required this.className,
    required this.text,
    required this.contentDescription,
    required this.isFocused,
    required this.isEnabled,
    required this.childCount,
    required this.resourceName,
    required this.applicationPackage,
    required this.children,
  });

  factory NativeView.fromJson(Map<String, dynamic> json) =>
      _$NativeViewFromJson(json);

  factory NativeView.fromAndroid(AndroidNativeView androidNativeView) {
    return NativeView(
      className: androidNativeView.className,
      text: androidNativeView.text,
      contentDescription: androidNativeView.contentDescription,
      isFocused: androidNativeView.isFocused,
      isEnabled: androidNativeView.isEnabled,
      childCount: androidNativeView.childCount,
      resourceName: androidNativeView.resourceName,
      applicationPackage: androidNativeView.applicationPackage,
      children: androidNativeView.children.map(NativeView.fromAndroid).toList(),
    );
  }

  factory NativeView.fromIOS(IOSNativeView iosNativeView) {
    return NativeView(
      className: iosNativeView.elementType.name,
      text: iosNativeView.label,
      contentDescription: iosNativeView.accessibilityLabel,
      isFocused: iosNativeView.hasFocus,
      isEnabled: iosNativeView.isEnabled,
      childCount: iosNativeView.children.length,
      resourceName: iosNativeView.identifier,
      applicationPackage: iosNativeView.bundleId,
      children: iosNativeView.children.map(NativeView.fromIOS).toList(),
    );
  }

  String? className;
  String? text;
  String? contentDescription;
  late bool isFocused;
  late bool isEnabled;
  int? childCount;
  String? resourceName;
  String? applicationPackage;
  late List<NativeView> children;

  Map<String, dynamic> toJson() => _$NativeViewToJson(this);
}

/// A DOM element of the page under test.
///
/// Kept in sync by hand with `WebNativeView` in package:patrol -- web contracts
/// aren't part of schema.dart, same as [NativeView] above.
@JsonSerializable()
class WebNativeView {
  WebNativeView();

  factory WebNativeView.fromJson(Map<String, dynamic> json) =>
      _$WebNativeViewFromJson(json);

  late String tagName;
  String? id;
  String? role;
  String? ariaLabel;
  String? testId;
  String? text;
  late bool isEnabled;
  late bool isFocused;
  late bool isVisible;
  WebViewBounds? bounds;
  late int childCount;
  late List<WebNativeView> children;

  Map<String, dynamic> toJson() => _$WebNativeViewToJson(this);
}

/// The bounding box of a [WebNativeView].
@JsonSerializable()
class WebViewBounds {
  WebViewBounds();

  factory WebViewBounds.fromJson(Map<String, dynamic> json) =>
      _$WebViewBoundsFromJson(json);

  late double x;
  late double y;
  late double width;
  late double height;

  Map<String, dynamic> toJson() => _$WebViewBoundsToJson(this);
}
