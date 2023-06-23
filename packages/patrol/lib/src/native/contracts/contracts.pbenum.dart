//
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class RunDartTestResponse_Result extends $pb.ProtobufEnum {
  static const RunDartTestResponse_Result SUCCESS = RunDartTestResponse_Result._(0, _omitEnumNames ? '' : 'SUCCESS');
  static const RunDartTestResponse_Result SKIPPED = RunDartTestResponse_Result._(1, _omitEnumNames ? '' : 'SKIPPED');
  static const RunDartTestResponse_Result FAILURE = RunDartTestResponse_Result._(2, _omitEnumNames ? '' : 'FAILURE');

  static const $core.List<RunDartTestResponse_Result> values = <RunDartTestResponse_Result> [
    SUCCESS,
    SKIPPED,
    FAILURE,
  ];

  static final $core.Map<$core.int, RunDartTestResponse_Result> _byValue = $pb.ProtobufEnum.initByValue(values);
  static RunDartTestResponse_Result? valueOf($core.int value) => _byValue[value];

  const RunDartTestResponse_Result._($core.int v, $core.String n) : super(v, n);
}

class HandlePermissionRequest_Code extends $pb.ProtobufEnum {
  static const HandlePermissionRequest_Code WHILE_USING = HandlePermissionRequest_Code._(0, _omitEnumNames ? '' : 'WHILE_USING');
  static const HandlePermissionRequest_Code ONLY_THIS_TIME = HandlePermissionRequest_Code._(1, _omitEnumNames ? '' : 'ONLY_THIS_TIME');
  static const HandlePermissionRequest_Code DENIED = HandlePermissionRequest_Code._(2, _omitEnumNames ? '' : 'DENIED');

  static const $core.List<HandlePermissionRequest_Code> values = <HandlePermissionRequest_Code> [
    WHILE_USING,
    ONLY_THIS_TIME,
    DENIED,
  ];

  static final $core.Map<$core.int, HandlePermissionRequest_Code> _byValue = $pb.ProtobufEnum.initByValue(values);
  static HandlePermissionRequest_Code? valueOf($core.int value) => _byValue[value];

  const HandlePermissionRequest_Code._($core.int v, $core.String n) : super(v, n);
}

class SetLocationAccuracyRequest_LocationAccuracy extends $pb.ProtobufEnum {
  static const SetLocationAccuracyRequest_LocationAccuracy COARSE = SetLocationAccuracyRequest_LocationAccuracy._(0, _omitEnumNames ? '' : 'COARSE');
  static const SetLocationAccuracyRequest_LocationAccuracy FINE = SetLocationAccuracyRequest_LocationAccuracy._(1, _omitEnumNames ? '' : 'FINE');

  static const $core.List<SetLocationAccuracyRequest_LocationAccuracy> values = <SetLocationAccuracyRequest_LocationAccuracy> [
    COARSE,
    FINE,
  ];

  static final $core.Map<$core.int, SetLocationAccuracyRequest_LocationAccuracy> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SetLocationAccuracyRequest_LocationAccuracy? valueOf($core.int value) => _byValue[value];

  const SetLocationAccuracyRequest_LocationAccuracy._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
