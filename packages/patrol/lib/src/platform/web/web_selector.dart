import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class WebSelector {
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

  final String? role;
  final String? label;
  final String? placeholder;
  final String? text;
  final String? altText;
  final String? title;
  final String? testId;
  final String? cssOrXpath;
}
