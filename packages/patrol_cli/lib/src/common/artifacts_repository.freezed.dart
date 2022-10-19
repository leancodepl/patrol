// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'artifacts_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Artifact {
  String get name => throw _privateConstructorUsedError;
  String? get version => throw _privateConstructorUsedError;
  String? get ext => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String? version, String? ext) file,
    required TResult Function(String name, String? version, String? ext)
        archive,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name, String? version, String? ext)? file,
    TResult Function(String name, String? version, String? ext)? archive,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String? version, String? ext)? file,
    TResult Function(String name, String? version, String? ext)? archive,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ArtifactFile value) file,
    required TResult Function(_ArtifactArchive value) archive,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_ArtifactFile value)? file,
    TResult Function(_ArtifactArchive value)? archive,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ArtifactFile value)? file,
    TResult Function(_ArtifactArchive value)? archive,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ArtifactCopyWith<Artifact> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArtifactCopyWith<$Res> {
  factory $ArtifactCopyWith(Artifact value, $Res Function(Artifact) then) =
      _$ArtifactCopyWithImpl<$Res>;
  $Res call({String name, String? version, String? ext});
}

/// @nodoc
class _$ArtifactCopyWithImpl<$Res> implements $ArtifactCopyWith<$Res> {
  _$ArtifactCopyWithImpl(this._value, this._then);

  final Artifact _value;
  // ignore: unused_field
  final $Res Function(Artifact) _then;

  @override
  $Res call({
    Object? name = freezed,
    Object? version = freezed,
    Object? ext = freezed,
  }) {
    return _then(_value.copyWith(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      ext: ext == freezed
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_ArtifactFileCopyWith<$Res>
    implements $ArtifactCopyWith<$Res> {
  factory _$$_ArtifactFileCopyWith(
          _$_ArtifactFile value, $Res Function(_$_ArtifactFile) then) =
      __$$_ArtifactFileCopyWithImpl<$Res>;
  @override
  $Res call({String name, String? version, String? ext});
}

/// @nodoc
class __$$_ArtifactFileCopyWithImpl<$Res> extends _$ArtifactCopyWithImpl<$Res>
    implements _$$_ArtifactFileCopyWith<$Res> {
  __$$_ArtifactFileCopyWithImpl(
      _$_ArtifactFile _value, $Res Function(_$_ArtifactFile) _then)
      : super(_value, (v) => _then(v as _$_ArtifactFile));

  @override
  _$_ArtifactFile get _value => super._value as _$_ArtifactFile;

  @override
  $Res call({
    Object? name = freezed,
    Object? version = freezed,
    Object? ext = freezed,
  }) {
    return _then(_$_ArtifactFile(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      ext: ext == freezed
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_ArtifactFile extends _ArtifactFile {
  const _$_ArtifactFile({required this.name, this.version, this.ext})
      : super._();

  @override
  final String name;
  @override
  final String? version;
  @override
  final String? ext;

  @override
  String toString() {
    return 'Artifact.file(name: $name, version: $version, ext: $ext)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ArtifactFile &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.version, version) &&
            const DeepCollectionEquality().equals(other.ext, ext));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(version),
      const DeepCollectionEquality().hash(ext));

  @JsonKey(ignore: true)
  @override
  _$$_ArtifactFileCopyWith<_$_ArtifactFile> get copyWith =>
      __$$_ArtifactFileCopyWithImpl<_$_ArtifactFile>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String? version, String? ext) file,
    required TResult Function(String name, String? version, String? ext)
        archive,
  }) {
    return file(name, version, ext);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name, String? version, String? ext)? file,
    TResult Function(String name, String? version, String? ext)? archive,
  }) {
    return file?.call(name, version, ext);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String? version, String? ext)? file,
    TResult Function(String name, String? version, String? ext)? archive,
    required TResult orElse(),
  }) {
    if (file != null) {
      return file(name, version, ext);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ArtifactFile value) file,
    required TResult Function(_ArtifactArchive value) archive,
  }) {
    return file(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_ArtifactFile value)? file,
    TResult Function(_ArtifactArchive value)? archive,
  }) {
    return file?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ArtifactFile value)? file,
    TResult Function(_ArtifactArchive value)? archive,
    required TResult orElse(),
  }) {
    if (file != null) {
      return file(this);
    }
    return orElse();
  }
}

abstract class _ArtifactFile extends Artifact {
  const factory _ArtifactFile(
      {required final String name,
      final String? version,
      final String? ext}) = _$_ArtifactFile;
  const _ArtifactFile._() : super._();

  @override
  String get name;
  @override
  String? get version;
  @override
  String? get ext;
  @override
  @JsonKey(ignore: true)
  _$$_ArtifactFileCopyWith<_$_ArtifactFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_ArtifactArchiveCopyWith<$Res>
    implements $ArtifactCopyWith<$Res> {
  factory _$$_ArtifactArchiveCopyWith(
          _$_ArtifactArchive value, $Res Function(_$_ArtifactArchive) then) =
      __$$_ArtifactArchiveCopyWithImpl<$Res>;
  @override
  $Res call({String name, String? version, String? ext});
}

/// @nodoc
class __$$_ArtifactArchiveCopyWithImpl<$Res>
    extends _$ArtifactCopyWithImpl<$Res>
    implements _$$_ArtifactArchiveCopyWith<$Res> {
  __$$_ArtifactArchiveCopyWithImpl(
      _$_ArtifactArchive _value, $Res Function(_$_ArtifactArchive) _then)
      : super(_value, (v) => _then(v as _$_ArtifactArchive));

  @override
  _$_ArtifactArchive get _value => super._value as _$_ArtifactArchive;

  @override
  $Res call({
    Object? name = freezed,
    Object? version = freezed,
    Object? ext = freezed,
  }) {
    return _then(_$_ArtifactArchive(
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String?,
      ext: ext == freezed
          ? _value.ext
          : ext // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_ArtifactArchive extends _ArtifactArchive {
  const _$_ArtifactArchive({required this.name, this.version, this.ext})
      : super._();

  @override
  final String name;
  @override
  final String? version;
  @override
  final String? ext;

  @override
  String toString() {
    return 'Artifact.archive(name: $name, version: $version, ext: $ext)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ArtifactArchive &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.version, version) &&
            const DeepCollectionEquality().equals(other.ext, ext));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(version),
      const DeepCollectionEquality().hash(ext));

  @JsonKey(ignore: true)
  @override
  _$$_ArtifactArchiveCopyWith<_$_ArtifactArchive> get copyWith =>
      __$$_ArtifactArchiveCopyWithImpl<_$_ArtifactArchive>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String name, String? version, String? ext) file,
    required TResult Function(String name, String? version, String? ext)
        archive,
  }) {
    return archive(name, version, ext);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String name, String? version, String? ext)? file,
    TResult Function(String name, String? version, String? ext)? archive,
  }) {
    return archive?.call(name, version, ext);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String name, String? version, String? ext)? file,
    TResult Function(String name, String? version, String? ext)? archive,
    required TResult orElse(),
  }) {
    if (archive != null) {
      return archive(name, version, ext);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_ArtifactFile value) file,
    required TResult Function(_ArtifactArchive value) archive,
  }) {
    return archive(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_ArtifactFile value)? file,
    TResult Function(_ArtifactArchive value)? archive,
  }) {
    return archive?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_ArtifactFile value)? file,
    TResult Function(_ArtifactArchive value)? archive,
    required TResult orElse(),
  }) {
    if (archive != null) {
      return archive(this);
    }
    return orElse();
  }
}

abstract class _ArtifactArchive extends Artifact {
  const factory _ArtifactArchive(
      {required final String name,
      final String? version,
      final String? ext}) = _$_ArtifactArchive;
  const _ArtifactArchive._() : super._();

  @override
  String get name;
  @override
  String? get version;
  @override
  String? get ext;
  @override
  @JsonKey(ignore: true)
  _$$_ArtifactArchiveCopyWith<_$_ArtifactArchive> get copyWith =>
      throw _privateConstructorUsedError;
}
