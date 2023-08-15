///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use listDartTestsResponseDescriptor instead')
const ListDartTestsResponse$json = const {
  '1': 'ListDartTestsResponse',
  '2': const [
    const {
      '1': 'group',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.patrol.DartGroupEntry',
      '10': 'group'
    },
  ],
};

/// Descriptor for `ListDartTestsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDartTestsResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0RGFydFRlc3RzUmVzcG9uc2USLAoFZ3JvdXAYASABKAsyFi5wYXRyb2wuRGFydEdyb3VwRW50cnlSBWdyb3Vw');
@$core.Deprecated('Use dartGroupEntryDescriptor instead')
const DartGroupEntry$json = const {
  '1': 'DartGroupEntry',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'fullName', '3': 2, '4': 1, '5': 9, '10': 'fullName'},
    const {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.patrol.DartGroupEntry.GroupEntryType',
      '10': 'type'
    },
    const {
      '1': 'entries',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.patrol.DartGroupEntry',
      '10': 'entries'
    },
  ],
  '4': const [DartGroupEntry_GroupEntryType$json],
};

@$core.Deprecated('Use dartGroupEntryDescriptor instead')
const DartGroupEntry_GroupEntryType$json = const {
  '1': 'GroupEntryType',
  '2': const [
    const {'1': 'GROUP', '2': 0},
    const {'1': 'TEST', '2': 1},
  ],
};

/// Descriptor for `DartGroupEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dartGroupEntryDescriptor = $convert.base64Decode(
    'Cg5EYXJ0R3JvdXBFbnRyeRISCgRuYW1lGAEgASgJUgRuYW1lEhoKCGZ1bGxOYW1lGAIgASgJUghmdWxsTmFtZRI5CgR0eXBlGAMgASgOMiUucGF0cm9sLkRhcnRHcm91cEVudHJ5Lkdyb3VwRW50cnlUeXBlUgR0eXBlEjAKB2VudHJpZXMYBCADKAsyFi5wYXRyb2wuRGFydEdyb3VwRW50cnlSB2VudHJpZXMiJQoOR3JvdXBFbnRyeVR5cGUSCQoFR1JPVVAQABIICgRURVNUEAE=');
@$core.Deprecated('Use runDartTestRequestDescriptor instead')
const RunDartTestRequest$json = const {
  '1': 'RunDartTestRequest',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RunDartTestRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runDartTestRequestDescriptor = $convert
    .base64Decode('ChJSdW5EYXJ0VGVzdFJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZQ==');
@$core.Deprecated('Use runDartTestResponseDescriptor instead')
const RunDartTestResponse$json = const {
  '1': 'RunDartTestResponse',
  '2': const [
    const {
      '1': 'result',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.patrol.RunDartTestResponse.Result',
      '10': 'result'
    },
    const {
      '1': 'details',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'details',
      '17': true
    },
  ],
  '4': const [RunDartTestResponse_Result$json],
  '8': const [
    const {'1': '_details'},
  ],
};

@$core.Deprecated('Use runDartTestResponseDescriptor instead')
const RunDartTestResponse_Result$json = const {
  '1': 'Result',
  '2': const [
    const {'1': 'SUCCESS', '2': 0},
    const {'1': 'SKIPPED', '2': 1},
    const {'1': 'FAILURE', '2': 2},
  ],
};

/// Descriptor for `RunDartTestResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runDartTestResponseDescriptor = $convert.base64Decode(
    'ChNSdW5EYXJ0VGVzdFJlc3BvbnNlEjoKBnJlc3VsdBgBIAEoDjIiLnBhdHJvbC5SdW5EYXJ0VGVzdFJlc3BvbnNlLlJlc3VsdFIGcmVzdWx0Eh0KB2RldGFpbHMYAiABKAlIAFIHZGV0YWlsc4gBASIvCgZSZXN1bHQSCwoHU1VDQ0VTUxAAEgsKB1NLSVBQRUQQARILCgdGQUlMVVJFEAJCCgoIX2RldGFpbHM=');
@$core.Deprecated('Use configureRequestDescriptor instead')
const ConfigureRequest$json = const {
  '1': 'ConfigureRequest',
  '2': const [
    const {
      '1': 'findTimeoutMillis',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'findTimeoutMillis'
    },
  ],
};

/// Descriptor for `ConfigureRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List configureRequestDescriptor = $convert.base64Decode(
    'ChBDb25maWd1cmVSZXF1ZXN0EiwKEWZpbmRUaW1lb3V0TWlsbGlzGAEgASgEUhFmaW5kVGltZW91dE1pbGxpcw==');
@$core.Deprecated('Use openAppRequestDescriptor instead')
const OpenAppRequest$json = const {
  '1': 'OpenAppRequest',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `OpenAppRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openAppRequestDescriptor = $convert
    .base64Decode('Cg5PcGVuQXBwUmVxdWVzdBIUCgVhcHBJZBgBIAEoCVIFYXBwSWQ=');
@$core.Deprecated('Use tapOnNotificationRequestDescriptor instead')
const TapOnNotificationRequest$json = const {
  '1': 'TapOnNotificationRequest',
  '2': const [
    const {'1': 'index', '3': 1, '4': 1, '5': 13, '9': 0, '10': 'index'},
    const {
      '1': 'selector',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.patrol.Selector',
      '9': 0,
      '10': 'selector'
    },
  ],
  '8': const [
    const {'1': 'findBy'},
  ],
};

/// Descriptor for `TapOnNotificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tapOnNotificationRequestDescriptor =
    $convert.base64Decode(
        'ChhUYXBPbk5vdGlmaWNhdGlvblJlcXVlc3QSFgoFaW5kZXgYASABKA1IAFIFaW5kZXgSLgoIc2VsZWN0b3IYAiABKAsyEC5wYXRyb2wuU2VsZWN0b3JIAFIIc2VsZWN0b3JCCAoGZmluZEJ5');
@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = const {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');
@$core.Deprecated('Use openQuickSettingsRequestDescriptor instead')
const OpenQuickSettingsRequest$json = const {
  '1': 'OpenQuickSettingsRequest',
};

/// Descriptor for `OpenQuickSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List openQuickSettingsRequestDescriptor =
    $convert.base64Decode('ChhPcGVuUXVpY2tTZXR0aW5nc1JlcXVlc3Q=');
@$core.Deprecated('Use darkModeRequestDescriptor instead')
const DarkModeRequest$json = const {
  '1': 'DarkModeRequest',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `DarkModeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List darkModeRequestDescriptor = $convert
    .base64Decode('Cg9EYXJrTW9kZVJlcXVlc3QSFAoFYXBwSWQYASABKAlSBWFwcElk');
@$core.Deprecated('Use getNativeViewsRequestDescriptor instead')
const GetNativeViewsRequest$json = const {
  '1': 'GetNativeViewsRequest',
  '2': const [
    const {
      '1': 'selector',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.patrol.Selector',
      '10': 'selector'
    },
    const {'1': 'appId', '3': 2, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `GetNativeViewsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNativeViewsRequestDescriptor = $convert.base64Decode(
    'ChVHZXROYXRpdmVWaWV3c1JlcXVlc3QSLAoIc2VsZWN0b3IYASABKAsyEC5wYXRyb2wuU2VsZWN0b3JSCHNlbGVjdG9yEhQKBWFwcElkGAIgASgJUgVhcHBJZA==');
@$core.Deprecated('Use getNativeViewsResponseDescriptor instead')
const GetNativeViewsResponse$json = const {
  '1': 'GetNativeViewsResponse',
  '2': const [
    const {
      '1': 'nativeViews',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.patrol.NativeView',
      '10': 'nativeViews'
    },
  ],
};

/// Descriptor for `GetNativeViewsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNativeViewsResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXROYXRpdmVWaWV3c1Jlc3BvbnNlEjQKC25hdGl2ZVZpZXdzGAIgAygLMhIucGF0cm9sLk5hdGl2ZVZpZXdSC25hdGl2ZVZpZXdz');
@$core.Deprecated('Use getNotificationsRequestDescriptor instead')
const GetNotificationsRequest$json = const {
  '1': 'GetNotificationsRequest',
};

/// Descriptor for `GetNotificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationsRequestDescriptor =
    $convert.base64Decode('ChdHZXROb3RpZmljYXRpb25zUmVxdWVzdA==');
@$core.Deprecated('Use getNotificationsResponseDescriptor instead')
const GetNotificationsResponse$json = const {
  '1': 'GetNotificationsResponse',
  '2': const [
    const {
      '1': 'notifications',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.patrol.Notification',
      '10': 'notifications'
    },
  ],
};

/// Descriptor for `GetNotificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationsResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXROb3RpZmljYXRpb25zUmVzcG9uc2USOgoNbm90aWZpY2F0aW9ucxgCIAMoCzIULnBhdHJvbC5Ob3RpZmljYXRpb25SDW5vdGlmaWNhdGlvbnM=');
@$core.Deprecated('Use tapRequestDescriptor instead')
const TapRequest$json = const {
  '1': 'TapRequest',
  '2': const [
    const {
      '1': 'selector',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.patrol.Selector',
      '10': 'selector'
    },
    const {'1': 'appId', '3': 2, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `TapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tapRequestDescriptor = $convert.base64Decode(
    'CgpUYXBSZXF1ZXN0EiwKCHNlbGVjdG9yGAEgASgLMhAucGF0cm9sLlNlbGVjdG9yUghzZWxlY3RvchIUCgVhcHBJZBgCIAEoCVIFYXBwSWQ=');
@$core.Deprecated('Use enterTextRequestDescriptor instead')
const EnterTextRequest$json = const {
  '1': 'EnterTextRequest',
  '2': const [
    const {'1': 'data', '3': 1, '4': 1, '5': 9, '10': 'data'},
    const {'1': 'appId', '3': 2, '4': 1, '5': 9, '10': 'appId'},
    const {'1': 'index', '3': 3, '4': 1, '5': 13, '9': 0, '10': 'index'},
    const {
      '1': 'selector',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.patrol.Selector',
      '9': 0,
      '10': 'selector'
    },
    const {'1': 'showKeyboard', '3': 5, '4': 1, '5': 8, '10': 'showKeyboard'},
  ],
  '8': const [
    const {'1': 'findBy'},
  ],
};

/// Descriptor for `EnterTextRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List enterTextRequestDescriptor = $convert.base64Decode(
    'ChBFbnRlclRleHRSZXF1ZXN0EhIKBGRhdGEYASABKAlSBGRhdGESFAoFYXBwSWQYAiABKAlSBWFwcElkEhYKBWluZGV4GAMgASgNSABSBWluZGV4Ei4KCHNlbGVjdG9yGAQgASgLMhAucGF0cm9sLlNlbGVjdG9ySABSCHNlbGVjdG9yEiIKDHNob3dLZXlib2FyZBgFIAEoCFIMc2hvd0tleWJvYXJkQggKBmZpbmRCeQ==');
@$core.Deprecated('Use swipeRequestDescriptor instead')
const SwipeRequest$json = const {
  '1': 'SwipeRequest',
  '2': const [
    const {'1': 'startX', '3': 1, '4': 1, '5': 2, '10': 'startX'},
    const {'1': 'startY', '3': 2, '4': 1, '5': 2, '10': 'startY'},
    const {'1': 'endX', '3': 3, '4': 1, '5': 2, '10': 'endX'},
    const {'1': 'endY', '3': 4, '4': 1, '5': 2, '10': 'endY'},
    const {'1': 'steps', '3': 5, '4': 1, '5': 13, '10': 'steps'},
    const {'1': 'appId', '3': 6, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `SwipeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List swipeRequestDescriptor = $convert.base64Decode(
    'CgxTd2lwZVJlcXVlc3QSFgoGc3RhcnRYGAEgASgCUgZzdGFydFgSFgoGc3RhcnRZGAIgASgCUgZzdGFydFkSEgoEZW5kWBgDIAEoAlIEZW5kWBISCgRlbmRZGAQgASgCUgRlbmRZEhQKBXN0ZXBzGAUgASgNUgVzdGVwcxIUCgVhcHBJZBgGIAEoCVIFYXBwSWQ=');
@$core.Deprecated('Use waitUntilVisibleRequestDescriptor instead')
const WaitUntilVisibleRequest$json = const {
  '1': 'WaitUntilVisibleRequest',
  '2': const [
    const {
      '1': 'selector',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.patrol.Selector',
      '10': 'selector'
    },
    const {'1': 'appId', '3': 2, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `WaitUntilVisibleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waitUntilVisibleRequestDescriptor =
    $convert.base64Decode(
        'ChdXYWl0VW50aWxWaXNpYmxlUmVxdWVzdBIsCghzZWxlY3RvchgBIAEoCzIQLnBhdHJvbC5TZWxlY3RvclIIc2VsZWN0b3ISFAoFYXBwSWQYAiABKAlSBWFwcElk');
@$core.Deprecated('Use handlePermissionRequestDescriptor instead')
const HandlePermissionRequest$json = const {
  '1': 'HandlePermissionRequest',
  '2': const [
    const {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.patrol.HandlePermissionRequest.Code',
      '10': 'code'
    },
  ],
  '4': const [HandlePermissionRequest_Code$json],
};

@$core.Deprecated('Use handlePermissionRequestDescriptor instead')
const HandlePermissionRequest_Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'WHILE_USING', '2': 0},
    const {'1': 'ONLY_THIS_TIME', '2': 1},
    const {'1': 'DENIED', '2': 2},
  ],
};

/// Descriptor for `HandlePermissionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List handlePermissionRequestDescriptor =
    $convert.base64Decode(
        'ChdIYW5kbGVQZXJtaXNzaW9uUmVxdWVzdBI4CgRjb2RlGAEgASgOMiQucGF0cm9sLkhhbmRsZVBlcm1pc3Npb25SZXF1ZXN0LkNvZGVSBGNvZGUiNwoEQ29kZRIPCgtXSElMRV9VU0lORxAAEhIKDk9OTFlfVEhJU19USU1FEAESCgoGREVOSUVEEAI=');
@$core.Deprecated('Use setLocationAccuracyRequestDescriptor instead')
const SetLocationAccuracyRequest$json = const {
  '1': 'SetLocationAccuracyRequest',
  '2': const [
    const {
      '1': 'locationAccuracy',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.patrol.SetLocationAccuracyRequest.LocationAccuracy',
      '10': 'locationAccuracy'
    },
  ],
  '4': const [SetLocationAccuracyRequest_LocationAccuracy$json],
};

@$core.Deprecated('Use setLocationAccuracyRequestDescriptor instead')
const SetLocationAccuracyRequest_LocationAccuracy$json = const {
  '1': 'LocationAccuracy',
  '2': const [
    const {'1': 'COARSE', '2': 0},
    const {'1': 'FINE', '2': 1},
  ],
};

/// Descriptor for `SetLocationAccuracyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setLocationAccuracyRequestDescriptor =
    $convert.base64Decode(
        'ChpTZXRMb2NhdGlvbkFjY3VyYWN5UmVxdWVzdBJfChBsb2NhdGlvbkFjY3VyYWN5GAEgASgOMjMucGF0cm9sLlNldExvY2F0aW9uQWNjdXJhY3lSZXF1ZXN0LkxvY2F0aW9uQWNjdXJhY3lSEGxvY2F0aW9uQWNjdXJhY3kiKAoQTG9jYXRpb25BY2N1cmFjeRIKCgZDT0FSU0UQABIICgRGSU5FEAE=');
@$core.Deprecated('Use permissionDialogVisibleRequestDescriptor instead')
const PermissionDialogVisibleRequest$json = const {
  '1': 'PermissionDialogVisibleRequest',
  '2': const [
    const {'1': 'timeoutMillis', '3': 1, '4': 1, '5': 4, '10': 'timeoutMillis'},
  ],
};

/// Descriptor for `PermissionDialogVisibleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionDialogVisibleRequestDescriptor =
    $convert.base64Decode(
        'Ch5QZXJtaXNzaW9uRGlhbG9nVmlzaWJsZVJlcXVlc3QSJAoNdGltZW91dE1pbGxpcxgBIAEoBFINdGltZW91dE1pbGxpcw==');
@$core.Deprecated('Use permissionDialogVisibleResponseDescriptor instead')
const PermissionDialogVisibleResponse$json = const {
  '1': 'PermissionDialogVisibleResponse',
  '2': const [
    const {'1': 'visible', '3': 1, '4': 1, '5': 8, '10': 'visible'},
  ],
};

/// Descriptor for `PermissionDialogVisibleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionDialogVisibleResponseDescriptor =
    $convert.base64Decode(
        'Ch9QZXJtaXNzaW9uRGlhbG9nVmlzaWJsZVJlc3BvbnNlEhgKB3Zpc2libGUYASABKAhSB3Zpc2libGU=');
@$core.Deprecated('Use selectorDescriptor instead')
const Selector$json = const {
  '1': 'Selector',
  '2': const [
    const {
      '1': 'text',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'text',
      '17': true
    },
    const {
      '1': 'textStartsWith',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'textStartsWith',
      '17': true
    },
    const {
      '1': 'textContains',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'textContains',
      '17': true
    },
    const {
      '1': 'className',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'className',
      '17': true
    },
    const {
      '1': 'contentDescription',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'contentDescription',
      '17': true
    },
    const {
      '1': 'contentDescriptionStartsWith',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'contentDescriptionStartsWith',
      '17': true
    },
    const {
      '1': 'contentDescriptionContains',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'contentDescriptionContains',
      '17': true
    },
    const {
      '1': 'resourceId',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 7,
      '10': 'resourceId',
      '17': true
    },
    const {
      '1': 'instance',
      '3': 9,
      '4': 1,
      '5': 13,
      '9': 8,
      '10': 'instance',
      '17': true
    },
    const {
      '1': 'enabled',
      '3': 10,
      '4': 1,
      '5': 8,
      '9': 9,
      '10': 'enabled',
      '17': true
    },
    const {
      '1': 'focused',
      '3': 11,
      '4': 1,
      '5': 8,
      '9': 10,
      '10': 'focused',
      '17': true
    },
    const {
      '1': 'pkg',
      '3': 12,
      '4': 1,
      '5': 9,
      '9': 11,
      '10': 'pkg',
      '17': true
    },
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
final $typed_data.Uint8List selectorDescriptor = $convert.base64Decode(
    'CghTZWxlY3RvchIXCgR0ZXh0GAEgASgJSABSBHRleHSIAQESKwoOdGV4dFN0YXJ0c1dpdGgYAiABKAlIAVIOdGV4dFN0YXJ0c1dpdGiIAQESJwoMdGV4dENvbnRhaW5zGAMgASgJSAJSDHRleHRDb250YWluc4gBARIhCgljbGFzc05hbWUYBCABKAlIA1IJY2xhc3NOYW1liAEBEjMKEmNvbnRlbnREZXNjcmlwdGlvbhgFIAEoCUgEUhJjb250ZW50RGVzY3JpcHRpb26IAQESRwocY29udGVudERlc2NyaXB0aW9uU3RhcnRzV2l0aBgGIAEoCUgFUhxjb250ZW50RGVzY3JpcHRpb25TdGFydHNXaXRoiAEBEkMKGmNvbnRlbnREZXNjcmlwdGlvbkNvbnRhaW5zGAcgASgJSAZSGmNvbnRlbnREZXNjcmlwdGlvbkNvbnRhaW5ziAEBEiMKCnJlc291cmNlSWQYCCABKAlIB1IKcmVzb3VyY2VJZIgBARIfCghpbnN0YW5jZRgJIAEoDUgIUghpbnN0YW5jZYgBARIdCgdlbmFibGVkGAogASgISAlSB2VuYWJsZWSIAQESHQoHZm9jdXNlZBgLIAEoCEgKUgdmb2N1c2VkiAEBEhUKA3BrZxgMIAEoCUgLUgNwa2eIAQFCBwoFX3RleHRCEQoPX3RleHRTdGFydHNXaXRoQg8KDV90ZXh0Q29udGFpbnNCDAoKX2NsYXNzTmFtZUIVChNfY29udGVudERlc2NyaXB0aW9uQh8KHV9jb250ZW50RGVzY3JpcHRpb25TdGFydHNXaXRoQh0KG19jb250ZW50RGVzY3JpcHRpb25Db250YWluc0INCgtfcmVzb3VyY2VJZEILCglfaW5zdGFuY2VCCgoIX2VuYWJsZWRCCgoIX2ZvY3VzZWRCBgoEX3BrZw==');
@$core.Deprecated('Use nativeViewDescriptor instead')
const NativeView$json = const {
  '1': 'NativeView',
  '2': const [
    const {'1': 'className', '3': 1, '4': 1, '5': 9, '10': 'className'},
    const {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    const {
      '1': 'contentDescription',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'contentDescription'
    },
    const {'1': 'focused', '3': 4, '4': 1, '5': 8, '10': 'focused'},
    const {'1': 'enabled', '3': 5, '4': 1, '5': 8, '10': 'enabled'},
    const {'1': 'childCount', '3': 6, '4': 1, '5': 5, '10': 'childCount'},
    const {'1': 'resourceName', '3': 7, '4': 1, '5': 9, '10': 'resourceName'},
    const {
      '1': 'applicationPackage',
      '3': 8,
      '4': 1,
      '5': 9,
      '10': 'applicationPackage'
    },
    const {
      '1': 'children',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.patrol.NativeView',
      '10': 'children'
    },
  ],
};

/// Descriptor for `NativeView`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nativeViewDescriptor = $convert.base64Decode(
    'CgpOYXRpdmVWaWV3EhwKCWNsYXNzTmFtZRgBIAEoCVIJY2xhc3NOYW1lEhIKBHRleHQYAiABKAlSBHRleHQSLgoSY29udGVudERlc2NyaXB0aW9uGAMgASgJUhJjb250ZW50RGVzY3JpcHRpb24SGAoHZm9jdXNlZBgEIAEoCFIHZm9jdXNlZBIYCgdlbmFibGVkGAUgASgIUgdlbmFibGVkEh4KCmNoaWxkQ291bnQYBiABKAVSCmNoaWxkQ291bnQSIgoMcmVzb3VyY2VOYW1lGAcgASgJUgxyZXNvdXJjZU5hbWUSLgoSYXBwbGljYXRpb25QYWNrYWdlGAggASgJUhJhcHBsaWNhdGlvblBhY2thZ2USLgoIY2hpbGRyZW4YCSADKAsyEi5wYXRyb2wuTmF0aXZlVmlld1IIY2hpbGRyZW4=');
@$core.Deprecated('Use notificationDescriptor instead')
const Notification$json = const {
  '1': 'Notification',
  '2': const [
    const {
      '1': 'appName',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'appName',
      '17': true
    },
    const {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    const {'1': 'content', '3': 3, '4': 1, '5': 9, '10': 'content'},
    const {'1': 'raw', '3': 4, '4': 1, '5': 9, '10': 'raw'},
  ],
  '8': const [
    const {'1': '_appName'},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode(
    'CgxOb3RpZmljYXRpb24SHQoHYXBwTmFtZRgBIAEoCUgAUgdhcHBOYW1liAEBEhQKBXRpdGxlGAIgASgJUgV0aXRsZRIYCgdjb250ZW50GAMgASgJUgdjb250ZW50EhAKA3JhdxgEIAEoCVIDcmF3QgoKCF9hcHBOYW1l');
@$core.Deprecated('Use submitTestResultsRequestDescriptor instead')
const SubmitTestResultsRequest$json = const {
  '1': 'SubmitTestResultsRequest',
  '2': const [
    const {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.patrol.SubmitTestResultsRequest.ResultsEntry',
      '10': 'results'
    },
  ],
  '3': const [SubmitTestResultsRequest_ResultsEntry$json],
};

@$core.Deprecated('Use submitTestResultsRequestDescriptor instead')
const SubmitTestResultsRequest_ResultsEntry$json = const {
  '1': 'ResultsEntry',
  '2': const [
    const {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': const {'7': true},
};

/// Descriptor for `SubmitTestResultsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitTestResultsRequestDescriptor =
    $convert.base64Decode(
        'ChhTdWJtaXRUZXN0UmVzdWx0c1JlcXVlc3QSRwoHcmVzdWx0cxgBIAMoCzItLnBhdHJvbC5TdWJtaXRUZXN0UmVzdWx0c1JlcXVlc3QuUmVzdWx0c0VudHJ5UgdyZXN1bHRzGjoKDFJlc3VsdHNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');
