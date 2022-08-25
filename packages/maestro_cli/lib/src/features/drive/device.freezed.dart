// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Device {
  String get name => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  TargetPlatform get targetPlatform => throw _privateConstructorUsedError;
  bool get real => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DeviceCopyWith<Device> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) then) =
      _$DeviceCopyWithImpl<$Res>;
  $Res call({String name, String id, TargetPlatform targetPlatform, bool real});
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
    Object? id = freezed,
    Object? targetPlatform = freezed,
    Object? real = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      targetPlatform: targetPlatform == freezed
          ? _value.targetPlatform
          : targetPlatform // ignore: cast_nullable_to_non_nullable
              as TargetPlatform,
      real: real == freezed
          ? _value.real
          : real // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$$_DeviceCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$$_DeviceCopyWith(_$_Device value, $Res Function(_$_Device) then) =
      __$$_DeviceCopyWithImpl<$Res>;
  @override
  $Res call({String name, String id, TargetPlatform targetPlatform, bool real});
}

/// @nodoc
class __$$_DeviceCopyWithImpl<$Res> extends _$DeviceCopyWithImpl<$Res>
    implements _$$_DeviceCopyWith<$Res> {
  __$$_DeviceCopyWithImpl(_$_Device _value, $Res Function(_$_Device) _then)
      : super(_value, (v) => _then(v as _$_Device));

  @override
  _$_Device get _value => super._value as _$_Device;

  @override
  $Res call({
    Object? name = freezed,
    Object? id = freezed,
    Object? targetPlatform = freezed,
    Object? real = freezed,
  }) {
    return _then(_$_Device(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      targetPlatform: targetPlatform == freezed
          ? _value.targetPlatform
          : targetPlatform // ignore: cast_nullable_to_non_nullable
              as TargetPlatform,
      real: real == freezed
          ? _value.real
          : real // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_Device extends _Device {
  const _$_Device(
      {required this.name,
      required this.id,
      required this.targetPlatform,
      required this.real})
      : super._();

  @override
  final String name;
  @override
  final String id;
  @override
  final TargetPlatform targetPlatform;
  @override
  final bool real;

  @override
  String toString() {
    return 'Device(name: $name, id: $id, targetPlatform: $targetPlatform, real: $real)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Device &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality()
                .equals(other.targetPlatform, targetPlatform) &&
            const DeepCollectionEquality().equals(other.real, real));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(targetPlatform),
      const DeepCollectionEquality().hash(real));

  @JsonKey(ignore: true)
  @override
  _$$_DeviceCopyWith<_$_Device> get copyWith =>
      __$$_DeviceCopyWithImpl<_$_Device>(this, _$identity);
}

abstract class _Device extends Device {
  const factory _Device(
      {required final String name,
      required final String id,
      required final TargetPlatform targetPlatform,
      required final bool real}) = _$_Device;
  const _Device._() : super._();

  @override
  String get name;
  @override
  String get id;
  @override
  TargetPlatform get targetPlatform;
  @override
  bool get real;
  @override
  @JsonKey(ignore: true)
  _$$_DeviceCopyWith<_$_Device> get copyWith =>
      throw _privateConstructorUsedError;
}
