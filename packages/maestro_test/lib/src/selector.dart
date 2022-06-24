import 'package:freezed_annotation/freezed_annotation.dart';

part 'selector.freezed.dart';
part 'selector.g.dart';

abstract class WidgetClasses {
  /// Maps to the native Text widget for the underlying platform.
  String get text;

  /// Maps to the native TextField widget for the underlying platform.
  String get textField;

  /// Maps to the native Buttonwidget for the underlying platform.
  String get button;
}

class _AndroidWidgetClasses extends WidgetClasses {
  @override
  String get button => 'com.android.Button';

  @override
  String get text => 'com.android.TextView';

  @override
  String get textField => 'com.android.EditText';
}

@freezed
class Selector with _$Selector {
  const factory Selector({
    String? text,
    String? textStartsWith,
    String? textContains,
    String? className,
    String? contentDescription,
    String? contentDescriptionStartsWith,
    String? contentDescriptionContains,
    String? resourceId,
    int? instance,
    bool? enabled,
    bool? focused,
    String? packageName,
  }) = _Selector;

  factory Selector.fromJson(Map<String, dynamic> json) =>
      _$SelectorFromJson(json);
}
