import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:maestro_test/src/custom_selectors.dart';

part 'selector.freezed.dart';
part 'selector.g.dart';

abstract class WidgetClasses {
  /// Maps to the native Text widget for the underlying platform.
  String get text;

  /// Maps to the native TextField widget for the underlying platform.
  String get textField;

  /// Maps to the native Buttonwidget for the underlying platform.
  String get button;

  /// Maps to the native Switch/Toggle widget for the underlying platform.
  String get toggle;
}

class _AndroidWidgetClasses implements WidgetClasses {
  @override
  String get button => 'android.widget.Button';

  @override
  String get text => 'android.widget.TextView';

  @override
  String get textField => 'android.widget.EditText';

  @override
  String get toggle => 'android.widget.Switch';
}

/// Matches widgets on the underlying native platform.
///
/// This *does not* match Flutter widgets. If you want to use Maestro's _custom
/// selector_, see [MaestroTester] and [MaestroFinder].
@freezed
class Selector with _$Selector {
  /// Creates a new [Selector].
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

  /// Creates a new [Selector] from JSON.
  factory Selector.fromJson(Map<String, dynamic> json) =>
      _$SelectorFromJson(json);
}
