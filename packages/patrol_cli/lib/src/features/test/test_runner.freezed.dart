// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'test_runner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$AppOptions {
  String get target => throw _privateConstructorUsedError;
  String? get flavor => throw _privateConstructorUsedError;
  Map<String, String> get dartDefines => throw _privateConstructorUsedError;
  Platform get platform => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppOptionsCopyWith<AppOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppOptionsCopyWith<$Res> {
  factory $AppOptionsCopyWith(
          AppOptions value, $Res Function(AppOptions) then) =
      _$AppOptionsCopyWithImpl<$Res>;
  $Res call(
      {String target,
      String? flavor,
      Map<String, String> dartDefines,
      Platform platform});
}

/// @nodoc
class _$AppOptionsCopyWithImpl<$Res> implements $AppOptionsCopyWith<$Res> {
  _$AppOptionsCopyWithImpl(this._value, this._then);

  final AppOptions _value;
  // ignore: unused_field
  final $Res Function(AppOptions) _then;

  @override
  $Res call({
    Object? target = freezed,
    Object? flavor = freezed,
    Object? dartDefines = freezed,
    Object? platform = freezed,
  }) {
    return _then(_value.copyWith(
      target: target == freezed
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
      flavor: flavor == freezed
          ? _value.flavor
          : flavor // ignore: cast_nullable_to_non_nullable
              as String?,
      dartDefines: dartDefines == freezed
          ? _value.dartDefines
          : dartDefines // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      platform: platform == freezed
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as Platform,
    ));
  }
}

/// @nodoc
abstract class _$$_AppOptionsCopyWith<$Res>
    implements $AppOptionsCopyWith<$Res> {
  factory _$$_AppOptionsCopyWith(
          _$_AppOptions value, $Res Function(_$_AppOptions) then) =
      __$$_AppOptionsCopyWithImpl<$Res>;
  @override
  $Res call(
      {String target,
      String? flavor,
      Map<String, String> dartDefines,
      Platform platform});
}

/// @nodoc
class __$$_AppOptionsCopyWithImpl<$Res> extends _$AppOptionsCopyWithImpl<$Res>
    implements _$$_AppOptionsCopyWith<$Res> {
  __$$_AppOptionsCopyWithImpl(
      _$_AppOptions _value, $Res Function(_$_AppOptions) _then)
      : super(_value, (v) => _then(v as _$_AppOptions));

  @override
  _$_AppOptions get _value => super._value as _$_AppOptions;

  @override
  $Res call({
    Object? target = freezed,
    Object? flavor = freezed,
    Object? dartDefines = freezed,
    Object? platform = freezed,
  }) {
    return _then(_$_AppOptions(
      target: target == freezed
          ? _value.target
          : target // ignore: cast_nullable_to_non_nullable
              as String,
      flavor: flavor == freezed
          ? _value.flavor
          : flavor // ignore: cast_nullable_to_non_nullable
              as String?,
      dartDefines: dartDefines == freezed
          ? _value._dartDefines
          : dartDefines // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      platform: platform == freezed
          ? _value.platform
          : platform // ignore: cast_nullable_to_non_nullable
              as Platform,
    ));
  }
}

/// @nodoc

class _$_AppOptions implements _AppOptions {
  const _$_AppOptions(
      {required this.target,
      required this.flavor,
      required final Map<String, String> dartDefines,
      required this.platform})
      : _dartDefines = dartDefines;

  @override
  final String target;
  @override
  final String? flavor;
  final Map<String, String> _dartDefines;
  @override
  Map<String, String> get dartDefines {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dartDefines);
  }

  @override
  final Platform platform;

  @override
  String toString() {
    return 'AppOptions(target: $target, flavor: $flavor, dartDefines: $dartDefines, platform: $platform)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AppOptions &&
            const DeepCollectionEquality().equals(other.target, target) &&
            const DeepCollectionEquality().equals(other.flavor, flavor) &&
            const DeepCollectionEquality()
                .equals(other._dartDefines, _dartDefines) &&
            const DeepCollectionEquality().equals(other.platform, platform));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(target),
      const DeepCollectionEquality().hash(flavor),
      const DeepCollectionEquality().hash(_dartDefines),
      const DeepCollectionEquality().hash(platform));

  @JsonKey(ignore: true)
  @override
  _$$_AppOptionsCopyWith<_$_AppOptions> get copyWith =>
      __$$_AppOptionsCopyWithImpl<_$_AppOptions>(this, _$identity);
}

abstract class _AppOptions implements AppOptions {
  const factory _AppOptions(
      {required final String target,
      required final String? flavor,
      required final Map<String, String> dartDefines,
      required final Platform platform}) = _$_AppOptions;

  @override
  String get target;
  @override
  String? get flavor;
  @override
  Map<String, String> get dartDefines;
  @override
  Platform get platform;
  @override
  @JsonKey(ignore: true)
  _$$_AppOptionsCopyWith<_$_AppOptions> get copyWith =>
      throw _privateConstructorUsedError;
}
