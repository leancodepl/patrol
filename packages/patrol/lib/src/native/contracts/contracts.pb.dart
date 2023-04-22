///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'contracts.pbenum.dart';

export 'contracts.pbenum.dart';

class ListDartTestsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ListDartTestsResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOM<DartTestGroup>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'group', subBuilder: DartTestGroup.create)
    ..hasRequiredFields = false
  ;

  ListDartTestsResponse._() : super();
  factory ListDartTestsResponse({
    DartTestGroup? group,
  }) {
    final _result = create();
    if (group != null) {
      _result.group = group;
    }
    return _result;
  }
  factory ListDartTestsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDartTestsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDartTestsResponse clone() => ListDartTestsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDartTestsResponse copyWith(void Function(ListDartTestsResponse) updates) => super.copyWith((message) => updates(message as ListDartTestsResponse)) as ListDartTestsResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListDartTestsResponse create() => ListDartTestsResponse._();
  ListDartTestsResponse createEmptyInstance() => create();
  static $pb.PbList<ListDartTestsResponse> createRepeated() => $pb.PbList<ListDartTestsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDartTestsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDartTestsResponse>(create);
  static ListDartTestsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DartTestGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(DartTestGroup v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  DartTestGroup ensureGroup() => $_ensure(0);
}

class DartTestGroup extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DartTestGroup', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..pc<DartTestCase>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'tests', $pb.PbFieldType.PM, subBuilder: DartTestCase.create)
    ..pc<DartTestGroup>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'groups', $pb.PbFieldType.PM, subBuilder: DartTestGroup.create)
    ..hasRequiredFields = false
  ;

  DartTestGroup._() : super();
  factory DartTestGroup({
    $core.String? name,
    $core.Iterable<DartTestCase>? tests,
    $core.Iterable<DartTestGroup>? groups,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (tests != null) {
      _result.tests.addAll(tests);
    }
    if (groups != null) {
      _result.groups.addAll(groups);
    }
    return _result;
  }
  factory DartTestGroup.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DartTestGroup.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DartTestGroup clone() => DartTestGroup()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DartTestGroup copyWith(void Function(DartTestGroup) updates) => super.copyWith((message) => updates(message as DartTestGroup)) as DartTestGroup; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DartTestGroup create() => DartTestGroup._();
  DartTestGroup createEmptyInstance() => create();
  static $pb.PbList<DartTestGroup> createRepeated() => $pb.PbList<DartTestGroup>();
  @$core.pragma('dart2js:noInline')
  static DartTestGroup getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DartTestGroup>(create);
  static DartTestGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<DartTestCase> get tests => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<DartTestGroup> get groups => $_getList(2);
}

class DartTestCase extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DartTestCase', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..hasRequiredFields = false
  ;

  DartTestCase._() : super();
  factory DartTestCase({
    $core.String? name,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory DartTestCase.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DartTestCase.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DartTestCase clone() => DartTestCase()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DartTestCase copyWith(void Function(DartTestCase) updates) => super.copyWith((message) => updates(message as DartTestCase)) as DartTestCase; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DartTestCase create() => DartTestCase._();
  DartTestCase createEmptyInstance() => create();
  static $pb.PbList<DartTestCase> createRepeated() => $pb.PbList<DartTestCase>();
  @$core.pragma('dart2js:noInline')
  static DartTestCase getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DartTestCase>(create);
  static DartTestCase? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class RunDartTestRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'RunDartTestRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'name')
    ..hasRequiredFields = false
  ;

  RunDartTestRequest._() : super();
  factory RunDartTestRequest({
    $core.String? name,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    return _result;
  }
  factory RunDartTestRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RunDartTestRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RunDartTestRequest clone() => RunDartTestRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RunDartTestRequest copyWith(void Function(RunDartTestRequest) updates) => super.copyWith((message) => updates(message as RunDartTestRequest)) as RunDartTestRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static RunDartTestRequest create() => RunDartTestRequest._();
  RunDartTestRequest createEmptyInstance() => create();
  static $pb.PbList<RunDartTestRequest> createRepeated() => $pb.PbList<RunDartTestRequest>();
  @$core.pragma('dart2js:noInline')
  static RunDartTestRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RunDartTestRequest>(create);
  static RunDartTestRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);
}

class RunDartTestResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'RunDartTestResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..e<RunDartTestResponse_Result>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'result', $pb.PbFieldType.OE, defaultOrMaker: RunDartTestResponse_Result.SUCCESS, valueOf: RunDartTestResponse_Result.valueOf, enumValues: RunDartTestResponse_Result.values)
    ..hasRequiredFields = false
  ;

  RunDartTestResponse._() : super();
  factory RunDartTestResponse({
    RunDartTestResponse_Result? result,
  }) {
    final _result = create();
    if (result != null) {
      _result.result = result;
    }
    return _result;
  }
  factory RunDartTestResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RunDartTestResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RunDartTestResponse clone() => RunDartTestResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RunDartTestResponse copyWith(void Function(RunDartTestResponse) updates) => super.copyWith((message) => updates(message as RunDartTestResponse)) as RunDartTestResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static RunDartTestResponse create() => RunDartTestResponse._();
  RunDartTestResponse createEmptyInstance() => create();
  static $pb.PbList<RunDartTestResponse> createRepeated() => $pb.PbList<RunDartTestResponse>();
  @$core.pragma('dart2js:noInline')
  static RunDartTestResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RunDartTestResponse>(create);
  static RunDartTestResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RunDartTestResponse_Result get result => $_getN(0);
  @$pb.TagNumber(1)
  set result(RunDartTestResponse_Result v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearResult() => clearField(1);
}

class ConfigureRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'ConfigureRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'findTimeoutMillis', $pb.PbFieldType.OU6, protoName: 'findTimeoutMillis', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  ConfigureRequest._() : super();
  factory ConfigureRequest({
    $fixnum.Int64? findTimeoutMillis,
  }) {
    final _result = create();
    if (findTimeoutMillis != null) {
      _result.findTimeoutMillis = findTimeoutMillis;
    }
    return _result;
  }
  factory ConfigureRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConfigureRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConfigureRequest clone() => ConfigureRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConfigureRequest copyWith(void Function(ConfigureRequest) updates) => super.copyWith((message) => updates(message as ConfigureRequest)) as ConfigureRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ConfigureRequest create() => ConfigureRequest._();
  ConfigureRequest createEmptyInstance() => create();
  static $pb.PbList<ConfigureRequest> createRepeated() => $pb.PbList<ConfigureRequest>();
  @$core.pragma('dart2js:noInline')
  static ConfigureRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfigureRequest>(create);
  static ConfigureRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get findTimeoutMillis => $_getI64(0);
  @$pb.TagNumber(1)
  set findTimeoutMillis($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFindTimeoutMillis() => $_has(0);
  @$pb.TagNumber(1)
  void clearFindTimeoutMillis() => clearField(1);
}

class OpenAppRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'OpenAppRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..hasRequiredFields = false
  ;

  OpenAppRequest._() : super();
  factory OpenAppRequest({
    $core.String? appId,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    return _result;
  }
  factory OpenAppRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpenAppRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OpenAppRequest clone() => OpenAppRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OpenAppRequest copyWith(void Function(OpenAppRequest) updates) => super.copyWith((message) => updates(message as OpenAppRequest)) as OpenAppRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static OpenAppRequest create() => OpenAppRequest._();
  OpenAppRequest createEmptyInstance() => create();
  static $pb.PbList<OpenAppRequest> createRepeated() => $pb.PbList<OpenAppRequest>();
  @$core.pragma('dart2js:noInline')
  static OpenAppRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OpenAppRequest>(create);
  static OpenAppRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);
}

enum TapOnNotificationRequest_FindBy {
  index_, 
  selector, 
  notSet
}

class TapOnNotificationRequest extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, TapOnNotificationRequest_FindBy> _TapOnNotificationRequest_FindByByTag = {
    1 : TapOnNotificationRequest_FindBy.index_,
    2 : TapOnNotificationRequest_FindBy.selector,
    0 : TapOnNotificationRequest_FindBy.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TapOnNotificationRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..a<$core.int>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'index', $pb.PbFieldType.OU3)
    ..aOM<Selector>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..hasRequiredFields = false
  ;

  TapOnNotificationRequest._() : super();
  factory TapOnNotificationRequest({
    $core.int? index,
    Selector? selector,
  }) {
    final _result = create();
    if (index != null) {
      _result.index = index;
    }
    if (selector != null) {
      _result.selector = selector;
    }
    return _result;
  }
  factory TapOnNotificationRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TapOnNotificationRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TapOnNotificationRequest clone() => TapOnNotificationRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TapOnNotificationRequest copyWith(void Function(TapOnNotificationRequest) updates) => super.copyWith((message) => updates(message as TapOnNotificationRequest)) as TapOnNotificationRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TapOnNotificationRequest create() => TapOnNotificationRequest._();
  TapOnNotificationRequest createEmptyInstance() => create();
  static $pb.PbList<TapOnNotificationRequest> createRepeated() => $pb.PbList<TapOnNotificationRequest>();
  @$core.pragma('dart2js:noInline')
  static TapOnNotificationRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TapOnNotificationRequest>(create);
  static TapOnNotificationRequest? _defaultInstance;

  TapOnNotificationRequest_FindBy whichFindBy() => _TapOnNotificationRequest_FindByByTag[$_whichOneof(0)]!;
  void clearFindBy() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => clearField(1);

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

class Empty extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Empty', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  Empty._() : super();
  factory Empty() => create();
  factory Empty.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Empty.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Empty clone() => Empty()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Empty copyWith(void Function(Empty) updates) => super.copyWith((message) => updates(message as Empty)) as Empty; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  Empty createEmptyInstance() => create();
  static $pb.PbList<Empty> createRepeated() => $pb.PbList<Empty>();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

class OpenQuickSettingsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'OpenQuickSettingsRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  OpenQuickSettingsRequest._() : super();
  factory OpenQuickSettingsRequest() => create();
  factory OpenQuickSettingsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpenQuickSettingsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OpenQuickSettingsRequest clone() => OpenQuickSettingsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OpenQuickSettingsRequest copyWith(void Function(OpenQuickSettingsRequest) updates) => super.copyWith((message) => updates(message as OpenQuickSettingsRequest)) as OpenQuickSettingsRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static OpenQuickSettingsRequest create() => OpenQuickSettingsRequest._();
  OpenQuickSettingsRequest createEmptyInstance() => create();
  static $pb.PbList<OpenQuickSettingsRequest> createRepeated() => $pb.PbList<OpenQuickSettingsRequest>();
  @$core.pragma('dart2js:noInline')
  static OpenQuickSettingsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OpenQuickSettingsRequest>(create);
  static OpenQuickSettingsRequest? _defaultInstance;
}

class DarkModeRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'DarkModeRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..hasRequiredFields = false
  ;

  DarkModeRequest._() : super();
  factory DarkModeRequest({
    $core.String? appId,
  }) {
    final _result = create();
    if (appId != null) {
      _result.appId = appId;
    }
    return _result;
  }
  factory DarkModeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DarkModeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DarkModeRequest clone() => DarkModeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DarkModeRequest copyWith(void Function(DarkModeRequest) updates) => super.copyWith((message) => updates(message as DarkModeRequest)) as DarkModeRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static DarkModeRequest create() => DarkModeRequest._();
  DarkModeRequest createEmptyInstance() => create();
  static $pb.PbList<DarkModeRequest> createRepeated() => $pb.PbList<DarkModeRequest>();
  @$core.pragma('dart2js:noInline')
  static DarkModeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DarkModeRequest>(create);
  static DarkModeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appId => $_getSZ(0);
  @$pb.TagNumber(1)
  set appId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppId() => clearField(1);
}

class GetNativeViewsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetNativeViewsRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOM<Selector>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..hasRequiredFields = false
  ;

  GetNativeViewsRequest._() : super();
  factory GetNativeViewsRequest({
    Selector? selector,
  }) {
    final _result = create();
    if (selector != null) {
      _result.selector = selector;
    }
    return _result;
  }
  factory GetNativeViewsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNativeViewsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNativeViewsRequest clone() => GetNativeViewsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNativeViewsRequest copyWith(void Function(GetNativeViewsRequest) updates) => super.copyWith((message) => updates(message as GetNativeViewsRequest)) as GetNativeViewsRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetNativeViewsRequest create() => GetNativeViewsRequest._();
  GetNativeViewsRequest createEmptyInstance() => create();
  static $pb.PbList<GetNativeViewsRequest> createRepeated() => $pb.PbList<GetNativeViewsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNativeViewsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNativeViewsRequest>(create);
  static GetNativeViewsRequest? _defaultInstance;

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

class GetNativeViewsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetNativeViewsResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..pc<NativeView>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'nativeViews', $pb.PbFieldType.PM, protoName: 'nativeViews', subBuilder: NativeView.create)
    ..hasRequiredFields = false
  ;

  GetNativeViewsResponse._() : super();
  factory GetNativeViewsResponse({
    $core.Iterable<NativeView>? nativeViews,
  }) {
    final _result = create();
    if (nativeViews != null) {
      _result.nativeViews.addAll(nativeViews);
    }
    return _result;
  }
  factory GetNativeViewsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNativeViewsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNativeViewsResponse clone() => GetNativeViewsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNativeViewsResponse copyWith(void Function(GetNativeViewsResponse) updates) => super.copyWith((message) => updates(message as GetNativeViewsResponse)) as GetNativeViewsResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetNativeViewsResponse create() => GetNativeViewsResponse._();
  GetNativeViewsResponse createEmptyInstance() => create();
  static $pb.PbList<GetNativeViewsResponse> createRepeated() => $pb.PbList<GetNativeViewsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNativeViewsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNativeViewsResponse>(create);
  static GetNativeViewsResponse? _defaultInstance;

  @$pb.TagNumber(2)
  $core.List<NativeView> get nativeViews => $_getList(0);
}

class GetNotificationsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetNotificationsRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  GetNotificationsRequest._() : super();
  factory GetNotificationsRequest() => create();
  factory GetNotificationsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNotificationsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNotificationsRequest clone() => GetNotificationsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNotificationsRequest copyWith(void Function(GetNotificationsRequest) updates) => super.copyWith((message) => updates(message as GetNotificationsRequest)) as GetNotificationsRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetNotificationsRequest create() => GetNotificationsRequest._();
  GetNotificationsRequest createEmptyInstance() => create();
  static $pb.PbList<GetNotificationsRequest> createRepeated() => $pb.PbList<GetNotificationsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetNotificationsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNotificationsRequest>(create);
  static GetNotificationsRequest? _defaultInstance;
}

class GetNotificationsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'GetNotificationsResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..pc<Notification>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'notifications', $pb.PbFieldType.PM, subBuilder: Notification.create)
    ..hasRequiredFields = false
  ;

  GetNotificationsResponse._() : super();
  factory GetNotificationsResponse({
    $core.Iterable<Notification>? notifications,
  }) {
    final _result = create();
    if (notifications != null) {
      _result.notifications.addAll(notifications);
    }
    return _result;
  }
  factory GetNotificationsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNotificationsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNotificationsResponse clone() => GetNotificationsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNotificationsResponse copyWith(void Function(GetNotificationsResponse) updates) => super.copyWith((message) => updates(message as GetNotificationsResponse)) as GetNotificationsResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetNotificationsResponse create() => GetNotificationsResponse._();
  GetNotificationsResponse createEmptyInstance() => create();
  static $pb.PbList<GetNotificationsResponse> createRepeated() => $pb.PbList<GetNotificationsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNotificationsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNotificationsResponse>(create);
  static GetNotificationsResponse? _defaultInstance;

  @$pb.TagNumber(2)
  $core.List<Notification> get notifications => $_getList(0);
}

class TapRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'TapRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOM<Selector>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..hasRequiredFields = false
  ;

  TapRequest._() : super();
  factory TapRequest({
    Selector? selector,
    $core.String? appId,
  }) {
    final _result = create();
    if (selector != null) {
      _result.selector = selector;
    }
    if (appId != null) {
      _result.appId = appId;
    }
    return _result;
  }
  factory TapRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TapRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TapRequest clone() => TapRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TapRequest copyWith(void Function(TapRequest) updates) => super.copyWith((message) => updates(message as TapRequest)) as TapRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TapRequest create() => TapRequest._();
  TapRequest createEmptyInstance() => create();
  static $pb.PbList<TapRequest> createRepeated() => $pb.PbList<TapRequest>();
  @$core.pragma('dart2js:noInline')
  static TapRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TapRequest>(create);
  static TapRequest? _defaultInstance;

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

  @$pb.TagNumber(2)
  $core.String get appId => $_getSZ(1);
  @$pb.TagNumber(2)
  set appId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAppId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAppId() => clearField(2);
}

enum EnterTextRequest_FindBy {
  index_, 
  selector, 
  notSet
}

class EnterTextRequest extends $pb.GeneratedMessage {
  static const $core.Map<$core.int, EnterTextRequest_FindBy> _EnterTextRequest_FindByByTag = {
    3 : EnterTextRequest_FindBy.index_,
    4 : EnterTextRequest_FindBy.selector,
    0 : EnterTextRequest_FindBy.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'EnterTextRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..oo(0, [3, 4])
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'data')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..a<$core.int>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'index', $pb.PbFieldType.OU3)
    ..aOM<Selector>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'selector', subBuilder: Selector.create)
    ..hasRequiredFields = false
  ;

  EnterTextRequest._() : super();
  factory EnterTextRequest({
    $core.String? data,
    $core.String? appId,
    $core.int? index,
    Selector? selector,
  }) {
    final _result = create();
    if (data != null) {
      _result.data = data;
    }
    if (appId != null) {
      _result.appId = appId;
    }
    if (index != null) {
      _result.index = index;
    }
    if (selector != null) {
      _result.selector = selector;
    }
    return _result;
  }
  factory EnterTextRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EnterTextRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EnterTextRequest clone() => EnterTextRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EnterTextRequest copyWith(void Function(EnterTextRequest) updates) => super.copyWith((message) => updates(message as EnterTextRequest)) as EnterTextRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static EnterTextRequest create() => EnterTextRequest._();
  EnterTextRequest createEmptyInstance() => create();
  static $pb.PbList<EnterTextRequest> createRepeated() => $pb.PbList<EnterTextRequest>();
  @$core.pragma('dart2js:noInline')
  static EnterTextRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnterTextRequest>(create);
  static EnterTextRequest? _defaultInstance;

  EnterTextRequest_FindBy whichFindBy() => _EnterTextRequest_FindByByTag[$_whichOneof(0)]!;
  void clearFindBy() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get data => $_getSZ(0);
  @$pb.TagNumber(1)
  set data($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get appId => $_getSZ(1);
  @$pb.TagNumber(2)
  set appId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAppId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAppId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get index => $_getIZ(2);
  @$pb.TagNumber(3)
  set index($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIndex() => $_has(2);
  @$pb.TagNumber(3)
  void clearIndex() => clearField(3);

  @$pb.TagNumber(4)
  Selector get selector => $_getN(3);
  @$pb.TagNumber(4)
  set selector(Selector v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSelector() => $_has(3);
  @$pb.TagNumber(4)
  void clearSelector() => clearField(4);
  @$pb.TagNumber(4)
  Selector ensureSelector() => $_ensure(3);
}

class SwipeRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SwipeRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..a<$core.double>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'startX', $pb.PbFieldType.OF, protoName: 'startX')
    ..a<$core.double>(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'startY', $pb.PbFieldType.OF, protoName: 'startY')
    ..a<$core.double>(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'endX', $pb.PbFieldType.OF, protoName: 'endX')
    ..a<$core.double>(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'endY', $pb.PbFieldType.OF, protoName: 'endY')
    ..a<$core.int>(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'steps', $pb.PbFieldType.OU3)
    ..aOS(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appId', protoName: 'appId')
    ..hasRequiredFields = false
  ;

  SwipeRequest._() : super();
  factory SwipeRequest({
    $core.double? startX,
    $core.double? startY,
    $core.double? endX,
    $core.double? endY,
    $core.int? steps,
    $core.String? appId,
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
    if (appId != null) {
      _result.appId = appId;
    }
    return _result;
  }
  factory SwipeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SwipeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SwipeRequest clone() => SwipeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SwipeRequest copyWith(void Function(SwipeRequest) updates) => super.copyWith((message) => updates(message as SwipeRequest)) as SwipeRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SwipeRequest create() => SwipeRequest._();
  SwipeRequest createEmptyInstance() => create();
  static $pb.PbList<SwipeRequest> createRepeated() => $pb.PbList<SwipeRequest>();
  @$core.pragma('dart2js:noInline')
  static SwipeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwipeRequest>(create);
  static SwipeRequest? _defaultInstance;

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
  set steps($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSteps() => $_has(4);
  @$pb.TagNumber(5)
  void clearSteps() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get appId => $_getSZ(5);
  @$pb.TagNumber(6)
  set appId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAppId() => $_has(5);
  @$pb.TagNumber(6)
  void clearAppId() => clearField(6);
}

class HandlePermissionRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'HandlePermissionRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..e<HandlePermissionRequest_Code>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'code', $pb.PbFieldType.OE, defaultOrMaker: HandlePermissionRequest_Code.WHILE_USING, valueOf: HandlePermissionRequest_Code.valueOf, enumValues: HandlePermissionRequest_Code.values)
    ..hasRequiredFields = false
  ;

  HandlePermissionRequest._() : super();
  factory HandlePermissionRequest({
    HandlePermissionRequest_Code? code,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    return _result;
  }
  factory HandlePermissionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory HandlePermissionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  HandlePermissionRequest clone() => HandlePermissionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  HandlePermissionRequest copyWith(void Function(HandlePermissionRequest) updates) => super.copyWith((message) => updates(message as HandlePermissionRequest)) as HandlePermissionRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static HandlePermissionRequest create() => HandlePermissionRequest._();
  HandlePermissionRequest createEmptyInstance() => create();
  static $pb.PbList<HandlePermissionRequest> createRepeated() => $pb.PbList<HandlePermissionRequest>();
  @$core.pragma('dart2js:noInline')
  static HandlePermissionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HandlePermissionRequest>(create);
  static HandlePermissionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HandlePermissionRequest_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(HandlePermissionRequest_Code v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);
}

class SetLocationAccuracyRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SetLocationAccuracyRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..e<SetLocationAccuracyRequest_LocationAccuracy>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'locationAccuracy', $pb.PbFieldType.OE, protoName: 'locationAccuracy', defaultOrMaker: SetLocationAccuracyRequest_LocationAccuracy.COARSE, valueOf: SetLocationAccuracyRequest_LocationAccuracy.valueOf, enumValues: SetLocationAccuracyRequest_LocationAccuracy.values)
    ..hasRequiredFields = false
  ;

  SetLocationAccuracyRequest._() : super();
  factory SetLocationAccuracyRequest({
    SetLocationAccuracyRequest_LocationAccuracy? locationAccuracy,
  }) {
    final _result = create();
    if (locationAccuracy != null) {
      _result.locationAccuracy = locationAccuracy;
    }
    return _result;
  }
  factory SetLocationAccuracyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetLocationAccuracyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetLocationAccuracyRequest clone() => SetLocationAccuracyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetLocationAccuracyRequest copyWith(void Function(SetLocationAccuracyRequest) updates) => super.copyWith((message) => updates(message as SetLocationAccuracyRequest)) as SetLocationAccuracyRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SetLocationAccuracyRequest create() => SetLocationAccuracyRequest._();
  SetLocationAccuracyRequest createEmptyInstance() => create();
  static $pb.PbList<SetLocationAccuracyRequest> createRepeated() => $pb.PbList<SetLocationAccuracyRequest>();
  @$core.pragma('dart2js:noInline')
  static SetLocationAccuracyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetLocationAccuracyRequest>(create);
  static SetLocationAccuracyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SetLocationAccuracyRequest_LocationAccuracy get locationAccuracy => $_getN(0);
  @$pb.TagNumber(1)
  set locationAccuracy(SetLocationAccuracyRequest_LocationAccuracy v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasLocationAccuracy() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocationAccuracy() => clearField(1);
}

class PermissionDialogVisibleRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PermissionDialogVisibleRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'timeoutMillis', $pb.PbFieldType.OU6, protoName: 'timeoutMillis', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  PermissionDialogVisibleRequest._() : super();
  factory PermissionDialogVisibleRequest({
    $fixnum.Int64? timeoutMillis,
  }) {
    final _result = create();
    if (timeoutMillis != null) {
      _result.timeoutMillis = timeoutMillis;
    }
    return _result;
  }
  factory PermissionDialogVisibleRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PermissionDialogVisibleRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PermissionDialogVisibleRequest clone() => PermissionDialogVisibleRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PermissionDialogVisibleRequest copyWith(void Function(PermissionDialogVisibleRequest) updates) => super.copyWith((message) => updates(message as PermissionDialogVisibleRequest)) as PermissionDialogVisibleRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PermissionDialogVisibleRequest create() => PermissionDialogVisibleRequest._();
  PermissionDialogVisibleRequest createEmptyInstance() => create();
  static $pb.PbList<PermissionDialogVisibleRequest> createRepeated() => $pb.PbList<PermissionDialogVisibleRequest>();
  @$core.pragma('dart2js:noInline')
  static PermissionDialogVisibleRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PermissionDialogVisibleRequest>(create);
  static PermissionDialogVisibleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timeoutMillis => $_getI64(0);
  @$pb.TagNumber(1)
  set timeoutMillis($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimeoutMillis() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeoutMillis() => clearField(1);
}

class PermissionDialogVisibleResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'PermissionDialogVisibleResponse', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOB(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'visible')
    ..hasRequiredFields = false
  ;

  PermissionDialogVisibleResponse._() : super();
  factory PermissionDialogVisibleResponse({
    $core.bool? visible,
  }) {
    final _result = create();
    if (visible != null) {
      _result.visible = visible;
    }
    return _result;
  }
  factory PermissionDialogVisibleResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PermissionDialogVisibleResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PermissionDialogVisibleResponse clone() => PermissionDialogVisibleResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PermissionDialogVisibleResponse copyWith(void Function(PermissionDialogVisibleResponse) updates) => super.copyWith((message) => updates(message as PermissionDialogVisibleResponse)) as PermissionDialogVisibleResponse; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PermissionDialogVisibleResponse create() => PermissionDialogVisibleResponse._();
  PermissionDialogVisibleResponse createEmptyInstance() => create();
  static $pb.PbList<PermissionDialogVisibleResponse> createRepeated() => $pb.PbList<PermissionDialogVisibleResponse>();
  @$core.pragma('dart2js:noInline')
  static PermissionDialogVisibleResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PermissionDialogVisibleResponse>(create);
  static PermissionDialogVisibleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get visible => $_getBF(0);
  @$pb.TagNumber(1)
  set visible($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVisible() => $_has(0);
  @$pb.TagNumber(1)
  void clearVisible() => clearField(1);
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
    ..a<$core.int>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'instance', $pb.PbFieldType.OU3)
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
  set instance($core.int v) { $_setUnsignedInt32(8, v); }
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

class NativeView extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'NativeView', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'className', protoName: 'className')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'text')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'contentDescription', protoName: 'contentDescription')
    ..aOB(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'focused')
    ..aOB(5, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'enabled')
    ..a<$core.int>(6, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'childCount', $pb.PbFieldType.O3, protoName: 'childCount')
    ..aOS(7, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'resourceName', protoName: 'resourceName')
    ..aOS(8, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'applicationPackage', protoName: 'applicationPackage')
    ..pc<NativeView>(9, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'children', $pb.PbFieldType.PM, subBuilder: NativeView.create)
    ..hasRequiredFields = false
  ;

  NativeView._() : super();
  factory NativeView({
    $core.String? className,
    $core.String? text,
    $core.String? contentDescription,
    $core.bool? focused,
    $core.bool? enabled,
    $core.int? childCount,
    $core.String? resourceName,
    $core.String? applicationPackage,
    $core.Iterable<NativeView>? children,
  }) {
    final _result = create();
    if (className != null) {
      _result.className = className;
    }
    if (text != null) {
      _result.text = text;
    }
    if (contentDescription != null) {
      _result.contentDescription = contentDescription;
    }
    if (focused != null) {
      _result.focused = focused;
    }
    if (enabled != null) {
      _result.enabled = enabled;
    }
    if (childCount != null) {
      _result.childCount = childCount;
    }
    if (resourceName != null) {
      _result.resourceName = resourceName;
    }
    if (applicationPackage != null) {
      _result.applicationPackage = applicationPackage;
    }
    if (children != null) {
      _result.children.addAll(children);
    }
    return _result;
  }
  factory NativeView.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NativeView.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NativeView clone() => NativeView()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NativeView copyWith(void Function(NativeView) updates) => super.copyWith((message) => updates(message as NativeView)) as NativeView; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static NativeView create() => NativeView._();
  NativeView createEmptyInstance() => create();
  static $pb.PbList<NativeView> createRepeated() => $pb.PbList<NativeView>();
  @$core.pragma('dart2js:noInline')
  static NativeView getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NativeView>(create);
  static NativeView? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get className => $_getSZ(0);
  @$pb.TagNumber(1)
  set className($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasClassName() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get contentDescription => $_getSZ(2);
  @$pb.TagNumber(3)
  set contentDescription($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContentDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearContentDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get focused => $_getBF(3);
  @$pb.TagNumber(4)
  set focused($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFocused() => $_has(3);
  @$pb.TagNumber(4)
  void clearFocused() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get enabled => $_getBF(4);
  @$pb.TagNumber(5)
  set enabled($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEnabled() => $_has(4);
  @$pb.TagNumber(5)
  void clearEnabled() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get childCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set childCount($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasChildCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearChildCount() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get resourceName => $_getSZ(6);
  @$pb.TagNumber(7)
  set resourceName($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasResourceName() => $_has(6);
  @$pb.TagNumber(7)
  void clearResourceName() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get applicationPackage => $_getSZ(7);
  @$pb.TagNumber(8)
  set applicationPackage($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasApplicationPackage() => $_has(7);
  @$pb.TagNumber(8)
  void clearApplicationPackage() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<NativeView> get children => $_getList(8);
}

class Notification extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'Notification', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..aOS(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'appName', protoName: 'appName')
    ..aOS(2, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'title')
    ..aOS(3, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'content')
    ..aOS(4, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'raw')
    ..hasRequiredFields = false
  ;

  Notification._() : super();
  factory Notification({
    $core.String? appName,
    $core.String? title,
    $core.String? content,
    $core.String? raw,
  }) {
    final _result = create();
    if (appName != null) {
      _result.appName = appName;
    }
    if (title != null) {
      _result.title = title;
    }
    if (content != null) {
      _result.content = content;
    }
    if (raw != null) {
      _result.raw = raw;
    }
    return _result;
  }
  factory Notification.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Notification.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Notification clone() => Notification()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Notification copyWith(void Function(Notification) updates) => super.copyWith((message) => updates(message as Notification)) as Notification; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Notification create() => Notification._();
  Notification createEmptyInstance() => create();
  static $pb.PbList<Notification> createRepeated() => $pb.PbList<Notification>();
  @$core.pragma('dart2js:noInline')
  static Notification getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Notification>(create);
  static Notification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appName => $_getSZ(0);
  @$pb.TagNumber(1)
  set appName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAppName() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get content => $_getSZ(2);
  @$pb.TagNumber(3)
  set content($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get raw => $_getSZ(3);
  @$pb.TagNumber(4)
  set raw($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRaw() => $_has(3);
  @$pb.TagNumber(4)
  void clearRaw() => clearField(4);
}

class SubmitTestResultsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'SubmitTestResultsRequest', package: const $pb.PackageName(const $core.bool.fromEnvironment('protobuf.omit_message_names') ? '' : 'patrol'), createEmptyInstance: create)
    ..m<$core.String, $core.String>(1, const $core.bool.fromEnvironment('protobuf.omit_field_names') ? '' : 'results', entryClassName: 'SubmitTestResultsRequest.ResultsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('patrol'))
    ..hasRequiredFields = false
  ;

  SubmitTestResultsRequest._() : super();
  factory SubmitTestResultsRequest({
    $core.Map<$core.String, $core.String>? results,
  }) {
    final _result = create();
    if (results != null) {
      _result.results.addAll(results);
    }
    return _result;
  }
  factory SubmitTestResultsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubmitTestResultsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubmitTestResultsRequest clone() => SubmitTestResultsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubmitTestResultsRequest copyWith(void Function(SubmitTestResultsRequest) updates) => super.copyWith((message) => updates(message as SubmitTestResultsRequest)) as SubmitTestResultsRequest; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SubmitTestResultsRequest create() => SubmitTestResultsRequest._();
  SubmitTestResultsRequest createEmptyInstance() => create();
  static $pb.PbList<SubmitTestResultsRequest> createRepeated() => $pb.PbList<SubmitTestResultsRequest>();
  @$core.pragma('dart2js:noInline')
  static SubmitTestResultsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubmitTestResultsRequest>(create);
  static SubmitTestResultsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.String> get results => $_getMap(0);
}

