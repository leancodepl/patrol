///
//  Generated code. Do not modify.
//  source: contracts.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

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
@$core.Deprecated('Use airplaneModeRequestDescriptor instead')
const AirplaneModeRequest$json = const {
  '1': 'AirplaneModeRequest',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `AirplaneModeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List airplaneModeRequestDescriptor =
    $convert.base64Decode(
        'ChNBaXJwbGFuZU1vZGVSZXF1ZXN0EhQKBWFwcElkGAEgASgJUgVhcHBJZA==');
@$core.Deprecated('Use cellularRequestDescriptor instead')
const CellularRequest$json = const {
  '1': 'CellularRequest',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `CellularRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cellularRequestDescriptor = $convert
    .base64Decode('Cg9DZWxsdWxhclJlcXVlc3QSFAoFYXBwSWQYASABKAlSBWFwcElk');
@$core.Deprecated('Use wiFiRequestDescriptor instead')
const WiFiRequest$json = const {
  '1': 'WiFiRequest',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `WiFiRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List wiFiRequestDescriptor =
    $convert.base64Decode('CgtXaUZpUmVxdWVzdBIUCgVhcHBJZBgBIAEoCVIFYXBwSWQ=');
@$core.Deprecated('Use bluetoothRequestDescriptor instead')
const BluetoothRequest$json = const {
  '1': 'BluetoothRequest',
  '2': const [
    const {'1': 'appId', '3': 1, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `BluetoothRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bluetoothRequestDescriptor = $convert
    .base64Decode('ChBCbHVldG9vdGhSZXF1ZXN0EhQKBWFwcElkGAEgASgJUgVhcHBJZA==');
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
@$core.Deprecated('Use getNativeWidgetsRequestDescriptor instead')
const GetNativeWidgetsRequest$json = const {
  '1': 'GetNativeWidgetsRequest',
  '2': const [
    const {
      '1': 'selector',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.patrol.Selector',
      '10': 'selector'
    },
  ],
};

/// Descriptor for `GetNativeWidgetsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNativeWidgetsRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXROYXRpdmVXaWRnZXRzUmVxdWVzdBIsCghzZWxlY3RvchgBIAEoCzIQLnBhdHJvbC5TZWxlY3RvclIIc2VsZWN0b3I=');
@$core.Deprecated('Use getNativeWidgetsResponseDescriptor instead')
const GetNativeWidgetsResponse$json = const {
  '1': 'GetNativeWidgetsResponse',
  '2': const [
    const {
      '1': 'nativeWidgets',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.patrol.NativeWidget',
      '10': 'nativeWidgets'
    },
  ],
};

/// Descriptor for `GetNativeWidgetsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNativeWidgetsResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXROYXRpdmVXaWRnZXRzUmVzcG9uc2USOgoNbmF0aXZlV2lkZ2V0cxgBIAMoCzIULnBhdHJvbC5OYXRpdmVXaWRnZXRSDW5hdGl2ZVdpZGdldHM=');
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
      '3': 1,
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
        'ChhHZXROb3RpZmljYXRpb25zUmVzcG9uc2USOgoNbm90aWZpY2F0aW9ucxgBIAMoCzIULnBhdHJvbC5Ob3RpZmljYXRpb25SDW5vdGlmaWNhdGlvbnM=');
@$core.Deprecated('Use tapRequestDescriptor instead')
const TapRequest$json = const {
  '1': 'TapRequest',
  '2': const [
    const {
      '1': 'Selector',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.patrol.Selector',
      '10': 'Selector'
    },
    const {'1': 'appId', '3': 2, '4': 1, '5': 9, '10': 'appId'},
  ],
};

/// Descriptor for `TapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tapRequestDescriptor = $convert.base64Decode(
    'CgpUYXBSZXF1ZXN0EiwKCFNlbGVjdG9yGAEgASgLMhAucGF0cm9sLlNlbGVjdG9yUghTZWxlY3RvchIUCgVhcHBJZBgCIAEoCVIFYXBwSWQ=');
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
  ],
  '8': const [
    const {'1': 'findBy'},
  ],
};

/// Descriptor for `EnterTextRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List enterTextRequestDescriptor = $convert.base64Decode(
    'ChBFbnRlclRleHRSZXF1ZXN0EhIKBGRhdGEYASABKAlSBGRhdGESFAoFYXBwSWQYAiABKAlSBWFwcElkEhYKBWluZGV4GAMgASgNSABSBWluZGV4Ei4KCHNlbGVjdG9yGAQgASgLMhAucGF0cm9sLlNlbGVjdG9ySABSCHNlbGVjdG9yQggKBmZpbmRCeQ==');
@$core.Deprecated('Use swipeRequestDescriptor instead')
const SwipeRequest$json = const {
  '1': 'SwipeRequest',
  '2': const [
    const {'1': 'startX', '3': 1, '4': 1, '5': 2, '10': 'startX'},
    const {'1': 'startY', '3': 2, '4': 1, '5': 2, '10': 'startY'},
    const {'1': 'endX', '3': 3, '4': 1, '5': 2, '10': 'endX'},
    const {'1': 'endY', '3': 4, '4': 1, '5': 2, '10': 'endY'},
    const {'1': 'steps', '3': 5, '4': 1, '5': 13, '10': 'steps'},
  ],
};

/// Descriptor for `SwipeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List swipeRequestDescriptor = $convert.base64Decode(
    'CgxTd2lwZVJlcXVlc3QSFgoGc3RhcnRYGAEgASgCUgZzdGFydFgSFgoGc3RhcnRZGAIgASgCUgZzdGFydFkSEgoEZW5kWBgDIAEoAlIEZW5kWBISCgRlbmRZGAQgASgCUgRlbmRZEhQKBXN0ZXBzGAUgASgNUgVzdGVwcw==');
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
@$core.Deprecated('Use nativeWidgetDescriptor instead')
const NativeWidget$json = const {
  '1': 'NativeWidget',
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
      '6': '.patrol.NativeWidget',
      '10': 'children'
    },
  ],
};

/// Descriptor for `NativeWidget`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nativeWidgetDescriptor = $convert.base64Decode(
    'CgxOYXRpdmVXaWRnZXQSHAoJY2xhc3NOYW1lGAEgASgJUgljbGFzc05hbWUSEgoEdGV4dBgCIAEoCVIEdGV4dBIuChJjb250ZW50RGVzY3JpcHRpb24YAyABKAlSEmNvbnRlbnREZXNjcmlwdGlvbhIYCgdmb2N1c2VkGAQgASgIUgdmb2N1c2VkEhgKB2VuYWJsZWQYBSABKAhSB2VuYWJsZWQSHgoKY2hpbGRDb3VudBgGIAEoBVIKY2hpbGRDb3VudBIiCgxyZXNvdXJjZU5hbWUYByABKAlSDHJlc291cmNlTmFtZRIuChJhcHBsaWNhdGlvblBhY2thZ2UYCCABKAlSEmFwcGxpY2F0aW9uUGFja2FnZRIwCghjaGlsZHJlbhgJIAMoCzIULnBhdHJvbC5OYXRpdmVXaWRnZXRSCGNoaWxkcmVu');
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
  ],
  '8': const [
    const {'1': '_appName'},
  ],
};

/// Descriptor for `Notification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationDescriptor = $convert.base64Decode(
    'CgxOb3RpZmljYXRpb24SHQoHYXBwTmFtZRgBIAEoCUgAUgdhcHBOYW1liAEBEhQKBXRpdGxlGAIgASgJUgV0aXRsZRIYCgdjb250ZW50GAMgASgJUgdjb250ZW50QgoKCF9hcHBOYW1l');
