// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'platform_driver.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Device {
  String get name => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name) android,
    required TResult Function(String name) ios,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name)? android,
    TResult Function(String name)? ios,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name)? android,
    TResult Function(String name)? ios,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AndroidDevice value) android,
    required TResult Function(_IOSDevice value) ios,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_AndroidDevice value)? android,
    TResult Function(_IOSDevice value)? ios,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AndroidDevice value)? android,
    TResult Function(_IOSDevice value)? ios,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeviceCopyWith<Device> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) then) =
      _$DeviceCopyWithImpl<$Res>;
  $Res call({String name});
}

/// @nodoc
class _$DeviceCopyWithImpl<$Res> implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._value, this._then);

  final Device _value;
  // ignore: unused_field
  final $Res Function(Device) _then;

  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_AndroidDeviceCopyWith<$Res>
    implements $DeviceCopyWith<$Res> {
  factory _$$_AndroidDeviceCopyWith(
          _$_AndroidDevice value, $Res Function(_$_AndroidDevice) then) =
      __$$_AndroidDeviceCopyWithImpl<$Res>;
  @override
  $Res call({String name});
}

/// @nodoc
class __$$_AndroidDeviceCopyWithImpl<$Res> extends _$DeviceCopyWithImpl<$Res>
    implements _$$_AndroidDeviceCopyWith<$Res> {
  __$$_AndroidDeviceCopyWithImpl(
      _$_AndroidDevice _value, $Res Function(_$_AndroidDevice) _then)
      : super(_value, (v) => _then(v as _$_AndroidDevice));

  @override
  _$_AndroidDevice get _value => super._value as _$_AndroidDevice;

  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_$_AndroidDevice(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_AndroidDevice implements _AndroidDevice {
  const _$_AndroidDevice({required this.name});

  @override
  final String name;

  @override
  String toString() {
    return 'Device.android(name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AndroidDevice &&
            const DeepCollectionEquality().equals(other.name, name));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(name));

  @JsonKey(ignore: true)
  @override
  _$$_AndroidDeviceCopyWith<_$_AndroidDevice> get copyWith =>
      __$$_AndroidDeviceCopyWithImpl<_$_AndroidDevice>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name) android,
    required TResult Function(String name) ios,
  }) {
    return android(name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name)? android,
    TResult Function(String name)? ios,
  }) {
    return android?.call(name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name)? android,
    TResult Function(String name)? ios,
    required TResult orElse(),
  }) {
    if (android != null) {
      return android(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AndroidDevice value) android,
    required TResult Function(_IOSDevice value) ios,
  }) {
    return android(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_AndroidDevice value)? android,
    TResult Function(_IOSDevice value)? ios,
  }) {
    return android?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AndroidDevice value)? android,
    TResult Function(_IOSDevice value)? ios,
    required TResult orElse(),
  }) {
    if (android != null) {
      return android(this);
    }
    return orElse();
  }
}

abstract class _AndroidDevice implements Device {
  const factory _AndroidDevice({required final String name}) = _$_AndroidDevice;

  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$_AndroidDeviceCopyWith<_$_AndroidDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_IOSDeviceCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$$_IOSDeviceCopyWith(
          _$_IOSDevice value, $Res Function(_$_IOSDevice) then) =
      __$$_IOSDeviceCopyWithImpl<$Res>;
  @override
  $Res call({String name});
}

/// @nodoc
class __$$_IOSDeviceCopyWithImpl<$Res> extends _$DeviceCopyWithImpl<$Res>
    implements _$$_IOSDeviceCopyWith<$Res> {
  __$$_IOSDeviceCopyWithImpl(
      _$_IOSDevice _value, $Res Function(_$_IOSDevice) _then)
      : super(_value, (v) => _then(v as _$_IOSDevice));

  @override
  _$_IOSDevice get _value => super._value as _$_IOSDevice;

  @override
  $Res call({
    Object? name = freezed,
  }) {
    return _then(_$_IOSDevice(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_IOSDevice implements _IOSDevice {
  const _$_IOSDevice({required this.name});

  @override
  final String name;

  @override
  String toString() {
    return 'Device.ios(name: $name)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IOSDevice &&
            const DeepCollectionEquality().equals(other.name, name));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(name));

  @JsonKey(ignore: true)
  @override
  _$$_IOSDeviceCopyWith<_$_IOSDevice> get copyWith =>
      __$$_IOSDeviceCopyWithImpl<_$_IOSDevice>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name) android,
    required TResult Function(String name) ios,
  }) {
    return ios(name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name)? android,
    TResult Function(String name)? ios,
  }) {
    return ios?.call(name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name)? android,
    TResult Function(String name)? ios,
    required TResult orElse(),
  }) {
    if (ios != null) {
      return ios(name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AndroidDevice value) android,
    required TResult Function(_IOSDevice value) ios,
  }) {
    return ios(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_AndroidDevice value)? android,
    TResult Function(_IOSDevice value)? ios,
  }) {
    return ios?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AndroidDevice value)? android,
    TResult Function(_IOSDevice value)? ios,
    required TResult orElse(),
  }) {
    if (ios != null) {
      return ios(this);
    }
    return orElse();
  }
}

abstract class _IOSDevice implements Device {
  const factory _IOSDevice({required final String name}) = _$_IOSDevice;

  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$_IOSDeviceCopyWith<_$_IOSDevice> get copyWith =>
      throw _privateConstructorUsedError;
}
