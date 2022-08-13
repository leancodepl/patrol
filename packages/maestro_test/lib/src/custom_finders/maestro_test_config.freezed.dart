// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'maestro_test_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$MaestroTestConfigTearOff {
  const _$MaestroTestConfigTearOff();

  _MaestroTestConfig call(
      {Duration existsTimeout = const Duration(seconds: 10),
      Duration visibleTimeout = const Duration(seconds: 10),
      Duration settleTimeout = const Duration(seconds: 10),
      Duration sleep = Duration.zero,
      bool andSettle = true,
      String? appName}) {
    return _MaestroTestConfig(
      existsTimeout: existsTimeout,
      visibleTimeout: visibleTimeout,
      settleTimeout: settleTimeout,
      sleep: sleep,
      andSettle: andSettle,
      appName: appName,
    );
  }
}

/// @nodoc
const $MaestroTestConfig = _$MaestroTestConfigTearOff();

/// @nodoc
mixin _$MaestroTestConfig {
  /// Time after which [MaestroFinder.waitUntilExists] fails if it doesn't
  /// finds a widget.
  Duration get existsTimeout => throw _privateConstructorUsedError;

  /// Time after which [MaestroFinder.waitUntilVisible] fails if it doesn't
  /// finds a widget.
  ///
  /// [MaestroFinder.waitUntilVisible] is used internally by
  /// [MaestroFinder.tap] and [MaestroFinder.enterText].
  Duration get visibleTimeout => throw _privateConstructorUsedError;

  /// Time after which [MaestroTester.pumpAndSettle] fails.
  Duration get settleTimeout => throw _privateConstructorUsedError;

  /// Time to sleep after successful test execution. If set to
  /// [Duration.zero], then the test completes immediately after successful
  /// execution.
  Duration get sleep => throw _privateConstructorUsedError;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [MaestroFinder.tap] and [MaestroFinder]. If false, only
  /// [WidgetTester.pump] is called.
  bool get andSettle => throw _privateConstructorUsedError;

  /// Name of the application under test.
  ///
  /// Used in [MaestroTester.log].
  String? get appName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MaestroTestConfigCopyWith<MaestroTestConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaestroTestConfigCopyWith<$Res> {
  factory $MaestroTestConfigCopyWith(
          MaestroTestConfig value, $Res Function(MaestroTestConfig) then) =
      _$MaestroTestConfigCopyWithImpl<$Res>;
  $Res call(
      {Duration existsTimeout,
      Duration visibleTimeout,
      Duration settleTimeout,
      Duration sleep,
      bool andSettle,
      String? appName});
}

/// @nodoc
class _$MaestroTestConfigCopyWithImpl<$Res>
    implements $MaestroTestConfigCopyWith<$Res> {
  _$MaestroTestConfigCopyWithImpl(this._value, this._then);

  final MaestroTestConfig _value;
  // ignore: unused_field
  final $Res Function(MaestroTestConfig) _then;

  @override
  $Res call({
    Object? existsTimeout = freezed,
    Object? visibleTimeout = freezed,
    Object? settleTimeout = freezed,
    Object? sleep = freezed,
    Object? andSettle = freezed,
    Object? appName = freezed,
  }) {
    return _then(_value.copyWith(
      existsTimeout: existsTimeout == freezed
          ? _value.existsTimeout
          : existsTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
      visibleTimeout: visibleTimeout == freezed
          ? _value.visibleTimeout
          : visibleTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
      settleTimeout: settleTimeout == freezed
          ? _value.settleTimeout
          : settleTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
      sleep: sleep == freezed
          ? _value.sleep
          : sleep // ignore: cast_nullable_to_non_nullable
              as Duration,
      andSettle: andSettle == freezed
          ? _value.andSettle
          : andSettle // ignore: cast_nullable_to_non_nullable
              as bool,
      appName: appName == freezed
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$MaestroTestConfigCopyWith<$Res>
    implements $MaestroTestConfigCopyWith<$Res> {
  factory _$MaestroTestConfigCopyWith(
          _MaestroTestConfig value, $Res Function(_MaestroTestConfig) then) =
      __$MaestroTestConfigCopyWithImpl<$Res>;
  @override
  $Res call(
      {Duration existsTimeout,
      Duration visibleTimeout,
      Duration settleTimeout,
      Duration sleep,
      bool andSettle,
      String? appName});
}

/// @nodoc
class __$MaestroTestConfigCopyWithImpl<$Res>
    extends _$MaestroTestConfigCopyWithImpl<$Res>
    implements _$MaestroTestConfigCopyWith<$Res> {
  __$MaestroTestConfigCopyWithImpl(
      _MaestroTestConfig _value, $Res Function(_MaestroTestConfig) _then)
      : super(_value, (v) => _then(v as _MaestroTestConfig));

  @override
  _MaestroTestConfig get _value => super._value as _MaestroTestConfig;

  @override
  $Res call({
    Object? existsTimeout = freezed,
    Object? visibleTimeout = freezed,
    Object? settleTimeout = freezed,
    Object? sleep = freezed,
    Object? andSettle = freezed,
    Object? appName = freezed,
  }) {
    return _then(_MaestroTestConfig(
      existsTimeout: existsTimeout == freezed
          ? _value.existsTimeout
          : existsTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
      visibleTimeout: visibleTimeout == freezed
          ? _value.visibleTimeout
          : visibleTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
      settleTimeout: settleTimeout == freezed
          ? _value.settleTimeout
          : settleTimeout // ignore: cast_nullable_to_non_nullable
              as Duration,
      sleep: sleep == freezed
          ? _value.sleep
          : sleep // ignore: cast_nullable_to_non_nullable
              as Duration,
      andSettle: andSettle == freezed
          ? _value.andSettle
          : andSettle // ignore: cast_nullable_to_non_nullable
              as bool,
      appName: appName == freezed
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_MaestroTestConfig implements _MaestroTestConfig {
  const _$_MaestroTestConfig(
      {this.existsTimeout = const Duration(seconds: 10),
      this.visibleTimeout = const Duration(seconds: 10),
      this.settleTimeout = const Duration(seconds: 10),
      this.sleep = Duration.zero,
      this.andSettle = true,
      this.appName});

  @JsonKey()
  @override

  /// Time after which [MaestroFinder.waitUntilExists] fails if it doesn't
  /// finds a widget.
  final Duration existsTimeout;
  @JsonKey()
  @override

  /// Time after which [MaestroFinder.waitUntilVisible] fails if it doesn't
  /// finds a widget.
  ///
  /// [MaestroFinder.waitUntilVisible] is used internally by
  /// [MaestroFinder.tap] and [MaestroFinder.enterText].
  final Duration visibleTimeout;
  @JsonKey()
  @override

  /// Time after which [MaestroTester.pumpAndSettle] fails.
  final Duration settleTimeout;
  @JsonKey()
  @override

  /// Time to sleep after successful test execution. If set to
  /// [Duration.zero], then the test completes immediately after successful
  /// execution.
  final Duration sleep;
  @JsonKey()
  @override

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [MaestroFinder.tap] and [MaestroFinder]. If false, only
  /// [WidgetTester.pump] is called.
  final bool andSettle;
  @override

  /// Name of the application under test.
  ///
  /// Used in [MaestroTester.log].
  final String? appName;

  @override
  String toString() {
    return 'MaestroTestConfig(existsTimeout: $existsTimeout, visibleTimeout: $visibleTimeout, settleTimeout: $settleTimeout, sleep: $sleep, andSettle: $andSettle, appName: $appName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MaestroTestConfig &&
            const DeepCollectionEquality()
                .equals(other.existsTimeout, existsTimeout) &&
            const DeepCollectionEquality()
                .equals(other.visibleTimeout, visibleTimeout) &&
            const DeepCollectionEquality()
                .equals(other.settleTimeout, settleTimeout) &&
            const DeepCollectionEquality().equals(other.sleep, sleep) &&
            const DeepCollectionEquality().equals(other.andSettle, andSettle) &&
            const DeepCollectionEquality().equals(other.appName, appName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(existsTimeout),
      const DeepCollectionEquality().hash(visibleTimeout),
      const DeepCollectionEquality().hash(settleTimeout),
      const DeepCollectionEquality().hash(sleep),
      const DeepCollectionEquality().hash(andSettle),
      const DeepCollectionEquality().hash(appName));

  @JsonKey(ignore: true)
  @override
  _$MaestroTestConfigCopyWith<_MaestroTestConfig> get copyWith =>
      __$MaestroTestConfigCopyWithImpl<_MaestroTestConfig>(this, _$identity);
}

abstract class _MaestroTestConfig implements MaestroTestConfig {
  const factory _MaestroTestConfig(
      {Duration existsTimeout,
      Duration visibleTimeout,
      Duration settleTimeout,
      Duration sleep,
      bool andSettle,
      String? appName}) = _$_MaestroTestConfig;

  @override

  /// Time after which [MaestroFinder.waitUntilExists] fails if it doesn't
  /// finds a widget.
  Duration get existsTimeout;
  @override

  /// Time after which [MaestroFinder.waitUntilVisible] fails if it doesn't
  /// finds a widget.
  ///
  /// [MaestroFinder.waitUntilVisible] is used internally by
  /// [MaestroFinder.tap] and [MaestroFinder.enterText].
  Duration get visibleTimeout;
  @override

  /// Time after which [MaestroTester.pumpAndSettle] fails.
  Duration get settleTimeout;
  @override

  /// Time to sleep after successful test execution. If set to
  /// [Duration.zero], then the test completes immediately after successful
  /// execution.
  Duration get sleep;
  @override

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [MaestroFinder.tap] and [MaestroFinder]. If false, only
  /// [WidgetTester.pump] is called.
  bool get andSettle;
  @override

  /// Name of the application under test.
  ///
  /// Used in [MaestroTester.log].
  String? get appName;
  @override
  @JsonKey(ignore: true)
  _$MaestroTestConfigCopyWith<_MaestroTestConfig> get copyWith =>
      throw _privateConstructorUsedError;
}
