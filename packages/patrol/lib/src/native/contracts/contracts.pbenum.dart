///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class HandlePermissionRequest_Code extends $pb.ProtobufEnum {
  static const HandlePermissionRequest_Code WHILE_USING = HandlePermissionRequest_Code._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'WHILE_USING');
  static const HandlePermissionRequest_Code ONLY_THIS_TIME = HandlePermissionRequest_Code._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'ONLY_THIS_TIME');
  static const HandlePermissionRequest_Code DENIED = HandlePermissionRequest_Code._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'DENIED');

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
  static const SetLocationAccuracyRequest_LocationAccuracy COARSE = SetLocationAccuracyRequest_LocationAccuracy._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'COARSE');
  static const SetLocationAccuracyRequest_LocationAccuracy FINE = SetLocationAccuracyRequest_LocationAccuracy._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'FINE');

  static const $core.List<SetLocationAccuracyRequest_LocationAccuracy> values = <SetLocationAccuracyRequest_LocationAccuracy> [
    COARSE,
    FINE,
  ];

  static final $core.Map<$core.int, SetLocationAccuracyRequest_LocationAccuracy> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SetLocationAccuracyRequest_LocationAccuracy? valueOf($core.int value) => _byValue[value];

  const SetLocationAccuracyRequest_LocationAccuracy._($core.int v, $core.String n) : super(v, n);
}

