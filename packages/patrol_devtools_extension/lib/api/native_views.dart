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
  late List<NativeView> roots;

  Map<String, dynamic> toJson() => _$GetNativeUITreeResponseToJson(this);
}

// this is copy paste from patrol/lib/src/native/native_automator.dart but don't have time/idea to make it better currently
@JsonSerializable()
class NativeView {
  NativeView({
    required this.className,
    required this.text,
    required this.contentDescription,
    required this.focused,
    required this.enabled,
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
      focused: androidNativeView.isFocused,
      enabled: androidNativeView.isEnabled,
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
      focused: iosNativeView.hasFocus,
      enabled: iosNativeView.isEnabled,
      childCount: iosNativeView.children.length,
      resourceName: iosNativeView.identifier,
      applicationPackage: iosNativeView.bundleId,
      children: iosNativeView.children.map(NativeView.fromIOS).toList(),
    );
  }

  String? className;
  String? text;
  String? contentDescription;
  late bool focused;
  late bool enabled;
  int? childCount;
  String? resourceName;
  String? applicationPackage;
  late List<NativeView> children;

  Map<String, dynamic> toJson() => _$NativeViewToJson(this);
}
