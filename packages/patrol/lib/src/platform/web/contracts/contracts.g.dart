// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contracts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DartGroupEntry _$DartGroupEntryFromJson(Map<String, dynamic> json) =>
    DartGroupEntry(
      name: json['name'] as String,
      type: $enumDecode(_$GroupEntryTypeEnumMap, json['type']),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => DartGroupEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      skip: json['skip'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DartGroupEntryToJson(DartGroupEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': _$GroupEntryTypeEnumMap[instance.type]!,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'skip': instance.skip,
      'tags': instance.tags,
    };

const _$GroupEntryTypeEnumMap = {
  GroupEntryType.group: 'group',
  GroupEntryType.test: 'test',
};

ListDartTestsResponse _$ListDartTestsResponseFromJson(
  Map<String, dynamic> json,
) => ListDartTestsResponse(
  group: DartGroupEntry.fromJson(json['group'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListDartTestsResponseToJson(
  ListDartTestsResponse instance,
) => <String, dynamic>{'group': instance.group.toJson()};

RunDartTestRequest _$RunDartTestRequestFromJson(Map<String, dynamic> json) =>
    RunDartTestRequest(name: json['name'] as String);

Map<String, dynamic> _$RunDartTestRequestToJson(RunDartTestRequest instance) =>
    <String, dynamic>{'name': instance.name};

RunDartTestResponse _$RunDartTestResponseFromJson(Map<String, dynamic> json) =>
    RunDartTestResponse(
      result: $enumDecode(_$RunDartTestResponseResultEnumMap, json['result']),
      details: json['details'] as String?,
    );

Map<String, dynamic> _$RunDartTestResponseToJson(
  RunDartTestResponse instance,
) => <String, dynamic>{
  'result': _$RunDartTestResponseResultEnumMap[instance.result]!,
  'details': instance.details,
};

const _$RunDartTestResponseResultEnumMap = {
  RunDartTestResponseResult.success: 'success',
  RunDartTestResponseResult.skipped: 'skipped',
  RunDartTestResponseResult.failure: 'failure',
};

ConfigureRequest _$ConfigureRequestFromJson(Map<String, dynamic> json) =>
    ConfigureRequest(
      findTimeoutMillis: (json['findTimeoutMillis'] as num).toInt(),
    );

Map<String, dynamic> _$ConfigureRequestToJson(ConfigureRequest instance) =>
    <String, dynamic>{'findTimeoutMillis': instance.findTimeoutMillis};

OpenAppRequest _$OpenAppRequestFromJson(Map<String, dynamic> json) =>
    OpenAppRequest(appId: json['appId'] as String);

Map<String, dynamic> _$OpenAppRequestToJson(OpenAppRequest instance) =>
    <String, dynamic>{'appId': instance.appId};

OpenQuickSettingsRequest _$OpenQuickSettingsRequestFromJson(
  Map<String, dynamic> json,
) => OpenQuickSettingsRequest();

Map<String, dynamic> _$OpenQuickSettingsRequestToJson(
  OpenQuickSettingsRequest instance,
) => <String, dynamic>{};

OpenUrlRequest _$OpenUrlRequestFromJson(Map<String, dynamic> json) =>
    OpenUrlRequest(url: json['url'] as String);

Map<String, dynamic> _$OpenUrlRequestToJson(OpenUrlRequest instance) =>
    <String, dynamic>{'url': instance.url};

Selector _$SelectorFromJson(Map<String, dynamic> json) => Selector(
  className: json['className'] as String?,
  isCheckable: json['isCheckable'] as bool?,
  isChecked: json['isChecked'] as bool?,
  isClickable: json['isClickable'] as bool?,
  isEnabled: json['isEnabled'] as bool?,
  isFocusable: json['isFocusable'] as bool?,
  isFocused: json['isFocused'] as bool?,
  isLongClickable: json['isLongClickable'] as bool?,
  isScrollable: json['isScrollable'] as bool?,
  isSelected: json['isSelected'] as bool?,
  applicationPackage: json['applicationPackage'] as String?,
  contentDescription: json['contentDescription'] as String?,
  contentDescriptionStartsWith: json['contentDescriptionStartsWith'] as String?,
  contentDescriptionContains: json['contentDescriptionContains'] as String?,
  text: json['text'] as String?,
  textStartsWith: json['textStartsWith'] as String?,
  textContains: json['textContains'] as String?,
  resourceName: json['resourceName'] as String?,
  instance: (json['instance'] as num?)?.toInt(),
);

Map<String, dynamic> _$SelectorToJson(Selector instance) => <String, dynamic>{
  'className': instance.className,
  'isCheckable': instance.isCheckable,
  'isChecked': instance.isChecked,
  'isClickable': instance.isClickable,
  'isEnabled': instance.isEnabled,
  'isFocusable': instance.isFocusable,
  'isFocused': instance.isFocused,
  'isLongClickable': instance.isLongClickable,
  'isScrollable': instance.isScrollable,
  'isSelected': instance.isSelected,
  'applicationPackage': instance.applicationPackage,
  'contentDescription': instance.contentDescription,
  'contentDescriptionStartsWith': instance.contentDescriptionStartsWith,
  'contentDescriptionContains': instance.contentDescriptionContains,
  'text': instance.text,
  'textStartsWith': instance.textStartsWith,
  'textContains': instance.textContains,
  'resourceName': instance.resourceName,
  'instance': instance.instance,
};

GetNativeViewsRequest _$GetNativeViewsRequestFromJson(
  Map<String, dynamic> json,
) => GetNativeViewsRequest(
  selector: Selector.fromJson(json['selector'] as Map<String, dynamic>),
  appId: json['appId'] as String,
);

Map<String, dynamic> _$GetNativeViewsRequestToJson(
  GetNativeViewsRequest instance,
) => <String, dynamic>{
  'selector': instance.selector.toJson(),
  'appId': instance.appId,
};

GetNativeUITreeRequest _$GetNativeUITreeRequestFromJson(
  Map<String, dynamic> json,
) => GetNativeUITreeRequest(
  useNativeViewHierarchy: json['useNativeViewHierarchy'] as bool,
);

Map<String, dynamic> _$GetNativeUITreeRequestToJson(
  GetNativeUITreeRequest instance,
) => <String, dynamic>{
  'useNativeViewHierarchy': instance.useNativeViewHierarchy,
};

GetNativeUITreeRespone _$GetNativeUITreeResponeFromJson(
  Map<String, dynamic> json,
) => GetNativeUITreeRespone(
  roots: (json['roots'] as List<dynamic>)
      .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetNativeUITreeResponeToJson(
  GetNativeUITreeRespone instance,
) => <String, dynamic>{'roots': instance.roots.map((e) => e.toJson()).toList()};

NativeView _$NativeViewFromJson(Map<String, dynamic> json) => NativeView(
  resourceName: json['resourceName'] as String?,
  text: json['text'] as String?,
  className: json['className'] as String?,
  contentDescription: json['contentDescription'] as String?,
  applicationPackage: json['applicationPackage'] as String?,
  childCount: (json['childCount'] as num).toInt(),
  isCheckable: json['isCheckable'] as bool,
  isChecked: json['isChecked'] as bool,
  isClickable: json['isClickable'] as bool,
  isEnabled: json['isEnabled'] as bool,
  isFocusable: json['isFocusable'] as bool,
  isFocused: json['isFocused'] as bool,
  isLongClickable: json['isLongClickable'] as bool,
  isScrollable: json['isScrollable'] as bool,
  isSelected: json['isSelected'] as bool,
  visibleBounds: Rectangle.fromJson(
    json['visibleBounds'] as Map<String, dynamic>,
  ),
  visibleCenter: Point2D.fromJson(
    json['visibleCenter'] as Map<String, dynamic>,
  ),
  children: (json['children'] as List<dynamic>)
      .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NativeViewToJson(NativeView instance) =>
    <String, dynamic>{
      'resourceName': instance.resourceName,
      'text': instance.text,
      'className': instance.className,
      'contentDescription': instance.contentDescription,
      'applicationPackage': instance.applicationPackage,
      'childCount': instance.childCount,
      'isCheckable': instance.isCheckable,
      'isChecked': instance.isChecked,
      'isClickable': instance.isClickable,
      'isEnabled': instance.isEnabled,
      'isFocusable': instance.isFocusable,
      'isFocused': instance.isFocused,
      'isLongClickable': instance.isLongClickable,
      'isScrollable': instance.isScrollable,
      'isSelected': instance.isSelected,
      'visibleBounds': instance.visibleBounds.toJson(),
      'visibleCenter': instance.visibleCenter.toJson(),
      'children': instance.children.map((e) => e.toJson()).toList(),
    };

Rectangle _$RectangleFromJson(Map<String, dynamic> json) => Rectangle(
  minX: (json['minX'] as num).toDouble(),
  minY: (json['minY'] as num).toDouble(),
  maxX: (json['maxX'] as num).toDouble(),
  maxY: (json['maxY'] as num).toDouble(),
);

Map<String, dynamic> _$RectangleToJson(Rectangle instance) => <String, dynamic>{
  'minX': instance.minX,
  'minY': instance.minY,
  'maxX': instance.maxX,
  'maxY': instance.maxY,
};

Point2D _$Point2DFromJson(Map<String, dynamic> json) =>
    Point2D(x: (json['x'] as num).toDouble(), y: (json['y'] as num).toDouble());

Map<String, dynamic> _$Point2DToJson(Point2D instance) => <String, dynamic>{
  'x': instance.x,
  'y': instance.y,
};

GetNativeViewsResponse _$GetNativeViewsResponseFromJson(
  Map<String, dynamic> json,
) => GetNativeViewsResponse(
  nativeViews: (json['nativeViews'] as List<dynamic>)
      .map((e) => NativeView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetNativeViewsResponseToJson(
  GetNativeViewsResponse instance,
) => <String, dynamic>{
  'nativeViews': instance.nativeViews.map((e) => e.toJson()).toList(),
};

TapRequest _$TapRequestFromJson(Map<String, dynamic> json) => TapRequest(
  selector: Selector.fromJson(json['selector'] as Map<String, dynamic>),
  appId: json['appId'] as String,
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
  delayBetweenTapsMillis: (json['delayBetweenTapsMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$TapRequestToJson(TapRequest instance) =>
    <String, dynamic>{
      'selector': instance.selector.toJson(),
      'appId': instance.appId,
      'timeoutMillis': instance.timeoutMillis,
      'delayBetweenTapsMillis': instance.delayBetweenTapsMillis,
    };

TapAtRequest _$TapAtRequestFromJson(Map<String, dynamic> json) => TapAtRequest(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  appId: json['appId'] as String,
);

Map<String, dynamic> _$TapAtRequestToJson(TapAtRequest instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'appId': instance.appId,
    };

EnterTextRequest _$EnterTextRequestFromJson(Map<String, dynamic> json) =>
    EnterTextRequest(
      data: json['data'] as String,
      appId: json['appId'] as String,
      index: (json['index'] as num?)?.toInt(),
      selector: json['selector'] == null
          ? null
          : Selector.fromJson(json['selector'] as Map<String, dynamic>),
      keyboardBehavior: $enumDecode(
        _$KeyboardBehaviorEnumMap,
        json['keyboardBehavior'],
      ),
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
      dx: (json['dx'] as num?)?.toDouble(),
      dy: (json['dy'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$EnterTextRequestToJson(EnterTextRequest instance) =>
    <String, dynamic>{
      'data': instance.data,
      'appId': instance.appId,
      'index': instance.index,
      'selector': instance.selector?.toJson(),
      'keyboardBehavior': _$KeyboardBehaviorEnumMap[instance.keyboardBehavior]!,
      'timeoutMillis': instance.timeoutMillis,
      'dx': instance.dx,
      'dy': instance.dy,
    };

const _$KeyboardBehaviorEnumMap = {
  KeyboardBehavior.showAndDismiss: 'showAndDismiss',
  KeyboardBehavior.alternative: 'alternative',
};

SwipeRequest _$SwipeRequestFromJson(Map<String, dynamic> json) => SwipeRequest(
  appId: json['appId'] as String,
  startX: (json['startX'] as num).toDouble(),
  startY: (json['startY'] as num).toDouble(),
  endX: (json['endX'] as num).toDouble(),
  endY: (json['endY'] as num).toDouble(),
  steps: (json['steps'] as num).toInt(),
);

Map<String, dynamic> _$SwipeRequestToJson(SwipeRequest instance) =>
    <String, dynamic>{
      'appId': instance.appId,
      'startX': instance.startX,
      'startY': instance.startY,
      'endX': instance.endX,
      'endY': instance.endY,
      'steps': instance.steps,
    };

WaitUntilVisibleRequest _$WaitUntilVisibleRequestFromJson(
  Map<String, dynamic> json,
) => WaitUntilVisibleRequest(
  selector: Selector.fromJson(json['selector'] as Map<String, dynamic>),
  appId: json['appId'] as String,
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$WaitUntilVisibleRequestToJson(
  WaitUntilVisibleRequest instance,
) => <String, dynamic>{
  'selector': instance.selector.toJson(),
  'appId': instance.appId,
  'timeoutMillis': instance.timeoutMillis,
};

DarkModeRequest _$DarkModeRequestFromJson(Map<String, dynamic> json) =>
    DarkModeRequest(appId: json['appId'] as String);

Map<String, dynamic> _$DarkModeRequestToJson(DarkModeRequest instance) =>
    <String, dynamic>{'appId': instance.appId};

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  appName: json['appName'] as String?,
  title: json['title'] as String,
  content: json['content'] as String,
  raw: json['raw'] as String?,
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'title': instance.title,
      'content': instance.content,
      'raw': instance.raw,
    };

GetNotificationsResponse _$GetNotificationsResponseFromJson(
  Map<String, dynamic> json,
) => GetNotificationsResponse(
  notifications: (json['notifications'] as List<dynamic>)
      .map((e) => Notification.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetNotificationsResponseToJson(
  GetNotificationsResponse instance,
) => <String, dynamic>{
  'notifications': instance.notifications.map((e) => e.toJson()).toList(),
};

GetNotificationsRequest _$GetNotificationsRequestFromJson(
  Map<String, dynamic> json,
) => GetNotificationsRequest();

Map<String, dynamic> _$GetNotificationsRequestToJson(
  GetNotificationsRequest instance,
) => <String, dynamic>{};

TapOnNotificationRequest _$TapOnNotificationRequestFromJson(
  Map<String, dynamic> json,
) => TapOnNotificationRequest(
  index: (json['index'] as num?)?.toInt(),
  selector: json['selector'] == null
      ? null
      : Selector.fromJson(json['selector'] as Map<String, dynamic>),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$TapOnNotificationRequestToJson(
  TapOnNotificationRequest instance,
) => <String, dynamic>{
  'index': instance.index,
  'selector': instance.selector?.toJson(),
  'timeoutMillis': instance.timeoutMillis,
};

PermissionDialogVisibleResponse _$PermissionDialogVisibleResponseFromJson(
  Map<String, dynamic> json,
) => PermissionDialogVisibleResponse(visible: json['visible'] as bool);

Map<String, dynamic> _$PermissionDialogVisibleResponseToJson(
  PermissionDialogVisibleResponse instance,
) => <String, dynamic>{'visible': instance.visible};

PermissionDialogVisibleRequest _$PermissionDialogVisibleRequestFromJson(
  Map<String, dynamic> json,
) => PermissionDialogVisibleRequest(
  timeoutMillis: (json['timeoutMillis'] as num).toInt(),
);

Map<String, dynamic> _$PermissionDialogVisibleRequestToJson(
  PermissionDialogVisibleRequest instance,
) => <String, dynamic>{'timeoutMillis': instance.timeoutMillis};

HandlePermissionRequest _$HandlePermissionRequestFromJson(
  Map<String, dynamic> json,
) => HandlePermissionRequest(
  code: $enumDecode(_$HandlePermissionRequestCodeEnumMap, json['code']),
);

Map<String, dynamic> _$HandlePermissionRequestToJson(
  HandlePermissionRequest instance,
) => <String, dynamic>{
  'code': _$HandlePermissionRequestCodeEnumMap[instance.code]!,
};

const _$HandlePermissionRequestCodeEnumMap = {
  HandlePermissionRequestCode.whileUsing: 'whileUsing',
  HandlePermissionRequestCode.onlyThisTime: 'onlyThisTime',
  HandlePermissionRequestCode.denied: 'denied',
};

SetLocationAccuracyRequest _$SetLocationAccuracyRequestFromJson(
  Map<String, dynamic> json,
) => SetLocationAccuracyRequest(
  locationAccuracy: $enumDecode(
    _$SetLocationAccuracyRequestLocationAccuracyEnumMap,
    json['locationAccuracy'],
  ),
);

Map<String, dynamic> _$SetLocationAccuracyRequestToJson(
  SetLocationAccuracyRequest instance,
) => <String, dynamic>{
  'locationAccuracy':
      _$SetLocationAccuracyRequestLocationAccuracyEnumMap[instance
          .locationAccuracy]!,
};

const _$SetLocationAccuracyRequestLocationAccuracyEnumMap = {
  SetLocationAccuracyRequestLocationAccuracy.coarse: 'coarse',
  SetLocationAccuracyRequestLocationAccuracy.fine: 'fine',
};

SetMockLocationRequest _$SetMockLocationRequestFromJson(
  Map<String, dynamic> json,
) => SetMockLocationRequest(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  packageName: json['packageName'] as String,
);

Map<String, dynamic> _$SetMockLocationRequestToJson(
  SetMockLocationRequest instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'packageName': instance.packageName,
};

IsVirtualDeviceResponse _$IsVirtualDeviceResponseFromJson(
  Map<String, dynamic> json,
) => IsVirtualDeviceResponse(isVirtualDevice: json['isVirtualDevice'] as bool);

Map<String, dynamic> _$IsVirtualDeviceResponseToJson(
  IsVirtualDeviceResponse instance,
) => <String, dynamic>{'isVirtualDevice': instance.isVirtualDevice};

GetOsVersionResponse _$GetOsVersionResponseFromJson(
  Map<String, dynamic> json,
) => GetOsVersionResponse(osVersion: (json['osVersion'] as num).toInt());

Map<String, dynamic> _$GetOsVersionResponseToJson(
  GetOsVersionResponse instance,
) => <String, dynamic>{'osVersion': instance.osVersion};

TakeCameraPhotoRequest _$TakeCameraPhotoRequestFromJson(
  Map<String, dynamic> json,
) => TakeCameraPhotoRequest(
  shutterButtonSelector: json['shutterButtonSelector'] == null
      ? null
      : Selector.fromJson(
          json['shutterButtonSelector'] as Map<String, dynamic>,
        ),
  doneButtonSelector: json['doneButtonSelector'] == null
      ? null
      : Selector.fromJson(json['doneButtonSelector'] as Map<String, dynamic>),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
  appId: json['appId'] as String,
);

Map<String, dynamic> _$TakeCameraPhotoRequestToJson(
  TakeCameraPhotoRequest instance,
) => <String, dynamic>{
  'shutterButtonSelector': instance.shutterButtonSelector?.toJson(),
  'doneButtonSelector': instance.doneButtonSelector?.toJson(),
  'timeoutMillis': instance.timeoutMillis,
  'appId': instance.appId,
};

PickImageFromGalleryRequest _$PickImageFromGalleryRequestFromJson(
  Map<String, dynamic> json,
) => PickImageFromGalleryRequest(
  imageSelector: json['imageSelector'] == null
      ? null
      : Selector.fromJson(json['imageSelector'] as Map<String, dynamic>),
  imageIndex: (json['imageIndex'] as num?)?.toInt(),
  timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
  appId: json['appId'] as String,
);

Map<String, dynamic> _$PickImageFromGalleryRequestToJson(
  PickImageFromGalleryRequest instance,
) => <String, dynamic>{
  'imageSelector': instance.imageSelector?.toJson(),
  'imageIndex': instance.imageIndex,
  'timeoutMillis': instance.timeoutMillis,
  'appId': instance.appId,
};

PickMultipleImagesFromGalleryRequest
_$PickMultipleImagesFromGalleryRequestFromJson(Map<String, dynamic> json) =>
    PickMultipleImagesFromGalleryRequest(
      imageSelector: json['imageSelector'] == null
          ? null
          : Selector.fromJson(json['imageSelector'] as Map<String, dynamic>),
      imageIndexes: (json['imageIndexes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      timeoutMillis: (json['timeoutMillis'] as num?)?.toInt(),
      appId: json['appId'] as String,
    );

Map<String, dynamic> _$PickMultipleImagesFromGalleryRequestToJson(
  PickMultipleImagesFromGalleryRequest instance,
) => <String, dynamic>{
  'imageSelector': instance.imageSelector?.toJson(),
  'imageIndexes': instance.imageIndexes,
  'timeoutMillis': instance.timeoutMillis,
  'appId': instance.appId,
};
