// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'test_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$TestCommandConfig {
  List<Device> get devices => throw _privateConstructorUsedError;
  List<String> get targets => throw _privateConstructorUsedError;
  String? get flavor => throw _privateConstructorUsedError;
  Map<String, String> get dartDefines => throw _privateConstructorUsedError;
  String? get packageName => throw _privateConstructorUsedError;
  String? get bundleId => throw _privateConstructorUsedError;
  int get repeat => throw _privateConstructorUsedError;
  bool get displayLabel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TestCommandConfigCopyWith<TestCommandConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TestCommandConfigCopyWith<$Res> {
  factory $TestCommandConfigCopyWith(
          TestCommandConfig value, $Res Function(TestCommandConfig) then) =
      _$TestCommandConfigCopyWithImpl<$Res>;
  $Res call(
      {List<Device> devices,
      List<String> targets,
      String? flavor,
      Map<String, String> dartDefines,
      String? packageName,
      String? bundleId,
      int repeat,
      bool displayLabel});
}

/// @nodoc
class _$TestCommandConfigCopyWithImpl<$Res>
    implements $TestCommandConfigCopyWith<$Res> {
  _$TestCommandConfigCopyWithImpl(this._value, this._then);

  final TestCommandConfig _value;
  // ignore: unused_field
  final $Res Function(TestCommandConfig) _then;

  @override
  $Res call({
    Object? devices = freezed,
    Object? targets = freezed,
    Object? flavor = freezed,
    Object? dartDefines = freezed,
    Object? packageName = freezed,
    Object? bundleId = freezed,
    Object? repeat = freezed,
    Object? displayLabel = freezed,
  }) {
    return _then(_value.copyWith(
      devices: devices == freezed
          ? _value.devices
          : devices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      targets: targets == freezed
          ? _value.targets
          : targets // ignore: cast_nullable_to_non_nullable
              as List<String>,
      flavor: flavor == freezed
          ? _value.flavor
          : flavor // ignore: cast_nullable_to_non_nullable
              as String?,
      dartDefines: dartDefines == freezed
          ? _value.dartDefines
          : dartDefines // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      packageName: packageName == freezed
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String?,
      bundleId: bundleId == freezed
          ? _value.bundleId
          : bundleId // ignore: cast_nullable_to_non_nullable
              as String?,
      repeat: repeat == freezed
          ? _value.repeat
          : repeat // ignore: cast_nullable_to_non_nullable
              as int,
      displayLabel: displayLabel == freezed
          ? _value.displayLabel
          : displayLabel // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
abstract class _$$_TestCommandConfigCopyWith<$Res>
    implements $TestCommandConfigCopyWith<$Res> {
  factory _$$_TestCommandConfigCopyWith(_$_TestCommandConfig value,
          $Res Function(_$_TestCommandConfig) then) =
      __$$_TestCommandConfigCopyWithImpl<$Res>;
  @override
  $Res call(
      {List<Device> devices,
      List<String> targets,
      String? flavor,
      Map<String, String> dartDefines,
      String? packageName,
      String? bundleId,
      int repeat,
      bool displayLabel});
}

/// @nodoc
class __$$_TestCommandConfigCopyWithImpl<$Res>
    extends _$TestCommandConfigCopyWithImpl<$Res>
    implements _$$_TestCommandConfigCopyWith<$Res> {
  __$$_TestCommandConfigCopyWithImpl(
      _$_TestCommandConfig _value, $Res Function(_$_TestCommandConfig) _then)
      : super(_value, (v) => _then(v as _$_TestCommandConfig));

  @override
  _$_TestCommandConfig get _value => super._value as _$_TestCommandConfig;

  @override
  $Res call({
    Object? devices = freezed,
    Object? targets = freezed,
    Object? flavor = freezed,
    Object? dartDefines = freezed,
    Object? packageName = freezed,
    Object? bundleId = freezed,
    Object? repeat = freezed,
    Object? displayLabel = freezed,
  }) {
    return _then(_$_TestCommandConfig(
      devices: devices == freezed
          ? _value._devices
          : devices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      targets: targets == freezed
          ? _value._targets
          : targets // ignore: cast_nullable_to_non_nullable
              as List<String>,
      flavor: flavor == freezed
          ? _value.flavor
          : flavor // ignore: cast_nullable_to_non_nullable
              as String?,
      dartDefines: dartDefines == freezed
          ? _value._dartDefines
          : dartDefines // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      packageName: packageName == freezed
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String?,
      bundleId: bundleId == freezed
          ? _value.bundleId
          : bundleId // ignore: cast_nullable_to_non_nullable
              as String?,
      repeat: repeat == freezed
          ? _value.repeat
          : repeat // ignore: cast_nullable_to_non_nullable
              as int,
      displayLabel: displayLabel == freezed
          ? _value.displayLabel
          : displayLabel // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$_TestCommandConfig implements _TestCommandConfig {
  const _$_TestCommandConfig(
      {required final List<Device> devices,
      required final List<String> targets,
      required this.flavor,
      required final Map<String, String> dartDefines,
      required this.packageName,
      required this.bundleId,
      required this.repeat,
      required this.displayLabel})
      : _devices = devices,
        _targets = targets,
        _dartDefines = dartDefines;

  final List<Device> _devices;
  @override
  List<Device> get devices {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_devices);
  }

  final List<String> _targets;
  @override
  List<String> get targets {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_targets);
  }

  @override
  final String? flavor;
  final Map<String, String> _dartDefines;
  @override
  Map<String, String> get dartDefines {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dartDefines);
  }

  @override
  final String? packageName;
  @override
  final String? bundleId;
  @override
  final int repeat;
  @override
  final bool displayLabel;

  @override
  String toString() {
    return 'TestCommandConfig(devices: $devices, targets: $targets, flavor: $flavor, dartDefines: $dartDefines, packageName: $packageName, bundleId: $bundleId, repeat: $repeat, displayLabel: $displayLabel)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TestCommandConfig &&
            const DeepCollectionEquality().equals(other._devices, _devices) &&
            const DeepCollectionEquality().equals(other._targets, _targets) &&
            const DeepCollectionEquality().equals(other.flavor, flavor) &&
            const DeepCollectionEquality()
                .equals(other._dartDefines, _dartDefines) &&
            const DeepCollectionEquality()
                .equals(other.packageName, packageName) &&
            const DeepCollectionEquality().equals(other.bundleId, bundleId) &&
            const DeepCollectionEquality().equals(other.repeat, repeat) &&
            const DeepCollectionEquality()
                .equals(other.displayLabel, displayLabel));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_devices),
      const DeepCollectionEquality().hash(_targets),
      const DeepCollectionEquality().hash(flavor),
      const DeepCollectionEquality().hash(_dartDefines),
      const DeepCollectionEquality().hash(packageName),
      const DeepCollectionEquality().hash(bundleId),
      const DeepCollectionEquality().hash(repeat),
      const DeepCollectionEquality().hash(displayLabel));

  @JsonKey(ignore: true)
  @override
  _$$_TestCommandConfigCopyWith<_$_TestCommandConfig> get copyWith =>
      __$$_TestCommandConfigCopyWithImpl<_$_TestCommandConfig>(
          this, _$identity);
}

abstract class _TestCommandConfig implements TestCommandConfig {
  const factory _TestCommandConfig(
      {required final List<Device> devices,
      required final List<String> targets,
      required final String? flavor,
      required final Map<String, String> dartDefines,
      required final String? packageName,
      required final String? bundleId,
      required final int repeat,
      required final bool displayLabel}) = _$_TestCommandConfig;

  @override
  List<Device> get devices;
  @override
  List<String> get targets;
  @override
  String? get flavor;
  @override
  Map<String, String> get dartDefines;
  @override
  String? get packageName;
  @override
  String? get bundleId;
  @override
  int get repeat;
  @override
  bool get displayLabel;
  @override
  @JsonKey(ignore: true)
  _$$_TestCommandConfigCopyWith<_$_TestCommandConfig> get copyWith =>
      throw _privateConstructorUsedError;
}
