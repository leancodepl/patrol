// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'patrol_test_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PatrolTestConfig {
  /// Time after which [PatrolFinder.waitUntilExists] fails if it doesn't
  /// finds a widget.
  Duration get existsTimeout => throw _privateConstructorUsedError;

  /// Time after which [PatrolFinder.waitUntilVisible] fails if it doesn't
  /// finds a widget.
  ///
  /// [PatrolFinder.waitUntilVisible] is used internally by [PatrolFinder.tap]
  /// and [PatrolFinder.enterText].
  Duration get visibleTimeout => throw _privateConstructorUsedError;

  /// Time after which [PatrolTester.pumpAndSettle] fails.
  Duration get settleTimeout => throw _privateConstructorUsedError;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [PatrolFinder.tap] and [PatrolFinder]. If false, only
  /// [WidgetTester.pump] is called.
  bool get andSettle => throw _privateConstructorUsedError;

  /// Name of the application under test.
  ///
  /// Used in [PatrolTester.log].
  String? get appName => throw _privateConstructorUsedError;

  /// Package name of the application under test.
  ///
  /// Android only.
  String? get packageName => throw _privateConstructorUsedError;

  /// Bundle identifier name of the application under test.
  ///
  /// iOS only.
  String? get bundleId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PatrolTestConfigCopyWith<PatrolTestConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatrolTestConfigCopyWith<$Res> {
  factory $PatrolTestConfigCopyWith(
          PatrolTestConfig value, $Res Function(PatrolTestConfig) then) =
      _$PatrolTestConfigCopyWithImpl<$Res>;
  $Res call(
      {Duration existsTimeout,
      Duration visibleTimeout,
      Duration settleTimeout,
      bool andSettle,
      String? appName,
      String? packageName,
      String? bundleId});
}

/// @nodoc
class _$PatrolTestConfigCopyWithImpl<$Res>
    implements $PatrolTestConfigCopyWith<$Res> {
  _$PatrolTestConfigCopyWithImpl(this._value, this._then);

  final PatrolTestConfig _value;
  // ignore: unused_field
  final $Res Function(PatrolTestConfig) _then;

  @override
  $Res call({
    Object? existsTimeout = freezed,
    Object? visibleTimeout = freezed,
    Object? settleTimeout = freezed,
    Object? andSettle = freezed,
    Object? appName = freezed,
    Object? packageName = freezed,
    Object? bundleId = freezed,
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
      andSettle: andSettle == freezed
          ? _value.andSettle
          : andSettle // ignore: cast_nullable_to_non_nullable
              as bool,
      appName: appName == freezed
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      packageName: packageName == freezed
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String?,
      bundleId: bundleId == freezed
          ? _value.bundleId
          : bundleId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_PatrolTestConfigCopyWith<$Res>
    implements $PatrolTestConfigCopyWith<$Res> {
  factory _$$_PatrolTestConfigCopyWith(
          _$_PatrolTestConfig value, $Res Function(_$_PatrolTestConfig) then) =
      __$$_PatrolTestConfigCopyWithImpl<$Res>;
  @override
  $Res call(
      {Duration existsTimeout,
      Duration visibleTimeout,
      Duration settleTimeout,
      bool andSettle,
      String? appName,
      String? packageName,
      String? bundleId});
}

/// @nodoc
class __$$_PatrolTestConfigCopyWithImpl<$Res>
    extends _$PatrolTestConfigCopyWithImpl<$Res>
    implements _$$_PatrolTestConfigCopyWith<$Res> {
  __$$_PatrolTestConfigCopyWithImpl(
      _$_PatrolTestConfig _value, $Res Function(_$_PatrolTestConfig) _then)
      : super(_value, (v) => _then(v as _$_PatrolTestConfig));

  @override
  _$_PatrolTestConfig get _value => super._value as _$_PatrolTestConfig;

  @override
  $Res call({
    Object? existsTimeout = freezed,
    Object? visibleTimeout = freezed,
    Object? settleTimeout = freezed,
    Object? andSettle = freezed,
    Object? appName = freezed,
    Object? packageName = freezed,
    Object? bundleId = freezed,
  }) {
    return _then(_$_PatrolTestConfig(
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
      andSettle: andSettle == freezed
          ? _value.andSettle
          : andSettle // ignore: cast_nullable_to_non_nullable
              as bool,
      appName: appName == freezed
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      packageName: packageName == freezed
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String?,
      bundleId: bundleId == freezed
          ? _value.bundleId
          : bundleId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_PatrolTestConfig implements _PatrolTestConfig {
  const _$_PatrolTestConfig(
      {this.existsTimeout = const Duration(seconds: 10),
      this.visibleTimeout = const Duration(seconds: 10),
      this.settleTimeout = const Duration(seconds: 10),
      this.andSettle = true,
      this.appName,
      this.packageName,
      this.bundleId});

  /// Time after which [PatrolFinder.waitUntilExists] fails if it doesn't
  /// finds a widget.
  @override
  @JsonKey()
  final Duration existsTimeout;

  /// Time after which [PatrolFinder.waitUntilVisible] fails if it doesn't
  /// finds a widget.
  ///
  /// [PatrolFinder.waitUntilVisible] is used internally by [PatrolFinder.tap]
  /// and [PatrolFinder.enterText].
  @override
  @JsonKey()
  final Duration visibleTimeout;

  /// Time after which [PatrolTester.pumpAndSettle] fails.
  @override
  @JsonKey()
  final Duration settleTimeout;

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [PatrolFinder.tap] and [PatrolFinder]. If false, only
  /// [WidgetTester.pump] is called.
  @override
  @JsonKey()
  final bool andSettle;

  /// Name of the application under test.
  ///
  /// Used in [PatrolTester.log].
  @override
  final String? appName;

  /// Package name of the application under test.
  ///
  /// Android only.
  @override
  final String? packageName;

  /// Bundle identifier name of the application under test.
  ///
  /// iOS only.
  @override
  final String? bundleId;

  @override
  String toString() {
    return 'PatrolTestConfig(existsTimeout: $existsTimeout, visibleTimeout: $visibleTimeout, settleTimeout: $settleTimeout, andSettle: $andSettle, appName: $appName, packageName: $packageName, bundleId: $bundleId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PatrolTestConfig &&
            const DeepCollectionEquality()
                .equals(other.existsTimeout, existsTimeout) &&
            const DeepCollectionEquality()
                .equals(other.visibleTimeout, visibleTimeout) &&
            const DeepCollectionEquality()
                .equals(other.settleTimeout, settleTimeout) &&
            const DeepCollectionEquality().equals(other.andSettle, andSettle) &&
            const DeepCollectionEquality().equals(other.appName, appName) &&
            const DeepCollectionEquality()
                .equals(other.packageName, packageName) &&
            const DeepCollectionEquality().equals(other.bundleId, bundleId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(existsTimeout),
      const DeepCollectionEquality().hash(visibleTimeout),
      const DeepCollectionEquality().hash(settleTimeout),
      const DeepCollectionEquality().hash(andSettle),
      const DeepCollectionEquality().hash(appName),
      const DeepCollectionEquality().hash(packageName),
      const DeepCollectionEquality().hash(bundleId));

  @JsonKey(ignore: true)
  @override
  _$$_PatrolTestConfigCopyWith<_$_PatrolTestConfig> get copyWith =>
      __$$_PatrolTestConfigCopyWithImpl<_$_PatrolTestConfig>(this, _$identity);
}

abstract class _PatrolTestConfig implements PatrolTestConfig {
  const factory _PatrolTestConfig(
      {final Duration existsTimeout,
      final Duration visibleTimeout,
      final Duration settleTimeout,
      final bool andSettle,
      final String? appName,
      final String? packageName,
      final String? bundleId}) = _$_PatrolTestConfig;

  @override

  /// Time after which [PatrolFinder.waitUntilExists] fails if it doesn't
  /// finds a widget.
  Duration get existsTimeout;
  @override

  /// Time after which [PatrolFinder.waitUntilVisible] fails if it doesn't
  /// finds a widget.
  ///
  /// [PatrolFinder.waitUntilVisible] is used internally by [PatrolFinder.tap]
  /// and [PatrolFinder.enterText].
  Duration get visibleTimeout;
  @override

  /// Time after which [PatrolTester.pumpAndSettle] fails.
  Duration get settleTimeout;
  @override

  /// Whether to call [WidgetTester.pumpAndSettle] after actions such as
  /// [PatrolFinder.tap] and [PatrolFinder]. If false, only
  /// [WidgetTester.pump] is called.
  bool get andSettle;
  @override

  /// Name of the application under test.
  ///
  /// Used in [PatrolTester.log].
  String? get appName;
  @override

  /// Package name of the application under test.
  ///
  /// Android only.
  String? get packageName;
  @override

  /// Bundle identifier name of the application under test.
  ///
  /// iOS only.
  String? get bundleId;
  @override
  @JsonKey(ignore: true)
  _$$_PatrolTestConfigCopyWith<_$_PatrolTestConfig> get copyWith =>
      throw _privateConstructorUsedError;
}
