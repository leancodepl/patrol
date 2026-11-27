import 'package:patrol/src/platform/contracts/contracts.dart';

/// Represents a native view in the UI hierarchy.
///
/// This class provides a unified representation of native views across different
/// platforms (Android and iOS), allowing you to inspect the native UI tree.
class NativeView {
  /// Creates a new [NativeView].
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

  /// Creates a [NativeView] from an iOS native view.
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

  /// Creates a [NativeView] from an Android native view.
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

  /// The class name of the native view.
  ///
  /// On Android, this is the class name. On iOS, this is the element type.
  String? className;

  /// The text content of the native view.
  ///
  /// On Android, this is the text. On iOS, this is the label.
  String? text;

  /// The content description of the native view.
  ///
  /// On Android, this is the content description. On iOS, this is the accessibility label.
  String? contentDescription;

  /// Whether the native view is focused.
  ///
  /// On Android, this is isFocused. On iOS, this is hasFocus.
  late bool focused;

  /// Whether the native view is enabled.
  late bool enabled;

  /// The number of child views.
  ///
  /// On iOS, this is always derived from the children list length.
  int? childCount;

  /// The resource name of the native view.
  ///
  /// On Android, this is the resource name. On iOS, this is the identifier.
  String? resourceName;

  /// The application package of the native view.
  ///
  /// On Android, this is the application package. On iOS, this is the bundle ID.
  String? applicationPackage;

  /// The list of child native views.
  late List<NativeView> children;
}
