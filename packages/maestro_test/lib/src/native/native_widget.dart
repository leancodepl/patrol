import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_widget.freezed.dart';
part 'native_widget.g.dart';

/// Represents a native UI control.
///
/// On Android, this is `android.view.View`.
@freezed
class NativeWidget with _$NativeWidget {
  /// Creates a new [NativeWidget].
  const factory NativeWidget({
    String? className,
    String? text,
    String? contentDescription,
    bool? enabled,
    bool? focused,
  }) = _NativeWidget;

  /// Creates a new [NativeWidget] from JSON.
  factory NativeWidget.fromJson(Map<String, dynamic> json) =>
      _$NativeWidgetFromJson(json);
}
