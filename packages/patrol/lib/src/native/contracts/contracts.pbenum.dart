///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class RunDartTestResponse_Result extends $pb.ProtobufEnum {
  static const RunDartTestResponse_Result SUCCESS =
      RunDartTestResponse_Result._(
          0,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'SUCCESS');
  static const RunDartTestResponse_Result SKIPPED =
      RunDartTestResponse_Result._(
          1,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'SKIPPED');
  static const RunDartTestResponse_Result FAILURE =
      RunDartTestResponse_Result._(
          2,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'FAILURE');

  static const $core.List<RunDartTestResponse_Result> values =
      <RunDartTestResponse_Result>[
    SUCCESS,
    SKIPPED,
    FAILURE,
  ];

  static final $core.Map<$core.int, RunDartTestResponse_Result> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static RunDartTestResponse_Result? valueOf($core.int value) =>
      _byValue[value];

  const RunDartTestResponse_Result._($core.int v, $core.String n) : super(v, n);
}

class EnterTextRequest_KeyboardBehavior extends $pb.ProtobufEnum {
  static const EnterTextRequest_KeyboardBehavior SHOW_AND_DISMISS =
      EnterTextRequest_KeyboardBehavior._(
          0,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'SHOW_AND_DISMISS');
  static const EnterTextRequest_KeyboardBehavior ALTERNATIVE =
      EnterTextRequest_KeyboardBehavior._(
          1,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'ALTERNATIVE');

  static const $core.List<EnterTextRequest_KeyboardBehavior> values =
      <EnterTextRequest_KeyboardBehavior>[
    SHOW_AND_DISMISS,
    ALTERNATIVE,
  ];

  static final $core.Map<$core.int, EnterTextRequest_KeyboardBehavior>
      _byValue = $pb.ProtobufEnum.initByValue(values);
  static EnterTextRequest_KeyboardBehavior? valueOf($core.int value) =>
      _byValue[value];

  const EnterTextRequest_KeyboardBehavior._($core.int v, $core.String n)
      : super(v, n);
}

class HandlePermissionRequest_Code extends $pb.ProtobufEnum {
  static const HandlePermissionRequest_Code WHILE_USING =
      HandlePermissionRequest_Code._(
          0,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'WHILE_USING');
  static const HandlePermissionRequest_Code ONLY_THIS_TIME =
      HandlePermissionRequest_Code._(
          1,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'ONLY_THIS_TIME');
  static const HandlePermissionRequest_Code DENIED =
      HandlePermissionRequest_Code._(
          2,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'DENIED');

  static const $core.List<HandlePermissionRequest_Code> values =
      <HandlePermissionRequest_Code>[
    WHILE_USING,
    ONLY_THIS_TIME,
    DENIED,
  ];

  static final $core.Map<$core.int, HandlePermissionRequest_Code> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static HandlePermissionRequest_Code? valueOf($core.int value) =>
      _byValue[value];

  const HandlePermissionRequest_Code._($core.int v, $core.String n)
      : super(v, n);
}

class SetLocationAccuracyRequest_LocationAccuracy extends $pb.ProtobufEnum {
  static const SetLocationAccuracyRequest_LocationAccuracy COARSE =
      SetLocationAccuracyRequest_LocationAccuracy._(
          0,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'COARSE');
  static const SetLocationAccuracyRequest_LocationAccuracy FINE =
      SetLocationAccuracyRequest_LocationAccuracy._(
          1,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'FINE');

  static const $core.List<SetLocationAccuracyRequest_LocationAccuracy> values =
      <SetLocationAccuracyRequest_LocationAccuracy>[
    COARSE,
    FINE,
  ];

  static final $core.Map<$core.int, SetLocationAccuracyRequest_LocationAccuracy>
      _byValue = $pb.ProtobufEnum.initByValue(values);
  static SetLocationAccuracyRequest_LocationAccuracy? valueOf(
          $core.int value) =>
      _byValue[value];

  const SetLocationAccuracyRequest_LocationAccuracy._(
      $core.int v, $core.String n)
      : super(v, n);
}
