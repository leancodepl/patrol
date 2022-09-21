///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'contracts.pbenum.dart';

export 'contracts.pbenum.dart';

class OpenAppCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'OpenAppCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..hasRequiredFields = false
  ;

  OpenAppCommand._() : super();
  factory OpenAppCommand({
    $core.String? appId,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    return _result;
  }
  factory OpenAppCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpenAppCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OpenAppCommand clone() => OpenAppCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OpenAppCommand copyWith(void Function(OpenAppCommand) updates) => super.copyWith((message) => updates(message as OpenAppCommand)) as OpenAppCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static OpenAppCommand create() => OpenAppCommand._();
  OpenAppCommand createEmptyInstance() => create();
  static $pb.PbList<OpenAppCommand> createRepeated() => $pb.PbList<OpenAppCommand>();
  @$core.pragma('dart2js:noInline')
  static OpenAppCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OpenAppCommand>(create);
  static OpenAppCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);
}

class TapCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TapCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..aOM<Selector>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..hasRequiredFields = false
  ;

  TapCommand._() : super();
  factory TapCommand({
    $core.String? appId,
    Selector? selector,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    if (selector != null) {
      _result.selector = selector;
    }
    return _result;
  }
  factory TapCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TapCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TapCommand clone() => TapCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TapCommand copyWith(void Function(TapCommand) updates) => super.copyWith((message) => updates(message as TapCommand)) as TapCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TapCommand create() => TapCommand._();
  TapCommand createEmptyInstance() => create();
  static $pb.PbList<TapCommand> createRepeated() => $pb.PbList<TapCommand>();
  @$core.pragma('dart2js:noInline')
  static TapCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TapCommand>(create);
  static TapCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);

  @$pb.TagNumber(2)
  Selector get selector => $_getN(1);
  @$pb.TagNumber(2)
  set selector(Selector v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSelector() => $_has(1);
  @$pb.TagNumber(2)
  void clearSelector() => clearField(2);
  @$pb.TagNumber(2)
  Selector ensureSelector() => $_ensure(1);
}

class DoubleTapCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DoubleTapCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..aOM<Selector>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..hasRequiredFields = false
  ;

  DoubleTapCommand._() : super();
  factory DoubleTapCommand({
    $core.String? appId,
    Selector? selector,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    if (selector != null) {
      _result.selector = selector;
    }
    return _result;
  }
  factory DoubleTapCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DoubleTapCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DoubleTapCommand clone() => DoubleTapCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DoubleTapCommand copyWith(void Function(DoubleTapCommand) updates) => super.copyWith((message) => updates(message as DoubleTapCommand)) as DoubleTapCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DoubleTapCommand create() => DoubleTapCommand._();
  DoubleTapCommand createEmptyInstance() => create();
  static $pb.PbList<DoubleTapCommand> createRepeated() => $pb.PbList<DoubleTapCommand>();
  @$core.pragma('dart2js:noInline')
  static DoubleTapCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DoubleTapCommand>(create);
  static DoubleTapCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);

  @$pb.TagNumber(2)
  Selector get selector => $_getN(1);
  @$pb.TagNumber(2)
  set selector(Selector v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSelector() => $_has(1);
  @$pb.TagNumber(2)
  void clearSelector() => clearField(2);
  @$pb.TagNumber(2)
  Selector ensureSelector() => $_ensure(1);
}

class EnterTextBySelectorCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EnterTextBySelectorCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..aOM<Selector>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..hasRequiredFields = false
  ;

  EnterTextBySelectorCommand._() : super();
  factory EnterTextBySelectorCommand({
    $core.String? appId,
    $core.String? data,
    Selector? selector,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    if (data != null) {
      _result.data = data;
    }
    if (selector != null) {
      _result.selector = selector;
    }
    return _result;
  }
  factory EnterTextBySelectorCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EnterTextBySelectorCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EnterTextBySelectorCommand clone() => EnterTextBySelectorCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EnterTextBySelectorCommand copyWith(void Function(EnterTextBySelectorCommand) updates) => super.copyWith((message) => updates(message as EnterTextBySelectorCommand)) as EnterTextBySelectorCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EnterTextBySelectorCommand create() => EnterTextBySelectorCommand._();
  EnterTextBySelectorCommand createEmptyInstance() => create();
  static $pb.PbList<EnterTextBySelectorCommand> createRepeated() => $pb.PbList<EnterTextBySelectorCommand>();
  @$core.pragma('dart2js:noInline')
  static EnterTextBySelectorCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnterTextBySelectorCommand>(create);
  static EnterTextBySelectorCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get data => $_getSZ(1);
  @$pb.TagNumber(2)
  set data($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);

  @$pb.TagNumber(3)
  Selector get selector => $_getN(2);
  @$pb.TagNumber(3)
  set selector(Selector v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSelector() => $_has(2);
  @$pb.TagNumber(3)
  void clearSelector() => clearField(3);
  @$pb.TagNumber(3)
  Selector ensureSelector() => $_ensure(2);
}

class EnterTextByIndexCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EnterTextByIndexCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'index', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  EnterTextByIndexCommand._() : super();
  factory EnterTextByIndexCommand({
    $core.String? appId,
    $core.String? data,
    $core.int? index,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    if (data != null) {
      _result.data = data;
    }
    if (index != null) {
      _result.index = index;
    }
    return _result;
  }
  factory EnterTextByIndexCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EnterTextByIndexCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EnterTextByIndexCommand clone() => EnterTextByIndexCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EnterTextByIndexCommand copyWith(void Function(EnterTextByIndexCommand) updates) => super.copyWith((message) => updates(message as EnterTextByIndexCommand)) as EnterTextByIndexCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EnterTextByIndexCommand create() => EnterTextByIndexCommand._();
  EnterTextByIndexCommand createEmptyInstance() => create();
  static $pb.PbList<EnterTextByIndexCommand> createRepeated() => $pb.PbList<EnterTextByIndexCommand>();
  @$core.pragma('dart2js:noInline')
  static EnterTextByIndexCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnterTextByIndexCommand>(create);
  static EnterTextByIndexCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get data => $_getSZ(1);
  @$pb.TagNumber(2)
  set data($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get index => $_getIZ(2);
  @$pb.TagNumber(3)
  set index($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearIndex() => clearField(3);
}

class TapOnNotificationByIndexCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TapOnNotificationByIndexCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'index', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  TapOnNotificationByIndexCommand._() : super();
  factory TapOnNotificationByIndexCommand({
    $core.int? index,
  }) {
    final _result = create();
    if (index != null) {
      _result.index = index;
    }
    return _result;
  }
  factory TapOnNotificationByIndexCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TapOnNotificationByIndexCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TapOnNotificationByIndexCommand clone() => TapOnNotificationByIndexCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TapOnNotificationByIndexCommand copyWith(void Function(TapOnNotificationByIndexCommand) updates) => super.copyWith((message) => updates(message as TapOnNotificationByIndexCommand)) as TapOnNotificationByIndexCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TapOnNotificationByIndexCommand create() => TapOnNotificationByIndexCommand._();
  TapOnNotificationByIndexCommand createEmptyInstance() => create();
  static $pb.PbList<TapOnNotificationByIndexCommand> createRepeated() => $pb.PbList<TapOnNotificationByIndexCommand>();
  @$core.pragma('dart2js:noInline')
  static TapOnNotificationByIndexCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TapOnNotificationByIndexCommand>(create);
  static TapOnNotificationByIndexCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);
}

class TapOnNotificationBySelectorCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TapOnNotificationBySelectorCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOM<Selector>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..hasRequiredFields = false
  ;

  TapOnNotificationBySelectorCommand._() : super();
  factory TapOnNotificationBySelectorCommand({
    Selector? selector,
  }) {
    final _result = create();
    if (selector != null) {
      _result.selector = selector;
    }
    return _result;
  }
  factory TapOnNotificationBySelectorCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TapOnNotificationBySelectorCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TapOnNotificationBySelectorCommand clone() => TapOnNotificationBySelectorCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TapOnNotificationBySelectorCommand copyWith(void Function(TapOnNotificationBySelectorCommand) updates) => super.copyWith((message) => updates(message as TapOnNotificationBySelectorCommand)) as TapOnNotificationBySelectorCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TapOnNotificationBySelectorCommand create() => TapOnNotificationBySelectorCommand._();
  TapOnNotificationBySelectorCommand createEmptyInstance() => create();
  static $pb.PbList<TapOnNotificationBySelectorCommand> createRepeated() => $pb.PbList<TapOnNotificationBySelectorCommand>();
  @$core.pragma('dart2js:noInline')
  static TapOnNotificationBySelectorCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TapOnNotificationBySelectorCommand>(create);
  static TapOnNotificationBySelectorCommand? _defaultInstance;

  @$pb.TagNumber(1)
  Selector get selector => $_getN(0);
  @$pb.TagNumber(1)
  set selector(Selector v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSelector() => $_has(0);
  @$pb.TagNumber(1)
  void clearSelector() => clearField(1);
  @$pb.TagNumber(1)
  Selector ensureSelector() => $_ensure(0);
}

class SwipeCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SwipeCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..a<$core.double>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'startX', $pb.PbFieldType.OF, protoName: 'startX')
    ..a<$core.double>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'startY', $pb.PbFieldType.OF, protoName: 'startY')
    ..a<$core.double>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'endX', $pb.PbFieldType.OF, protoName: 'endX')
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'endY', $pb.PbFieldType.OF, protoName: 'endY')
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'steps', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  SwipeCommand._() : super();
  factory SwipeCommand({
    $core.double? startX,
    $core.double? startY,
    $core.double? endX,
    $core.double? endY,
    $core.int? steps,
  }) {
    final _result = create();
    if (startX != null) {
      _result.startX = startX;
    }
    if (startY != null) {
      _result.startY = startY;
    }
    if (endX != null) {
      _result.endX = endX;
    }
    if (endY != null) {
      _result.endY = endY;
    }
    if (steps != null) {
      _result.steps = steps;
    }
    return _result;
  }
  factory SwipeCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SwipeCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SwipeCommand clone() => SwipeCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SwipeCommand copyWith(void Function(SwipeCommand) updates) => super.copyWith((message) => updates(message as SwipeCommand)) as SwipeCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SwipeCommand create() => SwipeCommand._();
  SwipeCommand createEmptyInstance() => create();
  static $pb.PbList<SwipeCommand> createRepeated() => $pb.PbList<SwipeCommand>();
  @$core.pragma('dart2js:noInline')
  static SwipeCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwipeCommand>(create);
  static SwipeCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get startX => $_getN(0);
  @$pb.TagNumber(1)
  set startX($core.double v) { $_setFloat(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartX() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartX() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get startY => $_getN(1);
  @$pb.TagNumber(2)
  set startY($core.double v) { $_setFloat(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartY() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartY() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get endX => $_getN(2);
  @$pb.TagNumber(3)
  set endX($core.double v) { $_setFloat(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEndX() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndX() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get endY => $_getN(3);
  @$pb.TagNumber(4)
  set endY($core.double v) { $_setFloat(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEndY() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndY() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get steps => $_getIZ(4);
  @$pb.TagNumber(5)
  set steps($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSteps() => $_has(4);
  @$pb.TagNumber(5)
  void clearSteps() => clearField(5);
}

class HandlePermissionCommand extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'HandlePermissionCommand', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..e<HandlePermissionCommand_Code>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'code', $pb.PbFieldType.OE, defaultOrMaker: HandlePermissionCommand_Code.WHILE_USING, valueOf: HandlePermissionCommand_Code.valueOf, enumValues: HandlePermissionCommand_Code.values)
    ..hasRequiredFields = false
  ;

  HandlePermissionCommand._() : super();
  factory HandlePermissionCommand({
    HandlePermissionCommand_Code? code,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    return _result;
  }
  factory HandlePermissionCommand.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HandlePermissionCommand.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HandlePermissionCommand clone() => HandlePermissionCommand()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HandlePermissionCommand copyWith(void Function(HandlePermissionCommand) updates) => super.copyWith((message) => updates(message as HandlePermissionCommand)) as HandlePermissionCommand; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static HandlePermissionCommand create() => HandlePermissionCommand._();
  HandlePermissionCommand createEmptyInstance() => create();
  static $pb.PbList<HandlePermissionCommand> createRepeated() => $pb.PbList<HandlePermissionCommand>();
  @$core.pragma('dart2js:noInline')
  static HandlePermissionCommand getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HandlePermissionCommand>(create);
  static HandlePermissionCommand? _defaultInstance;

  @$pb.TagNumber(1)
  HandlePermissionCommand_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(HandlePermissionCommand_Code v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);
}

class Selector extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Selector', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'text')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'textStartsWith', protoName: 'textStartsWith')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'textContains', protoName: 'textContains')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'className', protoName: 'className')
    ..aOS(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contentDescription', protoName: 'contentDescription')
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contentDescriptionStartsWith', protoName: 'contentDescriptionStartsWith')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contentDescriptionContains', protoName: 'contentDescriptionContains')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'resourceId', protoName: 'resourceId')
    ..a<$core.int>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'instance', $pb.PbFieldType.O3)
    ..aOB(10, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enabled')
    ..aOB(11, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'focused')
    ..aOS(12, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'pkg')
    ..hasRequiredFields = false
  ;

  Selector._() : super();
  factory Selector({
    $core.String? text,
    $core.String? textStartsWith,
    $core.String? textContains,
    $core.String? className,
    $core.String? contentDescription,
    $core.String? contentDescriptionStartsWith,
    $core.String? contentDescriptionContains,
    $core.String? resourceId,
    $core.int? instance,
    $core.bool? enabled,
    $core.bool? focused,
    $core.String? pkg,
  }) {
    final _result = create();
    if (text != null) {
      _result.text = text;
    }
    if (textStartsWith != null) {
      _result.textStartsWith = textStartsWith;
    }
    if (textContains != null) {
      _result.textContains = textContains;
    }
    if (className != null) {
      _result.className = className;
    }
    if (contentDescription != null) {
      _result.contentDescription = contentDescription;
    }
    if (contentDescriptionStartsWith != null) {
      _result.contentDescriptionStartsWith = contentDescriptionStartsWith;
    }
    if (contentDescriptionContains != null) {
      _result.contentDescriptionContains = contentDescriptionContains;
    }
    if (resourceId != null) {
      _result.resourceId = resourceId;
    }
    if (instance != null) {
      _result.instance = instance;
    }
    if (enabled != null) {
      _result.enabled = enabled;
    }
    if (focused != null) {
      _result.focused = focused;
    }
    if (pkg != null) {
      _result.pkg = pkg;
    }
    return _result;
  }
  factory Selector.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Selector.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Selector clone() => Selector()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Selector copyWith(void Function(Selector) updates) => super.copyWith((message) => updates(message as Selector)) as Selector; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Selector create() => Selector._();
  Selector createEmptyInstance() => create();
  static $pb.PbList<Selector> createRepeated() => $pb.PbList<Selector>();
  @$core.pragma('dart2js:noInline')
  static Selector getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Selector>(create);
  static Selector? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get textStartsWith => $_getSZ(1);
  @$pb.TagNumber(2)
  set textStartsWith($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTextStartsWith() => $_has(1);
  @$pb.TagNumber(2)
  void clearTextStartsWith() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get textContains => $_getSZ(2);
  @$pb.TagNumber(3)
  set textContains($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTextContains() => $_has(2);
  @$pb.TagNumber(3)
  void clearTextContains() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get className => $_getSZ(3);
  @$pb.TagNumber(4)
  set className($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasClassName() => $_has(3);
  @$pb.TagNumber(4)
  void clearClassName() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get contentDescription => $_getSZ(4);
  @$pb.TagNumber(5)
  set contentDescription($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasContentDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearContentDescription() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get contentDescriptionStartsWith => $_getSZ(5);
  @$pb.TagNumber(6)
  set contentDescriptionStartsWith($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasContentDescriptionStartsWith() => $_has(5);
  @$pb.TagNumber(6)
  void clearContentDescriptionStartsWith() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get contentDescriptionContains => $_getSZ(6);
  @$pb.TagNumber(7)
  set contentDescriptionContains($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasContentDescriptionContains() => $_has(6);
  @$pb.TagNumber(7)
  void clearContentDescriptionContains() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get resourceId => $_getSZ(7);
  @$pb.TagNumber(8)
  set resourceId($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasResourceId() => $_has(7);
  @$pb.TagNumber(8)
  void clearResourceId() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get instance => $_getIZ(8);
  @$pb.TagNumber(9)
  set instance($core.int v) { $_setSignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasInstance() => $_has(8);
  @$pb.TagNumber(9)
  void clearInstance() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get enabled => $_getBF(9);
  @$pb.TagNumber(10)
  set enabled($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasEnabled() => $_has(9);
  @$pb.TagNumber(10)
  void clearEnabled() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get focused => $_getBF(10);
  @$pb.TagNumber(11)
  set focused($core.bool v) { $_setBool(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasFocused() => $_has(10);
  @$pb.TagNumber(11)
  void clearFocused() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get pkg => $_getSZ(11);
  @$pb.TagNumber(12)
  set pkg($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasPkg() => $_has(11);
  @$pb.TagNumber(12)
  void clearPkg() => clearField(12);
}

