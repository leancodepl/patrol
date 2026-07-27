import 'package:json_annotation/json_annotation.dart';

part 'web_native_view.g.dart';

/// A DOM element of the page under test, as reported by the Playwright driver.
///
/// On web the DOM plays the role the native view hierarchy plays on Android and
/// iOS: web selectors resolve against it, and with semantics enabled Flutter
/// renders `<flt-semantics>` elements carrying the roles and labels those
/// selectors match.
@JsonSerializable()
class WebNativeView {
  /// Creates a new [WebNativeView].
  WebNativeView({
    required this.tagName,
    required this.isEnabled,
    required this.isFocused,
    required this.isVisible,
    required this.childCount,
    required this.children,
    this.id,
    this.role,
    this.ariaLabel,
    this.testId,
    this.text,
    this.bounds,
  });

  /// Creates a [WebNativeView] from JSON.
  factory WebNativeView.fromJson(Map<String, dynamic> json) =>
      _$WebNativeViewFromJson(json);

  /// Converts this view to JSON.
  Map<String, dynamic> toJson() => _$WebNativeViewToJson(this);

  /// The element's tag name, e.g. `FLT-SEMANTICS` or `DIV`.
  final String tagName;

  /// The element's `id` attribute.
  final String? id;

  /// The element's ARIA `role` attribute.
  final String? role;

  /// The element's `aria-label` attribute.
  final String? ariaLabel;

  /// The element's `data-testid` attribute.
  final String? testId;

  /// Text belonging directly to this element, excluding its descendants'.
  final String? text;

  /// Whether the element is not disabled.
  final bool isEnabled;

  /// Whether the element is the document's active element.
  final bool isFocused;

  /// Whether the element is rendered and takes up space.
  final bool isVisible;

  /// The element's bounding box, in CSS pixels relative to the viewport.
  final WebViewBounds? bounds;

  /// The number of reported children.
  final int childCount;

  /// The element's children, minus structural ones (scripts, styles, etc.).
  final List<WebNativeView> children;
}

/// The bounding box of a [WebNativeView].
@JsonSerializable()
class WebViewBounds {
  /// Creates a new [WebViewBounds].
  WebViewBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Creates a [WebViewBounds] from JSON.
  factory WebViewBounds.fromJson(Map<String, dynamic> json) =>
      _$WebViewBoundsFromJson(json);

  /// Converts these bounds to JSON.
  Map<String, dynamic> toJson() => _$WebViewBoundsToJson(this);

  /// Distance from the left edge of the viewport.
  final double x;

  /// Distance from the top edge of the viewport.
  final double y;

  /// The element's width.
  final double width;

  /// The element's height.
  final double height;
}

/// Response of the web `getNativeViews` action.
@JsonSerializable()
class WebGetNativeViewsResponse {
  /// Creates a new [WebGetNativeViewsResponse].
  WebGetNativeViewsResponse({required this.roots});

  /// Creates a [WebGetNativeViewsResponse] from JSON.
  factory WebGetNativeViewsResponse.fromJson(Map<String, dynamic> json) =>
      _$WebGetNativeViewsResponseFromJson(json);

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => _$WebGetNativeViewsResponseToJson(this);

  /// The root elements of the page, normally a single `BODY`.
  final List<WebNativeView> roots;
}
