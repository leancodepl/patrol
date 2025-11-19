import 'package:json_annotation/json_annotation.dart';

part 'web_selector.g.dart';

/// A selector for finding UI elements on the web.
@JsonSerializable()
class WebSelector {
  /// Creates a new [WebSelector].
  WebSelector({
    this.role,
    this.label,
    this.placeholder,
    this.text,
    this.altText,
    this.title,
    this.testId,
    this.cssOrXpath,
  });

  /// Converts this selector to JSON.
  Map<String, dynamic> toJson() => _$WebSelectorToJson(this);

  /// The ARIA role of the element.
  final String? role;

  /// The label of the element.
  final String? label;

  /// The placeholder text of the element.
  final String? placeholder;

  /// The text content of the element.
  final String? text;

  /// The alt text of the element.
  final String? altText;

  /// The title of the element.
  final String? title;

  /// The test ID of the element.
  final String? testId;

  /// A CSS selector or XPath expression. Can start with `css=` or `xpath=` to force a specific selector type.
  final String? cssOrXpath;
}
