///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class HandlePermissionCommand_Code extends $pb.ProtobufEnum {
  static const HandlePermissionCommand_Code WHILE_USING =
      HandlePermissionCommand_Code._(
          0,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'WHILE_USING');
  static const HandlePermissionCommand_Code ONLY_THIS_TIME =
      HandlePermissionCommand_Code._(
          1,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'ONLY_THIS_TIME');
  static const HandlePermissionCommand_Code DENIED =
      HandlePermissionCommand_Code._(
          2,
          const $core.bool.fromEnvironment('protobuf.omit_enum_names')
              ? ''
              : 'DENIED');

  static const $core.List<HandlePermissionCommand_Code> values =
      <HandlePermissionCommand_Code>[
    WHILE_USING,
    ONLY_THIS_TIME,
    DENIED,
  ];

  static final $core.Map<$core.int, HandlePermissionCommand_Code> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static HandlePermissionCommand_Code? valueOf($core.int value) =>
      _byValue[value];

  const HandlePermissionCommand_Code._($core.int v, $core.String n)
      : super(v, n);
}
