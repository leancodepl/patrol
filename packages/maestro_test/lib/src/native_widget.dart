import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_widget.freezed.dart';
part 'native_widget.g.dart';

const textClass = 'Text';
const textFieldClass = 'TextField';
const buttonClass = 'Button';

@freezed
class NativeWidget with _$NativeWidget {
  const factory NativeWidget({
    String? className,
    String? text,
    String? contentDescription,
    bool? enabled,
    bool? focused,
  }) = _NativeWidget;

  factory NativeWidget.fromJson(Map<String, dynamic> json) =>
      _$NativeWidgetFromJson(json);
}
