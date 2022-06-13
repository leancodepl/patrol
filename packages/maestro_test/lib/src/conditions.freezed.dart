// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'conditions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Conditions _$ConditionsFromJson(Map<String, dynamic> json) {
  return _Conditions.fromJson(json);
}

/// @nodoc
mixin _$Conditions {
  String? get className => throw _privateConstructorUsedError;
  bool? get enabled => throw _privateConstructorUsedError;
  bool? get focused => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  String? get textContains => throw _privateConstructorUsedError;
  String? get contentDescription => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConditionsCopyWith<Conditions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionsCopyWith<$Res> {
  factory $ConditionsCopyWith(
          Conditions value, $Res Function(Conditions) then) =
      _$ConditionsCopyWithImpl<$Res>;
  $Res call(
      {String? className,
      bool? enabled,
      bool? focused,
      String? text,
      String? textContains,
      String? contentDescription});
}

/// @nodoc
class _$ConditionsCopyWithImpl<$Res> implements $ConditionsCopyWith<$Res> {
  _$ConditionsCopyWithImpl(this._value, this._then);

  final Conditions _value;
  // ignore: unused_field
  final $Res Function(Conditions) _then;

  @override
  $Res call({
    Object? className = freezed,
    Object? enabled = freezed,
    Object? focused = freezed,
    Object? text = freezed,
    Object? textContains = freezed,
    Object? contentDescription = freezed,
  }) {
    return _then(_value.copyWith(
      className: className == freezed
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      enabled: enabled == freezed
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      focused: focused == freezed
          ? _value.focused
          : focused // ignore: cast_nullable_to_non_nullable
              as bool?,
      text: text == freezed
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      textContains: textContains == freezed
          ? _value.textContains
          : textContains // ignore: cast_nullable_to_non_nullable
              as String?,
      contentDescription: contentDescription == freezed
          ? _value.contentDescription
          : contentDescription // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_ConditionsCopyWith<$Res>
    implements $ConditionsCopyWith<$Res> {
  factory _$$_ConditionsCopyWith(
          _$_Conditions value, $Res Function(_$_Conditions) then) =
      __$$_ConditionsCopyWithImpl<$Res>;
  @override
  $Res call(
      {String? className,
      bool? enabled,
      bool? focused,
      String? text,
      String? textContains,
      String? contentDescription});
}

/// @nodoc
class __$$_ConditionsCopyWithImpl<$Res> extends _$ConditionsCopyWithImpl<$Res>
    implements _$$_ConditionsCopyWith<$Res> {
  __$$_ConditionsCopyWithImpl(
      _$_Conditions _value, $Res Function(_$_Conditions) _then)
      : super(_value, (v) => _then(v as _$_Conditions));

  @override
  _$_Conditions get _value => super._value as _$_Conditions;

  @override
  $Res call({
    Object? className = freezed,
    Object? enabled = freezed,
    Object? focused = freezed,
    Object? text = freezed,
    Object? textContains = freezed,
    Object? contentDescription = freezed,
  }) {
    return _then(_$_Conditions(
      className: className == freezed
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      enabled: enabled == freezed
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      focused: focused == freezed
          ? _value.focused
          : focused // ignore: cast_nullable_to_non_nullable
              as bool?,
      text: text == freezed
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      textContains: textContains == freezed
          ? _value.textContains
          : textContains // ignore: cast_nullable_to_non_nullable
              as String?,
      contentDescription: contentDescription == freezed
          ? _value.contentDescription
          : contentDescription // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Conditions implements _Conditions {
  const _$_Conditions(
      {this.className,
      this.enabled,
      this.focused,
      this.text,
      this.textContains,
      this.contentDescription});

  factory _$_Conditions.fromJson(Map<String, dynamic> json) =>
      _$$_ConditionsFromJson(json);

  @override
  final String? className;
  @override
  final bool? enabled;
  @override
  final bool? focused;
  @override
  final String? text;
  @override
  final String? textContains;
  @override
  final String? contentDescription;

  @override
  String toString() {
    return 'Conditions(className: $className, enabled: $enabled, focused: $focused, text: $text, textContains: $textContains, contentDescription: $contentDescription)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Conditions &&
            const DeepCollectionEquality().equals(other.className, className) &&
            const DeepCollectionEquality().equals(other.enabled, enabled) &&
            const DeepCollectionEquality().equals(other.focused, focused) &&
            const DeepCollectionEquality().equals(other.text, text) &&
            const DeepCollectionEquality()
                .equals(other.textContains, textContains) &&
            const DeepCollectionEquality()
                .equals(other.contentDescription, contentDescription));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(className),
      const DeepCollectionEquality().hash(enabled),
      const DeepCollectionEquality().hash(focused),
      const DeepCollectionEquality().hash(text),
      const DeepCollectionEquality().hash(textContains),
      const DeepCollectionEquality().hash(contentDescription));

  @JsonKey(ignore: true)
  @override
  _$$_ConditionsCopyWith<_$_Conditions> get copyWith =>
      __$$_ConditionsCopyWithImpl<_$_Conditions>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ConditionsToJson(this);
  }
}

abstract class _Conditions implements Conditions {
  const factory _Conditions(
      {final String? className,
      final bool? enabled,
      final bool? focused,
      final String? text,
      final String? textContains,
      final String? contentDescription}) = _$_Conditions;

  factory _Conditions.fromJson(Map<String, dynamic> json) =
      _$_Conditions.fromJson;

  @override
  String? get className => throw _privateConstructorUsedError;
  @override
  bool? get enabled => throw _privateConstructorUsedError;
  @override
  bool? get focused => throw _privateConstructorUsedError;
  @override
  String? get text => throw _privateConstructorUsedError;
  @override
  String? get textContains => throw _privateConstructorUsedError;
  @override
  String? get contentDescription => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_ConditionsCopyWith<_$_Conditions> get copyWith =>
      throw _privateConstructorUsedError;
}
