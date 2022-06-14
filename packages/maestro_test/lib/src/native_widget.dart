import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_widget.freezed.dart';
part 'native_widget.g.dart';

const TextClass = 'Text';
const TextFieldClass = 'TextField';
const ButtonClass = 'Button';

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
