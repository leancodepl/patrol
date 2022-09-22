///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use openAppCommandDescriptor instead')
const OpenAppCommand$json = const {
  '1': 'OpenAppCommand',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `OpenAppCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openAppCommandDescriptor = $convert.base64Decode('Cg5PcGVuQXBwQ29tbWFuZBIUCgVhcHBJZBgBIAEoCVIFYXBwSWQ=');
@$core.Deprecated('Use tapCommandDescriptor instead')
const TapCommand$json = const {
  '1': 'TapCommand',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
    const {'1': 'selector', '3': 2, '4': 1, '5': 11, '6': '.patrol.Selector', '10': 'selector'},
  ],
};

/// Descriptor for `TapCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tapCommandDescriptor = $convert.base64Decode('CgpUYXBDb21tYW5kEhQKBWFwcElkGAEgASgJUgVhcHBJZBIsCghzZWxlY3RvchgCIAEoCzIQLnBhdHJvbC5TZWxlY3RvclIIc2VsZWN0b3I=');
@$core.Deprecated('Use doubleTapCommandDescriptor instead')
const DoubleTapCommand$json = const {
  '1': 'DoubleTapCommand',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
    const {'1': 'selector', '3': 2, '4': 1, '5': 11, '6': '.patrol.Selector', '10': 'selector'},
  ],
};

/// Descriptor for `DoubleTapCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List doubleTapCommandDescriptor = $convert.base64Decode('ChBEb3VibGVUYXBDb21tYW5kEhQKBWFwcElkGAEgASgJUgVhcHBJZBIsCghzZWxlY3RvchgCIAEoCzIQLnBhdHJvbC5TZWxlY3RvclIIc2VsZWN0b3I=');
@$core.Deprecated('Use enterTextBySelectorCommandDescriptor instead')
const EnterTextBySelectorCommand$json = const {
  '1': 'EnterTextBySelectorCommand',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
    const {'1': 'data', '3': 2, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'selector', '3': 3, '4': 1, '5': 11, '6': '.patrol.Selector', '10': 'selector'},
  ],
};

/// Descriptor for `EnterTextBySelectorCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List enterTextBySelectorCommandDescriptor = $convert.base64Decode('ChpFbnRlclRleHRCeVNlbGVjdG9yQ29tbWFuZBIUCgVhcHBJZBgBIAEoCVIFYXBwSWQSEgoEZGF0YRgCIAEoCVIEZGF0YRIsCghzZWxlY3RvchgDIAEoCzIQLnBhdHJvbC5TZWxlY3RvclIIc2VsZWN0b3I=');
@$core.Deprecated('Use enterTextByIndexCommandDescriptor instead')
const EnterTextByIndexCommand$json = const {
  '1': 'EnterTextByIndexCommand',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
    const {'1': 'data', '3': 2, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'index', '3': 3, '4': 1, '5': 13, '10': 'index'},
  ],
};

/// Descriptor for `EnterTextByIndexCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List enterTextByIndexCommandDescriptor = $convert.base64Decode('ChdFbnRlclRleHRCeUluZGV4Q29tbWFuZBIUCgVhcHBJZBgBIAEoCVIFYXBwSWQSEgoEZGF0YRgCIAEoCVIEZGF0YRIUCgVpbmRleBgDIAEoDVIFaW5kZXg=');
@$core.Deprecated('Use tapOnNotificationByIndexCommandDescriptor instead')
const TapOnNotificationByIndexCommand$json = const {
  '1': 'TapOnNotificationByIndexCommand',
  '2': const [
    const {'1': 'index', '3': 1, '4': 1, '5': 13, '10': 'index'},
  ],
};

/// Descriptor for `TapOnNotificationByIndexCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tapOnNotificationByIndexCommandDescriptor = $convert.base64Decode('Ch9UYXBPbk5vdGlmaWNhdGlvbkJ5SW5kZXhDb21tYW5kEhQKBWluZGV4GAEgASgNUgVpbmRleA==');
@$core.Deprecated('Use tapOnNotificationBySelectorCommandDescriptor instead')
const TapOnNotificationBySelectorCommand$json = const {
  '1': 'TapOnNotificationBySelectorCommand',
  '2': const [
    const {'1': 'selector', '3': 1, '4': 1, '5': 11, '6': '.patrol.Selector', '10': 'selector'},
  ],
};

/// Descriptor for `TapOnNotificationBySelectorCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tapOnNotificationBySelectorCommandDescriptor = $convert.base64Decode('CiJUYXBPbk5vdGlmaWNhdGlvbkJ5U2VsZWN0b3JDb21tYW5kEiwKCHNlbGVjdG9yGAEgASgLMhAucGF0cm9sLlNlbGVjdG9yUghzZWxlY3Rvcg==');
@$core.Deprecated('Use swipeCommandDescriptor instead')
const SwipeCommand$json = const {
  '1': 'SwipeCommand',
  '2': const [
    const {'1': 'startX', '3': 1, '4': 1, '5': 2, '10': 'startX'},
    const {'1': 'startY', '3': 2, '4': 1, '5': 2, '10': 'startY'},
    const {'1': 'endX', '3': 3, '4': 1, '5': 2, '10': 'endX'},
    const {'1': 'endY', '3': 4, '4': 1, '5': 2, '10': 'endY'},
    const {'1': 'steps', '3': 5, '4': 1, '5': 13, '10': 'steps'},
  ],
};

/// Descriptor for `SwipeCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List swipeCommandDescriptor = $convert.base64Decode('CgxTd2lwZUNvbW1hbmQSFgoGc3RhcnRYGAEgASgCUgZzdGFydFgSFgoGc3RhcnRZGAIgASgCUgZzdGFydFkSEgoEZW5kWBgDIAEoAlIEZW5kWBISCgRlbmRZGAQgASgCUgRlbmRZEhQKBXN0ZXBzGAUgASgNUgVzdGVwcw==');
@$core.Deprecated('Use handlePermissionCommandDescriptor instead')
const HandlePermissionCommand$json = const {
  '1': 'HandlePermissionCommand',
  '2': const [
    const {'1': 'code', '3': 1, '4': 1, '5': 14, '6': '.patrol.HandlePermissionCommand.Code', '10': 'code'},
  ],
  '4': const [HandlePermissionCommand_Code$json],
};

@$core.Deprecated('Use handlePermissionCommandDescriptor instead')
const HandlePermissionCommand_Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'WHILE_USING', '2': 0},
    const {'1': 'ONLY_THIS_TIME', '2': 1},
    const {'1': 'DENIED', '2': 2},
  ],
};

/// Descriptor for `HandlePermissionCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handlePermissionCommandDescriptor = $convert.base64Decode('ChdIYW5kbGVQZXJtaXNzaW9uQ29tbWFuZBI4CgRjb2RlGAEgASgOMiQucGF0cm9sLkhhbmRsZVBlcm1pc3Npb25Db21tYW5kLkNvZGVSBGNvZGUiNwoEQ29kZRIPCgtXSElMRV9VU0lORxAAEhIKDk9OTFlfVEhJU19USU1FEAESCgoGREVOSUVEEAI=');
@$core.Deprecated('Use selectorDescriptor instead')
const Selector$json = const {
  '1': 'Selector',
  '2': const [
    const {'1': 'text', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'text', '17': true},
    const {'1': 'textStartsWith', '3': 2, '4': 1, '5': 9, '9': 1, '10': 'textStartsWith', '17': true},
    const {'1': 'textContains', '3': 3, '4': 1, '5': 9, '9': 2, '10': 'textContains', '17': true},
    const {'1': 'className', '3': 4, '4': 1, '5': 9, '9': 3, '10': 'className', '17': true},
    const {'1': 'contentDescription', '3': 5, '4': 1, '5': 9, '9': 4, '10': 'contentDescription', '17': true},
    const {'1': 'contentDescriptionStartsWith', '3': 6, '4': 1, '5': 9, '9': 5, '10': 'contentDescriptionStartsWith', '17': true},
    const {'1': 'contentDescriptionContains', '3': 7, '4': 1, '5': 9, '9': 6, '10': 'contentDescriptionContains', '17': true},
    const {'1': 'resourceId', '3': 8, '4': 1, '5': 9, '9': 7, '10': 'resourceId', '17': true},
    const {'1': 'instance', '3': 9, '4': 1, '5': 13, '9': 8, '10': 'instance', '17': true},
    const {'1': 'enabled', '3': 10, '4': 1, '5': 8, '9': 9, '10': 'enabled', '17': true},
    const {'1': 'focused', '3': 11, '4': 1, '5': 8, '9': 10, '10': 'focused', '17': true},
    const {'1': 'pkg', '3': 12, '4': 1, '5': 9, '9': 11, '10': 'pkg', '17': true},
  ],
  '8': const [
    const {'1': '_text'},
    const {'1': '_textStartsWith'},
    const {'1': '_textContains'},
    const {'1': '_className'},
    const {'1': '_contentDescription'},
    const {'1': '_contentDescriptionStartsWith'},
    const {'1': '_contentDescriptionContains'},
    const {'1': '_resourceId'},
    const {'1': '_instance'},
    const {'1': '_enabled'},
    const {'1': '_focused'},
    const {'1': '_pkg'},
  ],
};

/// Descriptor for `Selector`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List selectorDescriptor = $convert.base64Decode('CghTZWxlY3RvchIXCgR0ZXh0GAEgASgJSABSBHRleHSIAQESKwoOdGV4dFN0YXJ0c1dpdGgYAiABKAlIAVIOdGV4dFN0YXJ0c1dpdGiIAQESJwoMdGV4dENvbnRhaW5zGAMgASgJSAJSDHRleHRDb250YWluc4gBARIhCgljbGFzc05hbWUYBCABKAlIA1IJY2xhc3NOYW1liAEBEjMKEmNvbnRlbnREZXNjcmlwdGlvbhgFIAEoCUgEUhJjb250ZW50RGVzY3JpcHRpb26IAQESRwocY29udGVudERlc2NyaXB0aW9uU3RhcnRzV2l0aBgGIAEoCUgFUhxjb250ZW50RGVzY3JpcHRpb25TdGFydHNXaXRoiAEBEkMKGmNvbnRlbnREZXNjcmlwdGlvbkNvbnRhaW5zGAcgASgJSAZSGmNvbnRlbnREZXNjcmlwdGlvbkNvbnRhaW5ziAEBEiMKCnJlc291cmNlSWQYCCABKAlIB1IKcmVzb3VyY2VJZIgBARIfCghpbnN0YW5jZRgJIAEoDUgIUghpbnN0YW5jZYgBARIdCgdlbmFibGVkGAogASgISAlSB2VuYWJsZWSIAQESHQoHZm9jdXNlZBgLIAEoCEgKUgdmb2N1c2VkiAEBEhUKA3BrZxgMIAEoCUgLUgNwa2eIAQFCBwoFX3RleHRCEQoPX3RleHRTdGFydHNXaXRoQg8KDV90ZXh0Q29udGFpbnNCDAoKX2NsYXNzTmFtZUIVChNfY29udGVudERlc2NyaXB0aW9uQh8KHV9jb250ZW50RGVzY3JpcHRpb25TdGFydHNXaXRoQh0KG19jb250ZW50RGVzY3JpcHRpb25Db250YWluc0INCgtfcmVzb3VyY2VJZEILCglfaW5zdGFuY2VCCgoIX2VuYWJsZWRCCgoIX2ZvY3VzZWRCBgoEX3BrZw==');
@$core.Deprecated('Use nativeWidgetDescriptor instead')
const NativeWidget$json = const {
  '1': 'NativeWidget',
  '2': const [
    const {'1': 'className', '3': 1, '4': 1, '5': 9, '10': 'className'},
    const {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    const {'1': 'contentDescription', '3': 3, '4': 1, '5': 9, '10': 'contentDescription'},
    const {'1': 'focused', '3': 4, '4': 1, '5': 8, '10': 'focused'},
    const {'1': 'enabled', '3': 5, '4': 1, '5': 8, '10': 'enabled'},
    const {'1': 'childCount', '3': 6, '4': 1, '5': 5, '10': 'childCount'},
    const {'1': 'resourceName', '3': 7, '4': 1, '5': 9, '10': 'resourceName'},
    const {'1': 'applicationPackage', '3': 8, '4': 1, '5': 9, '10': 'applicationPackage'},
    const {'1': 'children', '3': 9, '4': 3, '5': 11, '6': '.patrol.NativeWidget', '10': 'children'},
  ],
};

/// Descriptor for `NativeWidget`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nativeWidgetDescriptor = $convert.base64Decode('CgxOYXRpdmVXaWRnZXQSHAoJY2xhc3NOYW1lGAEgASgJUgljbGFzc05hbWUSEgoEdGV4dBgCIAEoCVIEdGV4dBIuChJjb250ZW50RGVzY3JpcHRpb24YAyABKAlSEmNvbnRlbnREZXNjcmlwdGlvbhIYCgdmb2N1c2VkGAQgASgIUgdmb2N1c2VkEhgKB2VuYWJsZWQYBSABKAhSB2VuYWJsZWQSHgoKY2hpbGRDb3VudBgGIAEoBVIKY2hpbGRDb3VudBIiCgxyZXNvdXJjZU5hbWUYByABKAlSDHJlc291cmNlTmFtZRIuChJhcHBsaWNhdGlvblBhY2thZ2UYCCABKAlSEmFwcGxpY2F0aW9uUGFja2FnZRIwCghjaGlsZHJlbhgJIAMoCzIULnBhdHJvbC5OYXRpdmVXaWRnZXRSCGNoaWxkcmVu');
@$core.Deprecated('Use nativeWidgetsQueryDescriptor instead')
const NativeWidgetsQuery$json = const {
  '1': 'NativeWidgetsQuery',
  '2': const [
    const {'1': 'selector', '3': 1, '4': 1, '5': 11, '6': '.patrol.Selector', '10': 'selector'},
  ],
};

/// Descriptor for `NativeWidgetsQuery`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nativeWidgetsQueryDescriptor = $convert.base64Decode('ChJOYXRpdmVXaWRnZXRzUXVlcnkSLAoIc2VsZWN0b3IYASABKAsyEC5wYXRyb2wuU2VsZWN0b3JSCHNlbGVjdG9y');
@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = const {
  '1': 'Notification',
  '2': const [
    const {'1': 'appName', '3': 1, '4': 1, '5': 9, '10': 'appName'},
    const {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'content', '3': 3, '4': 1, '5': 9, '10': 'content'},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode('CgxOb3RpZmljYXRpb24SGAoHYXBwTmFtZRgBIAEoCVIHYXBwTmFtZRIUCgV0aXRsZRgCIAEoCVIFdGl0bGUSGAoHY29udGVudBgDIAEoCVIHY29udGVudA==');
@$core.Deprecated('Use notificationsQueryResponseDescriptor instead')
const NotificationsQueryResponse$json = const {
  '1': 'NotificationsQueryResponse',
  '2': const [
    const {'1': 'notifications', '3': 1, '4': 3, '5': 11, '6': '.patrol.Notification', '10': 'notifications'},
  ],
};

/// Descriptor for `NotificationsQueryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationsQueryResponseDescriptor = $convert.base64Decode('ChpOb3RpZmljYXRpb25zUXVlcnlSZXNwb25zZRI6Cg1ub3RpZmljYXRpb25zGAEgAygLMhQucGF0cm9sLk5vdGlmaWNhdGlvblINbm90aWZpY2F0aW9ucw==');
@$core.Deprecated('Use nativeWidgetsQueryResponseDescriptor instead')
const NativeWidgetsQueryResponse$json = const {
  '1': 'NativeWidgetsQueryResponse',
  '2': const [
    const {'1': 'nativeWidgets', '3': 1, '4': 3, '5': 11, '6': '.patrol.NativeWidget', '10': 'nativeWidgets'},
  ],
};

/// Descriptor for `NativeWidgetsQueryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nativeWidgetsQueryResponseDescriptor = $convert.base64Decode('ChpOYXRpdmVXaWRnZXRzUXVlcnlSZXNwb25zZRI6Cg1uYXRpdmVXaWRnZXRzGAEgAygLMhQucGF0cm9sLk5hdGl2ZVdpZGdldFINbmF0aXZlV2lkZ2V0cw==');
