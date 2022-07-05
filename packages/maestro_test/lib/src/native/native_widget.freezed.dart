// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'native_widget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

NativeWidget _$NativeWidgetFromJson(Map<String, dynamic> json) {
  return _NativeWidget.fromJson(json);
}

/// @nodoc
class _$NativeWidgetTearOff {
  const _$NativeWidgetTearOff();

  _NativeWidget call(
      {String? className,
      String? text,
      String? contentDescription,
      bool? enabled,
      bool? focused}) {
    return _NativeWidget(
      className: className,
      text: text,
      contentDescription: contentDescription,
      enabled: enabled,
      focused: focused,
    );
  }

  NativeWidget fromJson(Map<String, Object?> json) {
    return NativeWidget.fromJson(json);
  }
}

/// @nodoc
const $NativeWidget = _$NativeWidgetTearOff();

/// @nodoc
mixin _$NativeWidget {
  String? get className => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  String? get contentDescription => throw _privateConstructorUsedError;
  bool? get enabled => throw _privateConstructorUsedError;
  bool? get focused => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NativeWidgetCopyWith<NativeWidget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NativeWidgetCopyWith<$Res> {
  factory $NativeWidgetCopyWith(
          NativeWidget value, $Res Function(NativeWidget) then) =
      _$NativeWidgetCopyWithImpl<$Res>;
  $Res call(
      {String? className,
      String? text,
      String? contentDescription,
      bool? enabled,
      bool? focused});
}

/// @nodoc
class _$NativeWidgetCopyWithImpl<$Res> implements $NativeWidgetCopyWith<$Res> {
  _$NativeWidgetCopyWithImpl(this._value, this._then);

  final NativeWidget _value;
  // ignore: unused_field
  final $Res Function(NativeWidget) _then;

  @override
  $Res call({
    Object? className = freezed,
    Object? text = freezed,
    Object? contentDescription = freezed,
    Object? enabled = freezed,
    Object? focused = freezed,
  }) {
    return _then(_value.copyWith(
      className: className == freezed
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      text: text == freezed
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      contentDescription: contentDescription == freezed
          ? _value.contentDescription
          : contentDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      enabled: enabled == freezed
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      focused: focused == freezed
          ? _value.focused
          : focused // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
abstract class _$NativeWidgetCopyWith<$Res>
    implements $NativeWidgetCopyWith<$Res> {
  factory _$NativeWidgetCopyWith(
          _NativeWidget value, $Res Function(_NativeWidget) then) =
      __$NativeWidgetCopyWithImpl<$Res>;
  @override
  $Res call(
      {String? className,
      String? text,
      String? contentDescription,
      bool? enabled,
      bool? focused});
}

/// @nodoc
class __$NativeWidgetCopyWithImpl<$Res> extends _$NativeWidgetCopyWithImpl<$Res>
    implements _$NativeWidgetCopyWith<$Res> {
  __$NativeWidgetCopyWithImpl(
      _NativeWidget _value, $Res Function(_NativeWidget) _then)
      : super(_value, (v) => _then(v as _NativeWidget));

  @override
  _NativeWidget get _value => super._value as _NativeWidget;

  @override
  $Res call({
    Object? className = freezed,
    Object? text = freezed,
    Object? contentDescription = freezed,
    Object? enabled = freezed,
    Object? focused = freezed,
  }) {
    return _then(_NativeWidget(
      className: className == freezed
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      text: text == freezed
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      contentDescription: contentDescription == freezed
          ? _value.contentDescription
          : contentDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      enabled: enabled == freezed
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      focused: focused == freezed
          ? _value.focused
          : focused // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_NativeWidget implements _NativeWidget {
  const _$_NativeWidget(
      {this.className,
      this.text,
      this.contentDescription,
      this.enabled,
      this.focused});

  factory _$_NativeWidget.fromJson(Map<String, dynamic> json) =>
      _$$_NativeWidgetFromJson(json);

  @override
  final String? className;
  @override
  final String? text;
  @override
  final String? contentDescription;
  @override
  final bool? enabled;
  @override
  final bool? focused;

  @override
  String toString() {
    return 'NativeWidget(className: $className, text: $text, contentDescription: $contentDescription, enabled: $enabled, focused: $focused)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NativeWidget &&
            const DeepCollectionEquality().equals(other.className, className) &&
            const DeepCollectionEquality().equals(other.text, text) &&
            const DeepCollectionEquality()
                .equals(other.contentDescription, contentDescription) &&
            const DeepCollectionEquality().equals(other.enabled, enabled) &&
            const DeepCollectionEquality().equals(other.focused, focused));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(className),
      const DeepCollectionEquality().hash(text),
      const DeepCollectionEquality().hash(contentDescription),
      const DeepCollectionEquality().hash(enabled),
      const DeepCollectionEquality().hash(focused));

  @JsonKey(ignore: true)
  @override
  _$NativeWidgetCopyWith<_NativeWidget> get copyWith =>
      __$NativeWidgetCopyWithImpl<_NativeWidget>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_NativeWidgetToJson(this);
  }
}

abstract class _NativeWidget implements NativeWidget {
  const factory _NativeWidget(
      {String? className,
      String? text,
      String? contentDescription,
      bool? enabled,
      bool? focused}) = _$_NativeWidget;

  factory _NativeWidget.fromJson(Map<String, dynamic> json) =
      _$_NativeWidget.fromJson;

  @override
  String? get className;
  @override
  String? get text;
  @override
  String? get contentDescription;
  @override
  bool? get enabled;
  @override
  bool? get focused;
  @override
  @JsonKey(ignore: true)
  _$NativeWidgetCopyWith<_NativeWidget> get copyWith =>
      throw _privateConstructorUsedError;
}
